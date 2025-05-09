`timescale 1ns / 1ns
module pitch_game_tb (

output logic clk,
output logic reset,
output logic start_button,
output logic [11:0] mic,
    output logic [9:0] xpos,
    output logic [9:0] ypos,
    output logic hsync,
    output logic vsync,
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue,
	 output logic vga_clk
);



pitch_game_top DUT (
    // Inputs
    .clk(clk),
    .reset(reset),
    .start_button(start_button),
    .mic(mic),
    
    // Outputs
    .xpos(xpos),
    .ypos(ypos),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue),
	 .vga_clk(vga_clk)
);

initial begin
	clk = 1;
	for (integer i = 0; i < 250; i++) begin
		#1;
		clk = 0;
		#1;
		clk = 1;
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