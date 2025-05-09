module clock_divider (
    input logic clk,
	input logic reset,
    input [31:0] divisor,
    
    output logic clk_out
);

logic [31:0] count;
logic [31:0] base_clock;
assign base_clock = 50000000; // 50 MHz

always_ff @(posedge clk) begin
    if (!reset) begin
        count <= 32'd0;
        clk_out <= 0;
    end
    else begin
        count <= count + 1;
        if (count >= divisor - 1) begin
            count <= 32'd0;
        end
        clk_out <= (counter < divisor / 2) ? 1'b1 : 1'b0;
    end
end


endmodule