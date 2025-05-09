module collision (
    input logic clk,
    input logic reset,
    input logic [9:0] bird_x,
    input logic [9:0] bird_y,
    input logic [9:0] bird_width,
    input logic [9:0] bird_height,
    input logic [9:0] pipe_x,
    input logic [9:0] pipe_width,
    input logic [9:0] pipe_y_top,
    input logic [9:0] pipe_y_bot,

    output logic collided
);

logic [9:0] bird_bot;
logic [9:0] bird_top;
logic [9:0] bird_left;
logic [9:0] bird_right;

logic [9:0] pipe_bot;
logic [9:0] pipe_top;
logic [9:0] pipe_left;
logic [9:0] pipe_right;

assign bird_bot = bird_y + bird_height;
assign bird_top = bird_y - bird_height;
assign bird_left = bird_x - bird_width;
assign bird_right = bird_x + bird_width;

assign pipe_bot = pipe_y_bot + pipe_height;
assign pipe_top = pipe_y_top - pipe_height;
assign pipe_left = pipe_x - pipe_width;
assign pipe_right = pipe_x + pipe_width;

always_comb begin
    if ((bird_bot > pipe_top || bird_top < pipe_bot) && ((pipe_left < bird_right && bird_right < pipe_right) || (pipe_left < bird_left && bird_left < pipe_right))) begin
        collided = 1;
    end else begin
        collided = 0;
    end
end 

endmodule