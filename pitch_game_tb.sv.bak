`timescale 1ns / 1ns
module pitch_game_tb (
    output logic [9:0] hc_out,
    output logic [9:0] vc_out,
    output logic hsync,
    output logic vsync,
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

logic clk;
logic reset;
logic start_button;
logic [11:0] mic;


pitch_game_top DUT (
    // Inputs
    .clk(clk),
    .reset(reset),
    .start_button(start_button),
    .mic(mic),
    
    // Outputs
    .hc_out(hc_out),
    .vc_out(vc_out),
    .hsync(hsync),
    .vsync(vsync),
    .red(red),
    .green(green),
    .blue(blue)
);

endmodule