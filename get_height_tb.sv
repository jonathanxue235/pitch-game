
`timescale 1ns / 1ns
module get_height_tb (
    // DUT Inputs
    output logic clk,
	 output logic mic_clk,
    output logic reset,
    output logic [11:0] mic_data
	 //output logic [15:0] mic_data_shift[63:0]
    // DUT Outputs
	 //output logic [9:0] height_history [15:0],
	 //output logic [13:0] sum_of_heights,
    //output logic [9:0] height
);


wire [15:0] mic_data_shift[63:0];
// Instantiate the Device Under Test (DUT)
get_height DUT (
    .clk(clk),
	 .mic_clk(mic_clk),
    .reset(reset),
    .mic_data(mic_data),
	 .mic_data_shift(mic_data_shift)
);


// Clock generation
initial begin
    clk = 1;
	 mic_clk = 1;
    // Run for a certain number of clock cycles, e.g., 50000 cycles for one FFT round plus some margin
    // Each cycle is 2ns (1ns high, 1ns low)
    // Let's run for 100000 ns for now, which is 50000 cycles
    for (integer i = 0; i < 500; i++) begin
        #1;
        clk = 0;
		  mic_clk = 0;
        #1;
        clk = 1;
		  mic_clk = 1;
    end
end

// Stimulus
initial begin
    // Initialize Inputs
    reset = 1;
    mic_data = 12'd0;

    // Apply reset
    #2;
    reset = 1;
	 #2;
	 reset = 0;

    // Wait for a few cycles after reset
    #10;

    // Provide some mic data
    // The get_height module takes 64 samples before starting FFT
    // The internal counter in get_height for fetch_data is ~50000 clock cycles.
    // We will simulate a few data points. A more thorough testbench would mock the mic input precisely.
    for (integer i = 0; i < 250; i++) begin // Provide 100 data samples
        mic_data = i; // Random 12-bit data
        #2; // Hold data for one clock cycle (posedge to posedge)
    end

    // Let simulation run for a bit longer to observe height output
  #200; // Should be enough for at least one FFT computation and height update

end

endmodule 