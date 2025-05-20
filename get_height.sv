module get_height (
    input logic clk,
	 input logic mic_clk,
    input logic reset,
    input logic [11:0] mic_data,
    output logic [9:0] height
);

logic status;
logic [31:0] fft_out [63:0];
logic start;
logic [31:0] mic_data_shift [63:0];
//logic [11:0] mic_data;
logic resetNot;
assign resetNot = ~reset;
fft fft_inst (
    // Input
    .clk(clk),
    .reset(reset),
    .start(start),
    .in(mic_data_shift),

    // Output
    .out(fft_out),
    .status(status)
);


logic [11:0] mic_data2;
logic [11:0] mic_data3;
logic [11:0] mic_data4;
logic [11:0] mic_data5;
logic [11:0] mic_data6;
logic [11:0] mic_data7;
logic [11:0] mic_data8;

/*
mic mic_inst (
    // Inputs
    .CLOCK(mic_clk),
    .RESET(reset),

    // Outputs
    .CH0(mic_data),
	 .CH1(mic_data2),
	 .CH2(mic_data3),
	 .CH3(mic_data4),
	 .CH4(mic_data5),
	 .CH5(mic_data6),
	 .CH6(mic_data7),
	 .CH7(mic_data8),
);
*/




logic [31:0] count;
logic fetch_data;
always_ff @(posedge clk) begin
    if (reset) begin
        count <= 32'd0;
        fetch_data <= 0;
    end
    else begin
        count <= count + 1;
        if (count >= 50000 - 1) begin
            count <= 32'd0;
            fetch_data <= 1;
        end
        else begin
            fetch_data <= 0;
        end
    end
end


// Shift register to store the last 64 samples

logic [7:0] num_samples;
always_ff @(posedge clk) begin
    if (reset) begin
        mic_data_shift <= '{default: 0};
        num_samples <= 9'd0;
    end else begin
        if (fetch_data) begin
				mic_data_shift[0] <= {4'b0, mic_data, 16'b0};
				mic_data_shift[63:1] <= mic_data_shift[62:0];
            if (num_samples < 8'd64) begin
                num_samples <= num_samples + 1;
                start <= 0;
            end else begin
                num_samples <= 8'd0;
                start <= 1;
            end
        end
    end
end
//logic [31:0] new_mic_data = {4'b0, mic_data, 16'b0};

logic [9:0] new_height;
logic [31:0] curr_max;
always_comb begin
    curr_max = fft_out[63];
    new_height = 10'd50;
    for (int i = 0; i < 64; i++) begin
        if (fft_out[63 - i] > curr_max) begin
            curr_max = fft_out[63 - i];
            new_height = 5 * i + 16;
        end
    end
end

logic prev_status;
always_ff @(posedge clk) begin
    if (status) begin
        prev_status <= 1;
    end
    else begin
        prev_status <= 0;
    end
end

always_ff @(posedge clk) begin
    if (status) begin
        height <= new_height;
    end
end

endmodule
