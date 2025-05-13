`timescale 1ns/1ps

// Testbench for adc_sound_filter - Integer Stimulus Version
module adc_sound_filter_tb;

    // Parameters matching DUT
    localparam ADC_WIDTH = 12;
    localparam FFT_POINTS = 64;
    localparam SAMPLING_RATE_HZ = 1000; // Still relevant for interpreting results conceptually
    localparam FFT_INPUT_WIDTH = 12;
    localparam FFT_OUTPUT_WIDTH = 19;
    localparam MAG_SQ_WIDTH = 2 * FFT_OUTPUT_WIDTH + 1;
    localparam ENERGY_THRESHOLD = 5000000; // Should match DUT parameter

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

    //-------------------------------------------------
    // --- DUT Instantiation ---
    //-------------------------------------------------
    // ** IMPORTANT: Connect DUT FFT Interface to dut_fft_... wires below **
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

        // Add connections for DUT's FFT interface ports here, connecting to dut_fft_... wires
        // Example:
        // .fft_sink_valid(dut_fft_sink_valid), // Output from DUT
        // .fft_sink_ready(dut_fft_sink_ready), // Input to DUT
        // ... other sink ports ...
        // .fft_source_valid(dut_fft_source_valid), // Input to DUT
        // .fft_source_ready(dut_fft_source_ready), // Output from DUT
        // ... other source ports ...
    );

    // Clock Generation
    always #(CLK_PERIOD_NS / 2) clk = ~clk;
    always #(MIC_SAMPLE_CLK_PERIOD_NS / 2) mic_sample_clk = ~mic_sample_clk;

    //-------------------------------------------------
    // --- FFT Behavioral Model (Interface Simulation - No 'real' used) ---
    //-------------------------------------------------
    localparam FFT_LATENCY_CYCLES = 150; // Adjust based on expected/actual FFT latency

    // --- Wires connecting DUT instance to FFT Model ---
    // These act as the wires between your DUT and the actual FFT IP
    logic        dut_fft_sink_valid;
    logic        dut_fft_sink_ready; // Driven by FFT Model
    logic [1:0]  dut_fft_sink_error;
    logic        dut_fft_sink_sop;
    logic        dut_fft_sink_eop;
    logic signed [FFT_INPUT_WIDTH-1:0] dut_fft_sink_real;
    logic signed [FFT_INPUT_WIDTH-1:0] dut_fft_sink_imag;
    logic [6:0]  dut_fft_fftpts_in;
    logic        dut_fft_inverse;
    logic        dut_fft_source_valid; // Driven by FFT Model
    logic        dut_fft_source_ready;
    logic [1:0]  dut_fft_source_error; // Driven by FFT Model
    logic        dut_fft_source_sop;   // Driven by FFT Model
    logic        dut_fft_source_eop;   // Driven by FFT Model
    logic signed [FFT_OUTPUT_WIDTH-1:0] dut_fft_source_real; // Driven by FFT Model
    logic signed [FFT_OUTPUT_WIDTH-1:0] dut_fft_source_imag; // Driven by FFT Model
    logic [6:0]  dut_fft_fftpts_out;   // Driven by FFT Model

    // --- FFT Model Interface signals ---
    // These match the ports of the fft_64 module
    logic        fft_model_sink_valid;
    logic        fft_model_sink_ready; // Model output
    logic [1:0]  fft_model_sink_error;
    logic        fft_model_sink_sop;
    logic        fft_model_sink_eop;
    logic signed [FFT_INPUT_WIDTH-1:0] fft_model_sink_real;
    logic signed [FFT_INPUT_WIDTH-1:0] fft_model_sink_imag;
    logic [6:0]  fft_model_fftpts_in;
    logic        fft_model_inverse;

    logic        fft_model_source_valid; // Model output
    logic        fft_model_source_ready;
    logic [1:0]  fft_model_source_error; // Model output
    logic        fft_model_source_sop;   // Model output
    logic        fft_model_source_eop;   // Model output
    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_model_source_real; // Model output
    logic signed [FFT_OUTPUT_WIDTH-1:0] fft_model_source_imag; // Model output
    logic [6:0]  fft_model_fftpts_out;   // Model output

    // Connect the DUT wires to the FFT model's interface
    assign fft_model_sink_valid = dut_fft_sink_valid;
    assign dut_fft_sink_ready = fft_model_sink_ready; // Model drives ready TO DUT wire
    assign fft_model_sink_error = dut_fft_sink_error;
    assign fft_model_sink_sop = dut_fft_sink_sop;
    assign fft_model_sink_eop = dut_fft_sink_eop;
    assign fft_model_sink_real = dut_fft_sink_real;
    assign fft_model_sink_imag = dut_fft_sink_imag;
    assign fft_model_fftpts_in = dut_fft_fftpts_in;
    assign fft_model_inverse = dut_fft_inverse;

    assign dut_fft_source_valid = fft_model_source_valid; // Model drives valid TO DUT wire
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
    integer fft_model_in_count; // Use integer for counters
    integer fft_model_out_count;
    integer fft_model_latency_count;

    // Model's sink ready logic - ready to receive data when idle or receiving
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
            // Default outputs for source interface
            fft_model_source_valid <= 1'b0;
            fft_model_source_sop <= 1'b0;
            fft_model_source_eop <= 1'b0;

            // Model state machine logic
            case (fft_model_state)
                FFT_M_IDLE: begin
                    if (fft_model_sink_valid && fft_model_sink_ready && fft_model_sink_sop) begin
                        if (fft_model_in_count < FFT_POINTS) // Basic bounds check
                           fft_model_in_buffer[0] <= fft_model_sink_real;
                        fft_model_in_count <= 1;
                        fft_model_state <= (fft_model_sink_eop) ? FFT_M_DELAY : FFT_M_RECEIVE;
                        if(fft_model_sink_eop) fft_model_in_count <= 0;
                    end
                end
                FFT_M_RECEIVE: begin
                     if (fft_model_sink_valid && fft_model_sink_ready) begin
                        if (fft_model_in_count < FFT_POINTS) begin // Bounds check
                           fft_model_in_buffer[fft_model_in_count] <= fft_model_sink_real;
                        end
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
                    if (fft_model_latency_count >= FFT_LATENCY_CYCLES - 1) begin
                        fft_model_latency_count <= 0;
                        fft_model_out_count <= 0;
                        fft_model_state <= FFT_M_SEND;
                    end else begin
                        fft_model_latency_count <= fft_model_latency_count + 1;
                    end
                end
                FFT_M_SEND: begin
                    fft_model_source_valid <= 1'b1; // Assert valid when sending
                    fft_model_source_sop <= (fft_model_out_count == 0);
                    fft_model_source_eop <= (fft_model_out_count == FFT_POINTS - 1);
                    fft_model_fftpts_out <= FFT_POINTS;
                    fft_model_source_error <= '0;

                    // Dummy Output Generation (Scaled Pass-through)
                    if (fft_model_out_count < FFT_POINTS) begin
                        fft_model_source_real <= fft_model_in_buffer[fft_model_out_count] <<< (FFT_OUTPUT_WIDTH - FFT_INPUT_WIDTH);
                        fft_model_source_imag <= 0; // Simple model: no imaginary output
                    end else begin // Avoid potential index out of bounds if count goes wrong
                        fft_model_source_real <= '0;
                        fft_model_source_imag <= '0;
                    end

                    // Advance output count only if DUT accepts the data
                    if (fft_model_source_ready) begin
                        if (fft_model_out_count == FFT_POINTS - 1) begin
                            fft_model_state <= FFT_M_IDLE; // Done sending
                            fft_model_out_count <= 0;
                        end else begin
                            fft_model_out_count <= fft_model_out_count + 1;
                            // Stay in SEND state
                        end
                    end
                    // else: Stay in SEND, keep valid high, data stable, wait for ready
                end
                default: fft_model_state <= FFT_M_IDLE;
            endcase
        end
    end
    //-------------------------------------------------
    // --- End FFT Behavioral Model ---
    //-------------------------------------------------


    //-------------------------------------------------
    // --- Stimulus Generation (Using Integers Only) ---
    //-------------------------------------------------
    integer sample_index = 0; // Use integer for sample count

    initial begin
        // Reset sequence
        $display("TB: Applying Reset...");
        reset_n = 1'b1;
        adc_mic_data = 0;
        #(CLK_PERIOD_NS);
        reset_n = 1'b0;
        #(CLK_PERIOD_NS * 5);
        reset_n = 1'b1;
        $display("TB: Reset Released.");
        #(CLK_PERIOD_NS * 10);

		  /*
        // --- Test Scenario 1: Constant DC Value ---
        $display("TB: Starting Constant DC Test (Value: 500) @ %t", $time);
        apply_stimulus_int(FFT_POINTS + 5, 500); // Apply for > 1 FFT frame
        $display("TB: Finished Constant DC Test Stimulus @ %t", $time);
        wait_for_processing_completion(1); // Wait for 1 frame to be processed

        // --- Test Scenario 2: Alternating Value ---
        $display("TB: Starting Alternating Value Test (+/- 1000) @ %t", $time);
        apply_stimulus_alt(FFT_POINTS + 5, 1000, -1000);
        $display("TB: Finished Alternating Value Test Stimulus @ %t", $time);
        wait_for_processing_completion(1);

        // --- Test Scenario 3: Zero Input (Silence) ---
        $display("TB: Starting Zero Input Test @ %t", $time);
        apply_stimulus_int(FFT_POINTS + 5, 0);
        $display("TB: Finished Zero Input Test Stimulus @ %t", $time);
        wait_for_processing_completion(1);

        // --- Test Scenario 4: Ramp Input ---
        $display("TB: Starting Ramp Input Test (0 to 630) @ %t", $time);
        apply_stimulus_ramp(FFT_POINTS + 5, 0, 10); // Ramp up by 10 each sample
        $display("TB: Finished Ramp Input Test Stimulus @ %t", $time);
        wait_for_processing_completion(1);

        $display("TB: All Test Scenarios Complete @ %t", $time);
		  */
        $stop;
    end

    // Task to apply a constant integer stimulus
    task apply_stimulus_int (input integer num_samples, input logic signed [ADC_WIDTH-1:0] value);
        integer i;
        for (i = 0; i < num_samples; i = i + 1) begin
            @(posedge mic_sample_clk); // Wait for sample edge
            adc_mic_data <= value;     // Apply value
            sample_index <= sample_index + 1;
            @(negedge mic_sample_clk); // Wait for negedge to simulate holding
            adc_mic_data <= value;     // Hold value
        end
        // Set input to 0 after stimulus sequence (aligned with sample clock)
        @(posedge mic_sample_clk); adc_mic_data <= 0;
        @(negedge mic_sample_clk); adc_mic_data <= 0;
    endtask

    // Task to apply alternating integer stimulus
    task apply_stimulus_alt (input integer num_samples,
                             input logic signed [ADC_WIDTH-1:0] val1,
                             input logic signed [ADC_WIDTH-1:0] val2);
        integer i;
        for (i = 0; i < num_samples; i = i + 1) begin
             logic signed [ADC_WIDTH-1:0] current_val;
             current_val = (i % 2 == 0) ? val1 : val2; // Determine value for this sample index
             @(posedge mic_sample_clk);
             adc_mic_data <= current_val;
             sample_index <= sample_index + 1;
             @(negedge mic_sample_clk);
             adc_mic_data <= current_val; // Hold value
        end
         @(posedge mic_sample_clk); adc_mic_data <= 0;
         @(negedge mic_sample_clk); adc_mic_data <= 0;
    endtask

     // Task to apply ramping integer stimulus
    task apply_stimulus_ramp (input integer num_samples,
                              input logic signed [ADC_WIDTH-1:0] start_val,
                              input logic signed [ADC_WIDTH-1:0] step);
        integer i;
        logic signed [ADC_WIDTH-1:0] current_val = start_val;
        for (i = 0; i < num_samples; i = i + 1) begin
            @(posedge mic_sample_clk);
            adc_mic_data <= current_val;
            sample_index <= sample_index + 1;
            @(negedge mic_sample_clk); // Hold value during negedge phase
            adc_mic_data <= current_val;
            current_val = current_val + step; // Update for next sample
        end
         @(posedge mic_sample_clk); adc_mic_data <= 0;
         @(negedge mic_sample_clk); adc_mic_data <= 0;
    endtask

    // Task to wait for DUT processing (simple delay based estimate)
    task wait_for_processing_completion (input integer num_frames);
        integer wait_cycles = num_frames * (FFT_POINTS * MIC_SAMPLE_CLK_PERIOD_NS / CLK_PERIOD_NS + FFT_LATENCY_CYCLES + 200); // Estimate cycles, added more margin
        $display("TB: Waiting approx %0d cycles for %0d frame(s) processing...", wait_cycles, num_frames);
        repeat(wait_cycles) @(posedge clk);
        $display("TB: Wait complete.");
    endtask

    //-------------------------------------------------
    // --- Monitoring / Display (No 'real' used here) ---
    //-------------------------------------------------
    logic filtered_pitch_prev;
    logic [$clog2(FFT_POINTS/2 + 1)-1:0] dominant_bin_prev;
    initial begin
        filtered_pitch_prev = 1'bx; // Initialize to unknown
        dominant_bin_prev = 'x;
    end

    always @(posedge clk) begin
        // Monitor when outputs change after reset
        if (reset_n && (filtered_pitch_present !== filtered_pitch_prev || dominant_bin_index !== dominant_bin_prev)) begin
             $display("TB: @ %t : Output Changed! Filtered Present: %b -> %b, Dominant Bin: %d -> %d",
                     $time, filtered_pitch_prev, filtered_pitch_present,
                     dominant_bin_prev, dominant_bin_index);
        end
        // Update previous values for next cycle comparison
        if(reset_n) begin
             filtered_pitch_prev = filtered_pitch_present;
             dominant_bin_prev = dominant_bin_index;
        end
    end

endmodule