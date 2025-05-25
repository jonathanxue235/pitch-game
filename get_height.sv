module get_height (
    input logic clk,
	 input logic mic_clk,
    input logic reset,
    input logic [11:0] mic_data,
	 //output logic [15:0] mic_data_shift [63:0],
    
	 //output logic [9:0] height_history [15:0],
	 //output logic [13:0] sum_of_heights,
	 //output logic [9:0] height,
	 //output logic [15:0] fft_out [63:0],
	 output logic [15:0] mic_data_shift [63:0]
);

logic [9:0] height_history [15:0];
logic [14:0] sum_of_heights;


//logic [11:0] mic_data;

logic [15:0] fft_out [63:0];
logic [9:0] height;


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
	 .CH7(mic_data8)
);
*/



logic status;
//logic [15:0] fft_out [63:0];
logic start;
//logic [31:0] mic_data_shift [63:0];
//logic [15:0] mic_data_shift [63:0];

logic resetNot;
assign resetNot = ~reset;
fft_16 fft_inst (
    // Input
    .clk(clk),
    .reset(reset),
    .start(start),
    .in(mic_data_shift),

    // Output
    .out(fft_out),
    .status(status)
);

/*
clock_divider mic_sampler(
	.clk(clk),
	.reset(reset),
	.divisor(50000),
	.clk_out(fetch_data)
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
				//mic_data_shift[0] <= {4'b0, mic_data, 16'b0};
				mic_data_shift[0] <= {1'b0, mic_data[11:5], 8'b0};
				for (int i = 1; i < 64; i++) begin
					mic_data_shift[i] <= mic_data_shift[i-1];
				
				end
				//mic_data_shift[63:1] <= mic_data_shift[62:0];
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
    curr_max = fft_out[0];
    new_height = 10'd100;
    for (int i = 1; i < 32; i++) begin
        if (fft_out[i] > curr_max) begin
            curr_max = fft_out[i];
            new_height = 9 * i + 100;
        end
    end
end



logic prev_status;
always_ff @(posedge clk) begin
    if (reset) begin
        prev_status <= 0;
    end else begin
        prev_status <= status;
    end
end

/*
always_ff @(posedge status or posedge reset) begin
    if (reset) begin
        height_history <= '{default: 0};
        sum_of_heights <= 0;
        height <= 0;
    end else begin
        sum_of_heights <= sum_of_heights - height_history[15] + new_height;
		  height_history[0] <= new_height;
		  height_history[1] <= height_history[0];
		  height_history[2] <= height_history[1];
		  height_history[3] <= height_history[2];
		  height_history[4] <= height_history[3];
		  height_history[5] <= height_history[4];
		  height_history[6] <= height_history[5];
		  height_history[7] <= height_history[6];
		  height_history[8] <= height_history[7];
		  height_history[9] <= height_history[8];
		  height_history[10] <= height_history[9];
		  height_history[11] <= height_history[10];
		  height_history[12] <= height_history[11];
		  height_history[13] <= height_history[12];
		  height_history[14] <= height_history[13];
		  height_history[15] <= height_history[14];
        height <= sum_of_heights >> 4;
    end
end
*/


always_ff @(posedge clk) begin
	if (reset) begin
		height <= 0;
	end else begin
		height <= new_height;
	end
end



endmodule
