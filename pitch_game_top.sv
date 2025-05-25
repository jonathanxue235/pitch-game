module pitch_game_top (
    input logic clk,
	 input logic mic_clk,
    input logic resetNot,
	 
    input logic start_button_not,


     // output horizontal and vertical counters for communication with graphics module
	//output logic [9:0] xpos,
	//output logic [9:0] ypos,

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
	
	
	//output logic vga_clk
    
);

logic [9:0] xpos;
logic [9:0] ypos;

logic reset;
logic start_button;
assign start_button = ~start_button_not;
assign reset = ~resetNot;

logic [9:0] bird_x;
assign bird_x = 100;

logic [9:0] bird_y;

logic [9:0] pipe_x;
logic [9:0] pipe_y_top;
logic [9:0] pipe_y_bot;
logic [9:0] bird_width;
logic [9:0] bird_height;
logic [9:0] pipe_width;
logic [9:0] pipe_height;

assign bird_width = 20;
assign bird_height = 20;
assign pipe_width = 50;
assign pipe_height = 100;




logic vga_clk;
logic [11:0] mic_data;
logic mic_freq;

logic [15:0] mic_data_shift [63:0];



clock_divider mic_sample(
	// Input
    .clk(clk),
    .reset(reset),
    .divisor(50000),

    // Output
    .clk_out(mic_freq)
);


logic [15:0] fft_out [63:0];

get_height get_height_inst (
    // Input
    .clk(clk),
	 .mic_clk(mic_clk),
    .reset(reset),
    //.mic_data(mic_data),

    // Output
    .height(bird_y),
	 //.fft_out(fft_out),
	 .mic_data_shift(mic_data_shift)
);

//assign bird_y = 100;

logic collided;
logic position_reset;

logic enable;
position position_inst (
    // Input
    .clk(enable),
    .reset(reset),
    .start_button(start_button),
    .bird_y(bird_y),
    .collided(collided),
	 .enable(enable),

    // Output
    .pipe_x(pipe_x),
    .pipe_y_top(pipe_y_top),
    .pipe_y_bot(pipe_y_bot),
	 .led1(led1),
	 .led2(led2),
	 .led3(led3)
);

collision collision_inst (
    // Input
    .bird_x(bird_x),
    .bird_y(bird_y),
    .bird_width(bird_width),
    .bird_height(bird_height),
    .pipe_x(pipe_x),
    .pipe_width(pipe_width),
	 .pipe_height(pipe_height),
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
    .hc_out(xpos),
    .vc_out(ypos),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue)
);


clock_divider game_clock_divider (
    .clk(clk),
    .reset(reset),
    .divisor(10000000), // Change it to 10000000 when actually running, keep as 2 for tb
    .clk_out(enable)
);

logic [7:0] fft_vol [63:0];
always_comb begin
	for (int i = 0; i < 64; i++) begin
		fft_vol[i] = fft_out[i] >> 8;
	end
end

logic [7:0] mic_vol [63:0];
always_comb begin
	for (int i = 0; i < 64; i++) begin
		mic_vol[i] = mic_data_shift[i] >> 8;
	end
end


always_comb begin
	if (xpos < 256 && ypos >= (480 - fft_vol[xpos >> 2])) begin
		input_red = 3'b111;
		input_green = 3'b111;
		input_blue = 2'b00;
	end else if (xpos > 300 && ypos >= (480 - mic_vol[(xpos - 300) >> 2])) begin
		input_red = 3'b111;
		input_green = 3'b111;
		input_blue = 2'b00;
		
	end else begin
		input_red = 3'b000;
		input_green = 3'b000;
		input_blue = 2'b00;
	end

end

/*
always_comb begin
    if (bird_x - bird_width <= xpos && bird_x + bird_width >= xpos && bird_y - bird_height <= ypos && bird_y + bird_height >= ypos) begin
        input_red = 3'b111;
        input_green = 3'b000;
        input_blue = 2'b00;
    end
    else if (pipe_x - pipe_width <= xpos && pipe_x + pipe_width >= xpos && (pipe_y_bot <= ypos || pipe_y_top >= ypos)) begin
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
*/




endmodule