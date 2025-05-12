module adc_sound_filter #(
    parameter ADC_WIDTH = 12,
    parameter FFT_POINTS = 64,
    parameter SAMPLING_RATE_HZ = 1000,
    parameter FFT_INPUT_WIDTH = 12,      // From your FFT module (sink_real/imag)
    parameter FFT_OUTPUT_WIDTH = 19,     // From your FFT module (source_real/imag)
    parameter MAG_SQ_WIDTH = 2 * FFT_OUTPUT_WIDTH + 1,
    parameter ENERGY_THRESHOLD = 5000000 // Example threshold, needs tuning
) (
    input logic clk,         // Main system clock
    input logic reset_n,     // System reset

    // ADC Inputs
    input logic mic_sample_clk, // Your 1kHz 'mic_freq'
    input logic signed [ADC_WIDTH-1:0] adc_mic_data, // Your 'mic_out'

    // Output
    output logic filtered_pitch_present,
    output logic [$clog2(FFT_POINTS/2 + 1)-1:0] dominant_bin_index, // Index of bin with highest magnitude in range
    output logic [FFT_POINTS/2:0][MAG_SQ_WIDTH-1:0] dbg_bin_magnitudes_squared // Magnitudes of bins 0 to N/2
);

    // --- Derived Parameters for Frequency Bins ---
    localparam real REAL_FREQ_RESOLUTION = real'(SAMPLING_RATE_HZ) / FFT_POINTS;
    localparam int K_MIN_TARGET = integer'($ceil(real'(50.0) / REAL_FREQ_RESOLUTION)); // 50 Hz
    localparam int K_MAX_TARGET = integer'($floor(real'(500.0) / REAL_FREQ_RESOLUTION)); // 500 Hz
    localparam int ACTUAL_K_MIN = (K_MIN_TARGET < 1) ? 1 : K_MIN_TARGET; // Ensure we don't use DC for pitch if 0-index
    localparam int ACTUAL_K_MAX = (K_MAX_TARGET > FFT_POINTS/2) ? FFT_POINTS/2 : K_MAX_TARGET;

    // --- Signals for FFT IP Interface ---
    logic        fft_sink_valid;
    logic        fft_sink_ready;
    logic [1:0]  fft_sink_error;
    logic        fft_sink_sop;
    logic        fft_sink_eop;
    logic signed [FFT_INPUT_WIDTH-1:0] fft_sink_real_data;
    logic signed [FFT_INPUT_WIDTH-1:0] fft_sink_imag_data;
    logic [6:0]  fft_fftpts_in;
    logic        fft_inverse_in;

    logic        fft_source_valid;
    logic        fft_source_ready;
    logic [1:0]  fft_source_error;
    logic        fft_source_sop;
    logic        fft_source_eop;
    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_source_real_data;
    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_source_imag_data;
    logic [6:0]  fft_fftpts_out;


    // --- Instantiate the FFT IP Core ---
    fft_64 fft_inst (
        .clk          (clk),
        .reset_n      (reset_n),
        .sink_valid   (fft_sink_valid),
        .sink_ready   (fft_sink_ready),
        .sink_error   (fft_sink_error),
        .sink_sop     (fft_sink_sop),
        .sink_eop     (fft_sink_eop),
        .sink_real    (fft_sink_real_data),
        .sink_imag    (fft_sink_imag_data),
        .fftpts_in    (fft_fftpts_in),
        .inverse      (fft_inverse_in),
        .source_valid (fft_source_valid),
        .source_ready (fft_source_ready),
        .source_error (fft_source_error),
        .source_sop   (fft_source_sop),
        .source_eop   (fft_source_eop),
        .source_real  (fft_source_real_data),
        .source_imag  (fft_source_imag_data),
        .fftpts_out   (fft_fftpts_out)
    );

    // --- Internal State and Data Buffers ---
    typedef enum logic [2:0] {
        S_IDLE,
        S_WAIT_ADC_SAMPLE,
        S_SEND_FFT_DATA,
        S_RECEIVE_FFT_DATA,
        S_PROCESS_FFT_OUTPUT
    } state_e;
    state_e current_state, next_state;

    logic signed [ADC_WIDTH-1:0] captured_adc_data;
    logic adc_data_rdy_flag;

    logic [$clog2(FFT_POINTS)-1:0] send_sample_count;
    logic [$clog2(FFT_POINTS)-1:0] receive_sample_count;

    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_real_buffer [FFT_POINTS-1:0];
    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_imag_buffer [FFT_POINTS-1:0];
    logic process_output_now;

    // For finding dominant bin
    logic [MAG_SQ_WIDTH-1:0] max_magnitude_in_range;
    logic [$clog2(FFT_POINTS/2 + 1)-1:0] current_dominant_bin_idx;


    // --- ADC Data Capture Logic (from mic_sample_clk domain to clk domain) ---
    logic mic_sample_clk_prev;
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mic_sample_clk_prev <= 1'b0;
            adc_data_rdy_flag <= 1'b0;
        end else begin
            mic_sample_clk_prev <= mic_sample_clk;
            adc_data_rdy_flag <= 1'b0;
            if (mic_sample_clk == 1'b1 && mic_sample_clk_prev == 1'b0) begin
                captured_adc_data <= adc_mic_data;
                adc_data_rdy_flag <= 1'b1;
            end
        end
    end

    // --- Control FSM and Data Path Logic ---
    assign fft_fftpts_in = FFT_POINTS;
    assign fft_inverse_in = 1'b0;
    assign fft_sink_error = 2'b00;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= S_IDLE;
            send_sample_count <= 0;
            receive_sample_count <= 0;
            fft_sink_valid <= 1'b0;
            fft_sink_sop <= 1'b0;
            fft_sink_eop <= 1'b0;
            fft_source_ready <= 1'b0;
            filtered_pitch_present <= 1'b0;
            dominant_bin_index <= '0; // Reset dominant bin
            process_output_now <= 1'b0;
             for (int i = 0; i <= FFT_POINTS/2; i++) begin
                dbg_bin_magnitudes_squared[i] <= '0;
            end
        end else begin
            current_state <= next_state;
            process_output_now <= 1'b0;

            case (current_state)
                S_SEND_FFT_DATA: begin
                    if (fft_sink_valid && fft_sink_ready) begin
                        if (send_sample_count == FFT_POINTS - 1) begin
                            send_sample_count <= 0;
                        end else begin
                            send_sample_count <= send_sample_count + 1;
                        end
                    end
                end
                S_RECEIVE_FFT_DATA: begin
                    if (fft_source_valid && fft_source_ready) begin
                        fft_real_buffer[receive_sample_count] <= fft_source_real_data;
                        fft_imag_buffer[receive_sample_count] <= fft_source_imag_data;
                        if (fft_source_eop) begin
                            receive_sample_count <= 0;
                        end else begin
                            receive_sample_count <= receive_sample_count + 1;
                        end
                    end
                end
                default: begin
                    // No specific register updates for these states here
                end
            endcase

            fft_sink_valid <= 1'b0;
            fft_sink_sop <= 1'b0;
            fft_sink_eop <= 1'b0;
            fft_source_ready <= 1'b0;

            case (next_state)
                S_SEND_FFT_DATA: begin
                    fft_sink_valid <= 1'b1;
                    fft_sink_sop <= (send_sample_count == 0);
                    fft_sink_eop <= (send_sample_count == FFT_POINTS - 1);
                end
                S_RECEIVE_FFT_DATA: begin
                    fft_source_ready <= 1'b1;
                end
                default: begin
                end
            endcase
        end
    end

    // State Transition Logic (combinational)
    always_comb begin
        next_state = current_state;
        fft_sink_real_data = captured_adc_data;
        fft_sink_imag_data = 0;

        case (current_state)
            S_IDLE: begin
                next_state = S_WAIT_ADC_SAMPLE;
            end
            S_WAIT_ADC_SAMPLE: begin
                if (adc_data_rdy_flag) begin
                    next_state = S_SEND_FFT_DATA;
                end else begin
                    next_state = S_WAIT_ADC_SAMPLE;
                end
            end
            S_SEND_FFT_DATA: begin
                if (fft_sink_valid && fft_sink_ready) begin
                    if (send_sample_count == FFT_POINTS - 1) begin
                        next_state = S_RECEIVE_FFT_DATA;
                    end else begin
                        next_state = S_WAIT_ADC_SAMPLE;
                    end
                end else begin
                    next_state = S_SEND_FFT_DATA;
                end
            end
            S_RECEIVE_FFT_DATA: begin
                if (fft_source_valid && fft_source_ready && fft_source_eop) begin
                    process_output_now = 1'b1;
                    next_state = S_PROCESS_FFT_OUTPUT;
                end else begin
                    next_state = S_RECEIVE_FFT_DATA;
                end
            end
            S_PROCESS_FFT_OUTPUT: begin
                next_state = S_IDLE;
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // --- FFT Output Processing and Filtering Logic ---
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            filtered_pitch_present <= 1'b0;
            dominant_bin_index <= '0; // Initialize dominant bin index
            max_magnitude_in_range <= '0; // Initialize max magnitude
            current_dominant_bin_idx <= '0;
            for (int i = 0; i <= FFT_POINTS/2; i++) begin
                dbg_bin_magnitudes_squared[i] <= '0;
            end
        end else begin
            if (process_output_now) begin
                logic [MAG_SQ_WIDTH-1:0] sum_selected_magnitudes = '0;
                logic signed [FFT_OUTPUT_WIDTH-1:0] temp_real, temp_imag;
                logic [MAG_SQ_WIDTH-1:0] current_mag_sq_val_calc [FFT_POINTS/2:0]; // Temporary for calculation

                // Calculate all squared magnitudes first
                temp_real = fft_real_buffer[0];
                current_mag_sq_val_calc[0] = temp_real * temp_real;
                for (int k = 1; k < FFT_POINTS/2; k++) begin
                    temp_real = fft_real_buffer[k];
                    temp_imag = fft_imag_buffer[k];
                    current_mag_sq_val_calc[k] = (temp_real * temp_real) + (temp_imag * temp_imag);
                end
                temp_real = fft_real_buffer[FFT_POINTS/2];
                current_mag_sq_val_calc[FFT_POINTS/2] = temp_real * temp_real;

                // Update debug output with all calculated magnitudes
                for (int i = 0; i <= FFT_POINTS/2; i++) begin
                    dbg_bin_magnitudes_squared[i] <= current_mag_sq_val_calc[i];
                end

                // Find dominant bin within the specified range and sum magnitudes
                max_magnitude_in_range = '0; // Reset for current frame
                current_dominant_bin_idx = ACTUAL_K_MIN; // Default to start of range or 0 if range is invalid

                for (int k = ACTUAL_K_MIN; k <= ACTUAL_K_MAX; k++) begin
                    if (k >= 0 && k <= FFT_POINTS/2) begin // Bounds check
                        sum_selected_magnitudes += current_mag_sq_val_calc[k];
                        if (current_mag_sq_val_calc[k] > max_magnitude_in_range) begin
                            max_magnitude_in_range <= current_mag_sq_val_calc[k];
                            current_dominant_bin_idx <= k; // k is type int, compatible with logic port
                        end
                    end
                end
                dominant_bin_index <= current_dominant_bin_idx; // Output the dominant bin index

                filtered_pitch_present <= (sum_selected_magnitudes > ENERGY_THRESHOLD);

            end
        end
    end

endmodule