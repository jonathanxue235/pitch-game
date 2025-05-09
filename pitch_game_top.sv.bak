module pitch_game_top (
    input logic clk,
    input logic reset,
    input logic start_button,
    input logic [11:0] mic,


     // output horizontal and vertical counters for communication with graphics module
	output logic [9:0] hc_out,
	output logic [9:0] vc_out,

    // VGA outputs
	output logic hsync,
	output logic vsync,
    // expects 12 bits for color
	output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue
    
);

logic [9:0] bird_x;
assign bird_x = 100;

logic [9:0] bird_y;

microphone mic_inst (
    // Input
    .clk(clk),
    .reset(reset),
    .mic(mic),

    // Output
    .mic_out(bird_y)
);

logic collided;
logic position_reset;


position position_inst (
    // Input
    .clk(clk),
    .reset(reset),
    .start_button(start_button),
    .bird_y(bird_y),
    .collided(collided),
    .enable(enable),

    // Output
    .pipe_x(pipe_x),
    .pipe_y_top(pipe_y_top),
    .pipe_y_bot(pipe_y_bot)
);

collision collision_inst (
    // Input
    .clk(clk),
    .reset(reset),
    .bird_x(bird_x),
    .bird_y(bird_y),
    .bird_width(bird_width),
    .bird_height(bird_height),
    .pipe_x(pipe_x),
    .pipe_width(pipe_width),
    .pipe_y_top(pipe_y_top),
    .pipe_y_bot(pipe_y_bot),

    // Output
    .collided(collided)
);

clock_divider vga_clock_divider (
    // Input
    .clk(clk),
    .reset(reset),
    .divisor(2),

    // Output
    .clk_out(vga_clk)
);


logic [2:0] input_red;
logic [2:0] input_green;
logic [1:0] input_blue;

vga vga_inst (
    // Input
    .vgaclk(vga_clk),
    .rst(reset),
    .input_red(input_red),
    .input_green(input_green),
    .input_blue(input_blue),
    
    // Output
    .hc_out(hc_out),
    .vc_out(vc_out),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue)
);


clock_divider game_clock_divider (
    .clk(clk),
    .reset(reset),
    .divisor(2), // Change it to 10000000 when actually running, keep as 2 for tb
    .clk_out(game_clk)
);


always_comb begin
    if (bird_x - 20 <= xpos && xpos >= bird_x + 20 && bird_y - 20 <= ypos && bird_y + 20 >= ypos) begin
        input_red = 3'b111;
        input_green = 3'b000;
        input_blue = 2'b00;
    end
    else if (pipe_x - 50 <= xpos && xpos >= pipe_x + 50 && (pipe_y_bot >= ypos || pipe_y_top <= ypos)) begin
        input_red = 3'b000;
        input_green = 3'b111;
        input_blue = 2'b00;
    end
    else begin
        input_red = 3'b111;
        input_green = 3'b111;
        input_blue = 2'b11;
    end
end




endmodule