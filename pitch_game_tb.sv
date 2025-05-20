`timescale 1ns / 1ns
module pitch_game_tb (

	output logic clk,
	output logic mic_clk,
	output logic reset,
	output logic start_button,
    output logic [9:0] xpos,
    output logic [9:0] ypos,
    output logic hsync,
    output logic vsync,
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue,
	 output logic vga_clk
);
/*
    input logic clk,
	 input logic mic_clk,
    input logic resetNot,
	 
    input logic start_button_not,


     // output horizontal and vertical counters for communication with graphics module
	output logic [9:0] xpos,
	output logic [9:0] ypos,

    // VGA outputs
	output logic hsync,
	output logic vsync,
    // expects 12 bits for color
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue,
	output logic led,
	output logic led1,
	output logic led2,
	output logic led3
	*/


pitch_game_top DUT (
    // Inputs
    .clk(clk),
    .resetNot(reset),
    .start_button_not(start_button),
    .mic_clk(mic_clk),
    
    // Outputs
    .xpos(xpos),
    .ypos(ypos),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue)
);

initial begin
	clk = 1;
	mic_clk = 1;
	for (integer i = 0; i < 50; i++) begin
		#1;
		clk = 0;
		#1;
		clk = 1;
	end
	for (integer i = 0; i < 250; i++) begin
		#1;
		mic_clk = 0;
		#1;
		mic_clk = 1;
	end
end

initial begin
	
	reset = 1;
	start_button = 0;
	#2;
	reset = 0;
	#4;
	start_button = 1;
	#2;
	start_button = 0;
	#230;
	$stop;
end

endmodule