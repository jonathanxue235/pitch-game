module butterfly #(parameter WIDTH=32) (
	input logic signed [WIDTH-1:0] A,
	input logic signed [WIDTH-1:0] B,
	input logic signed [WIDTH-1:0] W,
	output logic signed [WIDTH-1:0] out0,
	output logic signed [WIDTH-1:0] out1
);

	 localparam HALF = WIDTH/2;
    
    
    logic signed [HALF-1:0] A_r, A_i;
    logic signed [HALF-1:0] B_r, B_i;
    logic signed [HALF-1:0] W_r, W_i;
    
    assign A_r = A[WIDTH-1:HALF];
    assign A_i = A[HALF-1:0];
    
	 
	 assign B_r = B[WIDTH-1:HALF];
    assign B_i = B[HALF-1:0];
	 
	 
    assign W_r = W[WIDTH-1:HALF];
    assign W_i = W[HALF-1:0];

    logic signed [2*HALF-1:0] mult_r;
    logic signed [2*HALF-1:0] mult_i;
    
    assign mult_r = (W_r * B_r) - (W_i * B_i);
    assign mult_i = (W_i * B_r) + (W_r * B_i);
	 
    logic signed [HALF-1:0] BW_r;
    logic signed [HALF-1:0] BW_i;
    
    assign BW_r = mult_r[2*HALF-2:HALF-1];
    assign BW_i = mult_i[2*HALF-2:HALF-1];
	 
	 
    assign out0 = {
        A_r + BW_r,
        A_i + BW_i 
    };
    
    assign out1 = {
        A_r - BW_r,
        A_i - BW_i 
    };

endmodule