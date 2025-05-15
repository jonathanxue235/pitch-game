module get_height (
    input logic clk,
    input logic reset,
    input logic [11:0] mic_data,
    output logic [9:0] height
);

logic status;
logic [31:0] fft_out [63:0];
logic start;

fft fft_inst (
    // Input
    .clk(clk),
    .reset(reset),
    .start(start),
    .in(mic_data),

    // Output
    .out(fft_out),
    .status(status)
);

mic mic_inst (
    // Inputs
    .CLOCK(clk),
    .RESET(~reset),

    // Outputs
    .CH0(mic_data)
);

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
logic [31:0] mic_data_shift [63:0];
logic [7:0] num_samples;
always_ff @(posedge clk) begin
    if (reset) begin
        mic_data_shift <= '{default: 0};
        num_samples <= 9'd0;
    end else begin
        if (fetch_data) begin
            mic_data_shift <= {mic_data_shift[1:63], {4'b0, mic_data, 16'b0}};
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

logic [9:0] new_height;
logic [31:0] curr_max;
always_comb begin
    curr_max = fft_out[0];
    new_height = 10'd16;
    for (int i = 0; i < 64; i++) begin
        if (fft_out[i] > curr_max) begin
            curr_max = fft_out[i];
            new_height = 7 * i + 16;
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
    if (prev_status) begin
        height <= new_height;
    end
end

endmodule
