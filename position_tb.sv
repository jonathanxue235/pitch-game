module position_tb (
	 output logic clk,
    output logic reset,
    output logic start_button,
	 output logic [9:0] bird_x,
    output logic [9:0] bird_y,
    output logic collided,
    output logic enable,

    output logic [9:0] pipe_x,
    output logic [9:0] pipe_y_top,
    output logic [9:0] pipe_y_bot,
	 output logic led1,
	 output logic led2,
	 output logic led3,
	 
	 output logic [1:0] state
);

assign bird_x = 100;
assign bird_y = 250;

collision collision_inst (
    // Input
    .bird_x(100),
    .bird_y(bird_y),
    .bird_width(20),
    .bird_height(20),
    .pipe_x(pipe_x),
    .pipe_width(50),
	 .pipe_height(50),
    .pipe_y_top(pipe_y_top),
    .pipe_y_bot(pipe_y_bot),

    // Output
    .collided(collided)
);

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
    .pipe_y_bot(pipe_y_bot),
	 .led1(led1),
	 .led2(led2),
	 .led3(led3),
	 .state(state)
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
	enable = 1;
	for (integer i = 0; i < 250; i++) begin
		#4;
		enable = 0;
		#4;
		enable = 1;
	end
end


initial begin
	$dumpfile("position_tb.vcd");	
	$dumpvars(0, position_tb);
	reset = 1;
	start_button = 0;
	#2;
	reset = 0;
	#4;
	start_button = 1;
	#2;
	start_button = 0;
	#230;
end

endmodule