`timescale 1ns/1ps

module adc_sound_filter_tb;

    // Parameters matching DUT
    localparam ADC_WIDTH = 12;
    localparam FFT_POINTS = 64;
    localparam SAMPLING_RATE_HZ = 1000;
    localparam FFT_INPUT_WIDTH = 12;      // Should match DUT's expectation for FFT sink
    localparam FFT_OUTPUT_WIDTH = 19;     // Should match DUT's expectation for FFT source
    localparam MAG_SQ_WIDTH = 2 * FFT_OUTPUT_WIDTH + 1;
    localparam ENERGY_THRESHOLD = 5000000; // Example - should match DUT parameter

    // Testbench Clock & Reset
    localparam CLK_PERIOD_NS = 20; // 50 MHz system clock
    localparam MIC_SAMPLE_CLK_PERIOD_NS = 1_000_000; // 1 kHz sample clock (1 ms)
    logic clk = 0;
    logic reset_n;
    logic mic_sample_clk = 0;

    // DUT Interface Signals
    logic signed [ADC_WIDTH-1:0] adc_mic_data;
    logic filtered_pitch_present;
    logic [$clog2(FFT_POINTS/2 + 1)-1:0] dominant_bin_index;
    logic [FFT_POINTS/2:0][MAG_SQ_WIDTH-1:0] dbg_bin_magnitudes_squared;

    // Instantiate DUT
    adc_sound_filter #(
        .ADC_WIDTH(ADC_WIDTH),
        .FFT_POINTS(FFT_POINTS),
        .SAMPLING_RATE_HZ(SAMPLING_RATE_HZ),
        .FFT_INPUT_WIDTH(FFT_INPUT_WIDTH),
        .FFT_OUTPUT_WIDTH(FFT_OUTPUT_WIDTH),
        .MAG_SQ_WIDTH(MAG_SQ_WIDTH),
        .ENERGY_THRESHOLD(ENERGY_THRESHOLD)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .mic_sample_clk(mic_sample_clk),
        .adc_mic_data(adc_mic_data),
        .filtered_pitch_present(filtered_pitch_present),
        .dominant_bin_index(dominant_bin_index),
        .dbg_bin_magnitudes_squared(dbg_bin_magnitudes_squared)
    );

    // Clock Generation
    always #(CLK_PERIOD_NS / 2) clk = ~clk;
    always #(MIC_SAMPLE_CLK_PERIOD_NS / 2) mic_sample_clk = ~mic_sample_clk;

    //-------------------------------------------------
    // --- FFT Behavioral Model (Interface Simulation) ---
    //-------------------------------------------------
    // This model mimics the Avalon-ST interface and latency
    // but does NOT perform a real FFT calculation.
    localparam FFT_LATENCY_CYCLES = 150; // Adjust based on expected/actual FFT latency

    // Interface signals mirroring the fft_64 module instance within the DUT
    logic        fft_model_sink_valid;
    logic        fft_model_sink_ready; // Output from model
    logic [1:0]  fft_model_sink_error; // Input to model (unused here)
    logic        fft_model_sink_sop;   // Input to model
    logic        fft_model_sink_eop;   // Input to model
    logic signed [FFT_INPUT_WIDTH-1:0] fft_model_sink_real; // Input to model
    logic signed [FFT_INPUT_WIDTH-1:0] fft_model_sink_imag; // Input to model
    logic [6:0]  fft_model_fftpts_in;  // Input to model
    logic        fft_model_inverse;    // Input to model

    logic        fft_model_source_valid; // Output from model
    logic        fft_model_source_ready; // Input to model
    logic [1:0]  fft_model_source_error; // Output from model
    logic        fft_model_source_sop;   // Output from model
    logic        fft_model_source_eop;   // Output from model
    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_model_source_real; // Output from model
    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_model_source_imag; // Output from model
    logic [6:0]  fft_model_fftpts_out;   // Output from model

    // --- Connect DUT's FFT interface signals to this model ---
    // This requires modifying the DUT slightly to expose its internal FFT interface signals
    // OR creating wires in the TB and connecting the DUT instance to those wires,
    // and then connecting those wires to the FFT model instance.
    // Assuming the second approach (wires in TB):

    // DUT FFT Interface wires
    logic        dut_fft_sink_valid;
    logic        dut_fft_sink_ready;
    logic [1:0]  dut_fft_sink_error;
    logic        dut_fft_sink_sop;
    logic        dut_fft_sink_eop;
    logic signed [FFT_INPUT_WIDTH-1:0] dut_fft_sink_real;
    logic signed [FFT_INPUT_WIDTH-1:0] dut_fft_sink_imag;
    logic [6:0]  dut_fft_fftpts_in;
    logic        dut_fft_inverse;
    logic        dut_fft_source_valid;
    logic        dut_fft_source_ready;
    logic [1:0]  dut_fft_source_error;
    logic        dut_fft_source_sop;
    logic        dut_fft_source_eop;
    logic signed [FFT_OUTPUT_WIDTH-1:0] dut_fft_source_real;
    logic signed [FFT_OUTPUT_WIDTH-1:0] dut_fft_source_imag;
    logic [6:0]  dut_fft_fftpts_out;

    // Re-instantiate DUT connecting to these wires (modify your DUT instance above)
    // ** NOTE: You need to modify the DUT instantiation above to connect to these wires
    // instead of directly to the fft_model signals. E.g.:
    // .fft_sink_valid(dut_fft_sink_valid), .fft_sink_ready(dut_fft_sink_ready), ...
    // .fft_source_valid(dut_fft_source_valid), .fft_source_ready(dut_fft_source_ready), ...

    // Connect wires to the FFT model
    assign fft_model_sink_valid = dut_fft_sink_valid;
    assign dut_fft_sink_ready = fft_model_sink_ready; // Model drives ready TO DUT
    assign fft_model_sink_error = dut_fft_sink_error;
    assign fft_model_sink_sop = dut_fft_sink_sop;
    assign fft_model_sink_eop = dut_fft_sink_eop;
    assign fft_model_sink_real = dut_fft_sink_real;
    assign fft_model_sink_imag = dut_fft_sink_imag;
    assign fft_model_fftpts_in = dut_fft_fftpts_in;
    assign fft_model_inverse = dut_fft_inverse;

    assign dut_fft_source_valid = fft_model_source_valid; // Model drives valid TO DUT
    assign fft_model_source_ready = dut_fft_source_ready;
    assign dut_fft_source_error = fft_model_source_error;
    assign dut_fft_source_sop = fft_model_source_sop;
    assign dut_fft_source_eop = fft_model_source_eop;
    assign dut_fft_source_real = fft_model_source_real;
    assign dut_fft_source_imag = fft_model_source_imag;
    assign dut_fft_source_fftpts_out = fft_model_fftpts_out;


    // --- FFT Model Internal Logic ---
    typedef enum logic [1:0] { FFT_M_IDLE, FFT_M_RECEIVE, FFT_M_DELAY, FFT_M_SEND } fft_model_state_e;
    fft_model_state_e fft_model_state;
    logic signed [FFT_INPUT_WIDTH-1:0] fft_model_in_buffer [FFT_POINTS-1:0];
    int fft_model_in_count;
    int fft_model_out_count;
    int fft_model_latency_count;

    // Model's sink ready logic
    assign fft_model_sink_ready = (fft_model_state == FFT_M_RECEIVE || fft_model_state == FFT_M_IDLE);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            fft_model_state <= FFT_M_IDLE;
            fft_model_in_count <= 0;
            fft_model_out_count <= 0;
            fft_model_latency_count <= 0;
            fft_model_source_valid <= 1'b0;
            fft_model_source_sop <= 1'b0;
            fft_model_source_eop <= 1'b0;
            fft_model_source_real <= '0;
            fft_model_source_imag <= '0;
            fft_model_source_error <= '0;
            fft_model_fftpts_out <= '0;
        end else begin
            // Default outputs
            fft_model_source_valid <= 1'b0;
            fft_model_source_sop <= 1'b0;
            fft_model_source_eop <= 1'b0;

            case (fft_model_state)
                FFT_M_IDLE: begin
                    if (fft_model_sink_valid && fft_model_sink_ready && fft_model_sink_sop) begin
                        fft_model_in_buffer[0] <= fft_model_sink_real;
                        fft_model_in_count <= 1;
                        if (fft_model_sink_eop) begin
                           fft_model_latency_count <= 0;
                           fft_model_state <= FFT_M_DELAY;
                           fft_model_in_count <= 0;
                        end else begin
                            fft_model_state <= FFT_M_RECEIVE;
                        end
                    end
                end
                FFT_M_RECEIVE: begin
                     if (fft_model_sink_valid && fft_model_sink_ready) begin
                        fft_model_in_buffer[fft_model_in_count] <= fft_model_sink_real;
                        if (fft_model_sink_eop) begin
                           fft_model_latency_count <= 0;
                           fft_model_state <= FFT_M_DELAY;
                           fft_model_in_count <= 0;
                        end else begin
                           fft_model_in_count <= fft_model_in_count + 1;
                        end
                     end
                end
                FFT_M_DELAY: begin
                    if (fft_model_latency_count >= FFT_LATENCY_CYCLES - 1) begin // Use >= for robustness
                        fft_model_latency_count <= 0;
                        fft_model_out_count <= 0;
                        fft_model_state <= FFT_M_SEND;
                    end else begin
                        fft_model_latency_count <= fft_model_latency_count + 1;
                    end
                end
                FFT_M_SEND: begin
                    fft_model_source_valid <= 1'b1;
                    fft_model_source_sop <= (fft_model_out_count == 0);
                    fft_model_source_eop <= (fft_model_out_count == FFT_POINTS - 1);
                    fft_model_fftpts_out <= FFT_POINTS; // Assuming fixed point FFT
                    fft_model_source_error <= '0;

                    // --- Dummy Output Generation ---
                    // Pass through scaled input data as a simple placeholder behavior
                    if (fft_model_out_count < FFT_POINTS) begin
                        fft_model_source_real <= fft_model_in_buffer[fft_model_out_count] <<< (FFT_OUTPUT_WIDTH - FFT_INPUT_WIDTH);
                        fft_model_source_imag <= 0; // No imaginary part in this dummy model
                    end else begin
                        fft_model_source_real <= '0;
                        fft_model_source_imag <= '0;
                    end

                    if (fft_model_source_ready) begin // Wait for DUT to be ready
                        if (fft_model_out_count == FFT_POINTS - 1) begin
                            fft_model_state <= FFT_M_IDLE; // Done sending
                            fft_model_out_count <= 0;
                        end else begin
                            fft_model_out_count <= fft_model_out_count + 1;
                        end
                    end
                end
                default: fft_model_state <= FFT_M_IDLE;
            endcase
        end
    end
    //-------------------------------------------------
    // --- End FFT Behavioral Model ---
    //-------------------------------------------------


    //-------------------------------------------------
    // --- Stimulus Generation ---
    //-------------------------------------------------
    real Time_ms = 0.0;
    real Freq_Hz = 100.0; // Test frequency
    real Ampl = 1500.0;  // Amplitude (max for 12-bit signed is 2047)

    initial begin
        // Reset sequence
        $display("TB: Applying Reset...");
        reset_n = 1'b1; // Start high for negedge detection if needed
        adc_mic_data = 0;
        #(CLK_PERIOD_NS);
        reset_n = 1'b0;
        #(CLK_PERIOD_NS * 5); // Hold reset for a few cycles
        reset_n = 1'b1;
        $display("TB: Reset Released.");
        #(CLK_PERIOD_NS * 10); // Wait after reset

        // --- Test Scenario 1: ~100 Hz Sine Wave ---
        Freq_Hz = 100.0; // Expected bin = round(100/15.625) = 6
        Ampl = 1500.0;
        $display("TB: Starting 100 Hz Sine Wave Test @ %t", $time);
        apply_stimulus(FFT_POINTS + 5); // Apply for > 1 FFT frame
        $display("TB: Finished 100 Hz Sine Wave Test Stimulus @ %t", $time);
        $display("TB: Expecting Dominant Bin around 6");
        wait_for_processing_completion(1); // Wait for 1 frame to be processed

        // --- Test Scenario 2: ~300 Hz Sine Wave ---
        Freq_Hz = 300.0; // Expected bin = round(300/15.625) = 19
        Ampl = 1800.0;
        $display("TB: Starting 300 Hz Sine Wave Test @ %t", $time);
        apply_stimulus(FFT_POINTS + 5);
        $display("TB: Finished 300 Hz Sine Wave Test Stimulus @ %t", $time);
        $display("TB: Expecting Dominant Bin around 19");
        wait_for_processing_completion(1);

        // --- Test Scenario 3: Silence ---
        Freq_Hz = 100.0; // Freq doesn't matter
        Ampl = 0.0;
        $display("TB: Starting Silence Test @ %t", $time);
        apply_stimulus(FFT_POINTS + 5);
        $display("TB: Finished Silence Test Stimulus @ %t", $time);
        $display("TB: Expecting filtered_pitch_present = 0");
        wait_for_processing_completion(1);

        // --- Test Scenario 4: Out of band (low) ---
        Freq_Hz = 30.0; // Below 50Hz. Expected actual bin = 2.
        Ampl = 1500.0;
        $display("TB: Starting 30 Hz (OOB Low) Test @ %t", $time);
        apply_stimulus(FFT_POINTS + 5);
        $display("TB: Finished 30 Hz Test Stimulus @ %t", $time);
        $display("TB: Expecting dominant bin NOT = 2 (should be in 4-32 range)");
        wait_for_processing_completion(1);

        // --- Test Scenario 5: Out of band (high, aliased) ---
        Freq_Hz = 700.0; // Aliases to 300 Hz. Expected bin = 19.
        Ampl = 1600.0;
        $display("TB: Starting 700 Hz (Aliased to 300Hz) Test @ %t", $time);
        apply_stimulus(FFT_POINTS + 5);
        $display("TB: Finished 700 Hz Test Stimulus @ %t", $time);
        $display("TB: Expecting dominant bin around 19");
        wait_for_processing_completion(1);


        $display("TB: All Test Scenarios Complete @ %t", $time);
        $stop;
    end

    // Task to apply sine wave stimulus for N samples
    task apply_stimulus (input int num_samples);
        integer i;
        real current_time_sec;
        real sample_val_real;
        logic signed [ADC_WIDTH-1:0] sample_val_signed;

        for (i = 0; i < num_samples; i = i + 1) begin
            // Wait for the next sample clock edge where data is expected
            @(posedge mic_sample_clk);
            current_time_sec = Time_ms / 1000.0;
            sample_val_real = Ampl * $sin(2.0 * $M_PI * Freq_Hz * current_time_sec);

            // Clamp and convert to signed 12-bit
            if (sample_val_real > 2047.0) sample_val_real = 2047.0;
            if (sample_val_real < -2048.0) sample_val_real = -2048.0;
            sample_val_signed = signed'(sample_val_real);

            adc_mic_data <= sample_val_signed;
            Time_ms = Time_ms + 1.0; // Increment time by 1ms per sample

            // Hold the value until the next sample edge
            // Wait for negedge to simulate holding value between posedges
             @(negedge mic_sample_clk);
             adc_mic_data <= sample_val_signed;

        end
        // Set input to 0 after stimulus sequence
         @(posedge mic_sample_clk); // Align with sample clock
         adc_mic_data <= 0;
         @(negedge mic_sample_clk);
         adc_mic_data <= 0;

    endtask

    // Task to wait for DUT to signal processing completion
    task wait_for_processing_completion (input int num_frames);
        integer frame_count = 0;
        // Need a signal from DUT indicating completion. Using internal signal 'process_output_now'
        // Requires modifying DUT or using a different indicator if 'process_output_now' is not accessible.
        // Let's assume we can monitor dominant_bin_index changes after expected latency.
        int wait_cycles = num_frames * (FFT_POINTS * MIC_SAMPLE_CLK_PERIOD_NS / CLK_PERIOD_NS + FFT_LATENCY_CYCLES + 100); // Estimate cycles
        $display("TB: Waiting approx %0d cycles for %0d frame(s) processing...", wait_cycles, num_frames);
        repeat(wait_cycles) @(posedge clk);
        $display("TB: Wait complete.");
    endtask


    // --- Monitoring / Display ---
    // Monitor key signals on clock edge for changes or specific events
    logic filtered_pitch_prev;
    logic [$clog2(FFT_POINTS/2 + 1)-1:0] dominant_bin_prev;
    initial begin
        filtered_pitch_prev = 1'bx; // Initialize to unknown
        dominant_bin_prev = 'x;
    end

    always @(posedge clk) begin
        // Example: Display output only when it changes
        if (reset_n && (filtered_pitch_present !== filtered_pitch_prev || dominant_bin_index !== dominant_bin_prev)) begin
             $display("TB: @ %t : Output Changed! Filtered Present: %b -> %b, Dominant Bin: %d -> %d (Freq ~%.1f Hz)",
                     $time, filtered_pitch_prev, filtered_pitch_present,
                     dominant_bin_prev, dominant_bin_index,
                     real'(dominant_bin_index) * 15.625);
             filtered_pitch_prev = filtered_pitch_present;
             dominant_bin_prev = dominant_bin_index;
        end else begin
             // Update previous values even if no change for next comparison
             filtered_pitch_prev = filtered_pitch_present;
             dominant_bin_prev = dominant_bin_index;
        end
    end

endmodule