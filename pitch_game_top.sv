module pitch_game_top (
    input logic clk,
    input logic resetNot,
    input logic start_button_not,
    input logic [11:0] mic_in,


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
	
	
	//output logic vga_clk
    
);

logic reset;
logic start_button;
assign start_button = ~start_button_not;
assign reset = ~resetNot;
always_ff @(posedge enable) begin
	led <= ~led;
end

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
logic [11:0] mic_out;
logic mic_freq;


mic mic_inst (
    // Input
    .CLOCK(clk),
    .RESET(resetNot),
	 .CH0(mic_out)
);


clock_divider mic_sample(
	// Input
    .clk(clk),
    .reset(reset),
    .divisor(50000),

    // Output
    .clk_out(mic_freq)
);


		input  wire        clk,          //    clk.clk
		input  wire        reset_n,      //    rst.reset_n
		input  wire        sink_valid,   //   sink.sink_valid
		output wire        sink_ready,   //       .sink_ready
		input  wire [1:0]  sink_error,   //       .sink_error
		input  wire        sink_sop,     //       .sink_sop
		input  wire        sink_eop,     //       .sink_eop
		input  wire [11:0] sink_real,    //       .sink_real
		input  wire [11:0] sink_imag,    //       .sink_imag
		input  wire [6:0]  fftpts_in,    //       .fftpts_in
		input  wire [0:0]  inverse,      //       .inverse
		output wire        source_valid, // source.source_valid
		input  wire        source_ready, //       .source_ready
		output wire [1:0]  source_error, //       .source_error
		output wire        source_sop,   //       .source_sop
		output wire        source_eop,   //       .source_eop
		output wire [18:0] source_real,  //       .source_real
		output wire [18:0] source_imag,  //       .source_imag
		output wire [6:0]  fftpts_out    //       .fftpts_out

fft_64 mic_pitch(
	.clk(clk),
	.
	
);




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




endmodule