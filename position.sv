module position # (
    parameter logic [9:0] PIPE_GAP = 100,
    parameter logic [9:0] PIPE_X_START = 640,
    parameter logic [9:0] BIRD_X = 100
)(
    input logic clk,
    input logic reset,
    input logic start_button,
    input logic [9:0] bird_y,
    input logic collided,
	 input logic enable,

    output logic [9:0] pipe_x,
    output logic [9:0] pipe_y_top,
    output logic [9:0] pipe_y_bot,
	 output logic led1,
	 output logic led2,
	 output logic led3,
	 
	 
	 
	 output logic [1:0] state
);

logic [9:0] pipe_y_start;

prng pipe_y_height (
    .clk(clk),
    .reset(reset),
    .prng_out(pipe_y_start)
);

// State machine
localparam logic [1:0] STATE_IDLE = 2'b00;
localparam logic [1:0] STATE_PLAY = 2'b01;
localparam logic [1:0] STATE_GAME_OVER = 2'b10;

//logic [1:0] state;
logic [1:0] next_state;

logic [9:0] pipe_y;
logic [9:0] pipe_y_next;
logic [9:0] pipe_x_next;

assign led1 = (state == STATE_IDLE);
assign led2 = (state == STATE_PLAY);
assign led3 = (state == STATE_GAME_OVER);


always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= STATE_IDLE;
    end
    else begin
		  state <= next_state;
    end
end
assign pipe_y_bot = pipe_y + PIPE_GAP;
assign pipe_y_top = pipe_y - PIPE_GAP;


always_ff @(posedge enable or posedge reset) begin // TODO: Make synchronous
    if (reset) begin
        pipe_x <= PIPE_X_START;
        pipe_y <= pipe_y_start;
    end else begin
        pipe_x <= pipe_x_next;
        pipe_y <= pipe_y_next;
    end

end


always_comb begin
    case (state)
        STATE_IDLE: begin
            if (start_button) begin
                next_state = STATE_PLAY;
            end else begin
					next_state = STATE_IDLE;
				end
            pipe_x_next = PIPE_X_START;
            pipe_y_next = pipe_y_start;
        end
        STATE_PLAY: begin
            if (collided) begin
                next_state = STATE_GAME_OVER;
            end else begin
                next_state = STATE_PLAY;
            end
            pipe_x_next = pipe_x - 10'd20;
            pipe_y_next = pipe_y;
        end
        STATE_GAME_OVER: begin
            if (reset) begin
                next_state = STATE_IDLE;
            end else begin
						next_state = STATE_GAME_OVER;
				end
				pipe_x_next = pipe_x;
				pipe_y_next = pipe_y;
        end
        default: begin
				pipe_x_next = pipe_x;
				pipe_y_next = pipe_y;
				next_state = STATE_IDLE;
		  end
    endcase
end
endmodule