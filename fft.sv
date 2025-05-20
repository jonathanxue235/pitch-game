/**
*
* TODO: This could be implemented better and more cleanly
*/
module fft (
    input clk,
    input reset,
    input start,

    // 64 complex inputs (Real and Imaginary parts)
    input logic [31:0] in [63:0],

    // 64 complex outputs
    output logic [31:0] out [63:0],
    output logic status
);

/*
always_comb begin
	for (int i = 0; i < 64; i++) begin
		out[i] = in[i];
	end
end
assign status = start;
*/


logic [31:0] f_a [31:0];
logic [31:0] f_b [31:0];
logic [31:0] f_w [31:0];
logic [31:0] f_out0 [31:0];
logic [31:0] f_out1 [31:0];

logic [31:0] in_reorder [63:0];
/*
always_ff @(posedge clk) begin
	if (start) begin
    in_reorder[0] <= in[0];
    in_reorder[1] <= in[32];
    in_reorder[2] <= in[16];
    in_reorder[3] <= in[48];
    in_reorder[4] <= in[8];
    in_reorder[5] <= in[40];
    in_reorder[6] <= in[24];
    in_reorder[7] <= in[56];
    in_reorder[8] <= in[4];
    in_reorder[9] <= in[36];
    in_reorder[10] <= in[20];
    in_reorder[11] <= in[52];
    in_reorder[12] <= in[12];
    in_reorder[13] <= in[44];
    in_reorder[14] <= in[28];
    in_reorder[15] <= in[60];
    in_reorder[16] <= in[2];
    in_reorder[17] <= in[34];
    in_reorder[18] <= in[18];
    in_reorder[19] <= in[50];
    in_reorder[20] <= in[10];
    in_reorder[21] <= in[42];
    in_reorder[22] <= in[26];
    in_reorder[23] <= in[58];
    in_reorder[24] <= in[6];
    in_reorder[25] <= in[38];
    in_reorder[26] <= in[22];
    in_reorder[27] <= in[54];
    in_reorder[28] <= in[14];
    in_reorder[29] <= in[46];
    in_reorder[30] <= in[30];
    in_reorder[31] <= in[62];
    in_reorder[32] <= in[1];
    in_reorder[33] <= in[33];
    in_reorder[34] <= in[17];
    in_reorder[35] <= in[49];
    in_reorder[36] <= in[9];
    in_reorder[37] <= in[41];
    in_reorder[38] <= in[25];
    in_reorder[39] <= in[57];
    in_reorder[40] <= in[5];
    in_reorder[41] <= in[37];
    in_reorder[42] <= in[21];
    in_reorder[43] <= in[53];
    in_reorder[44] <= in[13];
    in_reorder[45] <= in[45];
    in_reorder[46] <= in[29];
    in_reorder[47] <= in[61];
    in_reorder[48] <= in[3];
    in_reorder[49] <= in[35];
    in_reorder[50] <= in[19];
    in_reorder[51] <= in[51];
    in_reorder[52] <= in[11];
    in_reorder[53] <= in[43];
    in_reorder[54] <= in[27];
    in_reorder[55] <= in[59];
    in_reorder[56] <= in[7];
    in_reorder[57] <= in[39];
    in_reorder[58] <= in[23];
    in_reorder[59] <= in[55];
    in_reorder[60] <= in[15];
    in_reorder[61] <= in[47];
    in_reorder[62] <= in[31];
    in_reorder[63] <= in[63];
	 end
end
*/

butterfly fft0(.A(f_a[0]), .B(f_b[0]), .W(f_w[0]), .out0(f_out0[0]), .out1(f_out1[0]));
butterfly fft1(.A(f_a[1]), .B(f_b[1]), .W(f_w[1]), .out0(f_out0[1]), .out1(f_out1[1]));
butterfly fft2(.A(f_a[2]), .B(f_b[2]), .W(f_w[2]), .out0(f_out0[2]), .out1(f_out1[2]));
butterfly fft3(.A(f_a[3]), .B(f_b[3]), .W(f_w[3]), .out0(f_out0[3]), .out1(f_out1[3]));
butterfly fft4(.A(f_a[4]), .B(f_b[4]), .W(f_w[4]), .out0(f_out0[4]), .out1(f_out1[4]));
butterfly fft5(.A(f_a[5]), .B(f_b[5]), .W(f_w[5]), .out0(f_out0[5]), .out1(f_out1[5]));
butterfly fft6(.A(f_a[6]), .B(f_b[6]), .W(f_w[6]), .out0(f_out0[6]), .out1(f_out1[6]));
butterfly fft7(.A(f_a[7]), .B(f_b[7]), .W(f_w[7]), .out0(f_out0[7]), .out1(f_out1[7]));
butterfly fft8(.A(f_a[8]), .B(f_b[8]), .W(f_w[8]), .out0(f_out0[8]), .out1(f_out1[8]));
butterfly fft9(.A(f_a[9]), .B(f_b[9]), .W(f_w[9]), .out0(f_out0[9]), .out1(f_out1[9]));
butterfly fft10(.A(f_a[10]), .B(f_b[10]), .W(f_w[10]), .out0(f_out0[10]), .out1(f_out1[10]));
butterfly fft11(.A(f_a[11]), .B(f_b[11]), .W(f_w[11]), .out0(f_out0[11]), .out1(f_out1[11]));
butterfly fft12(.A(f_a[12]), .B(f_b[12]), .W(f_w[12]), .out0(f_out0[12]), .out1(f_out1[12]));
butterfly fft13(.A(f_a[13]), .B(f_b[13]), .W(f_w[13]), .out0(f_out0[13]), .out1(f_out1[13]));
butterfly fft14(.A(f_a[14]), .B(f_b[14]), .W(f_w[14]), .out0(f_out0[14]), .out1(f_out1[14]));
butterfly fft15(.A(f_a[15]), .B(f_b[15]), .W(f_w[15]), .out0(f_out0[15]), .out1(f_out1[15]));
butterfly fft16(.A(f_a[16]), .B(f_b[16]), .W(f_w[16]), .out0(f_out0[16]), .out1(f_out1[16]));
butterfly fft17(.A(f_a[17]), .B(f_b[17]), .W(f_w[17]), .out0(f_out0[17]), .out1(f_out1[17]));
butterfly fft18(.A(f_a[18]), .B(f_b[18]), .W(f_w[18]), .out0(f_out0[18]), .out1(f_out1[18]));
butterfly fft19(.A(f_a[19]), .B(f_b[19]), .W(f_w[19]), .out0(f_out0[19]), .out1(f_out1[19]));
butterfly fft20(.A(f_a[20]), .B(f_b[20]), .W(f_w[20]), .out0(f_out0[20]), .out1(f_out1[20]));
butterfly fft21(.A(f_a[21]), .B(f_b[21]), .W(f_w[21]), .out0(f_out0[21]), .out1(f_out1[21]));
butterfly fft22(.A(f_a[22]), .B(f_b[22]), .W(f_w[22]), .out0(f_out0[22]), .out1(f_out1[22]));
butterfly fft23(.A(f_a[23]), .B(f_b[23]), .W(f_w[23]), .out0(f_out0[23]), .out1(f_out1[23]));
butterfly fft24(.A(f_a[24]), .B(f_b[24]), .W(f_w[24]), .out0(f_out0[24]), .out1(f_out1[24]));
butterfly fft25(.A(f_a[25]), .B(f_b[25]), .W(f_w[25]), .out0(f_out0[25]), .out1(f_out1[25]));
butterfly fft26(.A(f_a[26]), .B(f_b[26]), .W(f_w[26]), .out0(f_out0[26]), .out1(f_out1[26]));
butterfly fft27(.A(f_a[27]), .B(f_b[27]), .W(f_w[27]), .out0(f_out0[27]), .out1(f_out1[27]));
butterfly fft28(.A(f_a[28]), .B(f_b[28]), .W(f_w[28]), .out0(f_out0[28]), .out1(f_out1[28]));
butterfly fft29(.A(f_a[29]), .B(f_b[29]), .W(f_w[29]), .out0(f_out0[29]), .out1(f_out1[29]));
butterfly fft30(.A(f_a[30]), .B(f_b[30]), .W(f_w[30]), .out0(f_out0[30]), .out1(f_out1[30]));
butterfly fft31(.A(f_a[31]), .B(f_b[31]), .W(f_w[31]), .out0(f_out0[31]), .out1(f_out1[31]));

/*
logic [31:0] w_64 [31:0];

initial begin
    w_64[0] = {16'sb0111111111111111, 16'sb0000000000000000}; // R: 32767 (orig: 1), I: 0 (orig: 0)
    w_64[1] = {16'sb0111111101100010, 16'sb1111001101110100}; // R: 32610 (orig: cos(pi/32)), I: -3212 (orig: -sin(pi/32))
    w_64[2] = {16'sb0111110110011011, 16'sb1110100100000111}; // R: 32139 (orig: cos(pi/16)), I: -6393 (orig: -sin(pi/16))
    w_64[3] = {16'sb0111101001111101, 16'sb1101101011001000}; // R: 31357 (orig: cos(3*pi/32)), I: -9512 (orig: -sin(3*pi/32))
    w_64[4] = {16'sb0111011001000001, 16'sb1100111000000001}; // R: 30273 (orig: cos(pi/8)), I: -12543 (orig: -sin(pi/8))
    w_64[5] = {16'sb0111000011100011, 16'sb1100001110011000}; // R: 28899 (orig: cos(5*pi/32)), I: -15464 (orig: -sin(5*pi/32))
    w_64[6] = {16'sb0110101001101101, 16'sb1011100011100100}; // R: 27245 (orig: cos(3*pi/16)), I: -18204 (orig: -sin(3*pi/16))
    w_64[7] = {16'sb0110001011110010, 16'sb1010110111001100}; // R: 25330 (orig: cos(7*pi/32)), I: -20788 (orig: -sin(7*pi/32))
    w_64[8] = {16'sb0101101010000010, 16'sb1010010101111110}; // R: 23170 (orig: sqrt(2)/2), I: -23170 (orig: -sqrt(2)/2)
    w_64[9] = {16'sb0101000100110100, 16'sb1001110100001110}; // R: 20788 (orig: cos(9*pi/32)), I: -25330 (orig: -sin(9*pi/32))
    w_64[10] = {16'sb0100011100011100, 16'sb1001010110010011}; // R: 18204 (orig: cos(5*pi/16)), I: -27245 (orig: -sin(5*pi/16))
    w_64[11] = {16'sb0011110001101000, 16'sb1000111100011101}; // R: 15464 (orig: cos(11*pi/32)), I: -28899 (orig: -sin(11*pi/32))
    w_64[12] = {16'sb0011000011111111, 16'sb1000100110111111}; // R: 12543 (orig: cos(3*pi/8)), I: -30273 (orig: -sin(3*pi/8))
    w_64[13] = {16'sb0010010100101000, 16'sb1000010110000011}; // R: 9512 (orig: cos(13*pi/32)), I: -31357 (orig: -sin(13*pi/32))
    w_64[14] = {16'sb0001100011111001, 16'sb1000001001110101}; // R: 6393 (orig: cos(7*pi/16)), I: -32139 (orig: -sin(7*pi/16))
    w_64[15] = {16'sb0000110010001100, 16'sb1111111010011110}; // R: 3212 (orig: cos(15*pi/32)), I: -32610 (orig: -sin(15*pi/32))
    w_64[16] = {16'sb0000000000000000, 16'sb1000000000000000}; // R: 0 (orig: 0), I: -32768 (orig: -1)
    w_64[17] = {16'sb1111001101110100, 16'sb1111111010011110}; // R: -3212 (orig: cos(17*pi/32)), I: -32610 (orig: -sin(17*pi/32))
    w_64[18] = {16'sb1110100100000111, 16'sb1000001001110101}; // R: -6393 (orig: cos(9*pi/16)), I: -32139 (orig: -sin(9*pi/16))
    w_64[19] = {16'sb1101101011001000, 16'sb1000010110000011}; // R: -9512 (orig: cos(19*pi/32)), I: -31357 (orig: -sin(19*pi/32))
    w_64[20] = {16'sb1100111000000001, 16'sb1000100110111111}; // R: -12543 (orig: cos(5*pi/8)), I: -30273 (orig: -sin(5*pi/8))
    w_64[21] = {16'sb1100001110011000, 16'sb1000111100011101}; // R: -15464 (orig: cos(21*pi/32)), I: -28899 (orig: -sin(21*pi/32))
    w_64[22] = {16'sb1011100011100100, 16'sb1001010110010011}; // R: -18204 (orig: cos(11*pi/16)), I: -27245 (orig: -sin(11*pi/16))
    w_64[23] = {16'sb1010110111001100, 16'sb1001110100001110}; // R: -20788 (orig: cos(23*pi/32)), I: -25330 (orig: -sin(23*pi/32))
    w_64[24] = {16'sb1010010101111110, 16'sb1010010101111110}; // R: -23170 (orig: -sqrt(2)/2), I: -23170 (orig: -sqrt(2)/2)
    w_64[25] = {16'sb1001110100001110, 16'sb1010110111001100}; // R: -25330 (orig: cos(25*pi/32)), I: -20788 (orig: -sin(25*pi/32))
    w_64[26] = {16'sb1001010110010011, 16'sb1011100011100100}; // R: -27245 (orig: cos(13*pi/16)), I: -18204 (orig: -sin(13*pi/16))
    w_64[27] = {16'sb1000111100011101, 16'sb1100001110011000}; // R: -28899 (orig: cos(27*pi/32)), I: -15464 (orig: -sin(27*pi/32))
    w_64[28] = {16'sb1000100110111111, 16'sb1100111000000001}; // R: -30273 (orig: cos(7*pi/8)), I: -12543 (orig: -sin(7*pi/8))
    w_64[29] = {16'sb1000010110000011, 16'sb1101101011001000}; // R: -31357 (orig: cos(29*pi/32)), I: -9512 (orig: -sin(29*pi/32))
    w_64[30] = {16'sb1000001001110101, 16'sb1110100100000111}; // R: -32139 (orig: cos(15*pi/16)), I: -6393 (orig: -sin(15*pi/16))
    w_64[31] = {16'sb1111111010011110, 16'sb1111001101110100}; // R: -32610 (orig: cos(31*pi/32)), I: -3212 (orig: -sin(31*pi/32))
end
*/
parameter logic [31:0] w_64 [0:31] = '{ // Array literal assignment
    {16'sh7FFF, 16'sh0000}, // w_64[0]:  R: 32767 (1.0), I: 0
    {16'sh7F62, 16'shF374}, // w_64[1]:  R: 32610, I: -3212
    {16'sh7D9B, 16'shE907}, // w_64[2]:  R: 32139, I: -6393
    {16'sh7A7D, 16'shDAC8}, // w_64[3]:  R: 31357, I: -9512
    {16'sh7641, 16'shCE01}, // w_64[4]:  R: 30273, I: -12543
    {16'sh70E3, 16'shC398}, // w_64[5]:  R: 28899, I: -15464
    {16'sh6A6D, 16'shB8E4}, // w_64[6]:  R: 27245, I: -18204
    {16'sh62F2, 16'shADCC}, // w_64[7]:  R: 25330, I: -20788
    {16'sh5A82, 16'shA57E}, // w_64[8]:  R: 23170, I: -23170 (sqrt(2)/2)
    {16'sh5134, 16'sh9D0E}, // w_64[9]:  R: 20788, I: -25330
    {16'sh471C, 16'sh9593}, // w_64[10]: R: 18204, I: -27245
    {16'sh3C68, 16'sh8F1D}, // w_64[11]: R: 15464, I: -28899
    {16'sh30FF, 16'sh89BF}, // w_64[12]: R: 12543, I: -30273
    {16'sh2528, 16'sh8583}, // w_64[13]: R: 9512,  I: -31357
    {16'sh18F9, 16'sh8275}, // w_64[14]: R: 6393,  I: -32139
    {16'sh0C8C, 16'shFE9E}, // w_64[15]: R: 3212,  I: -32610
    {16'sh0000, 16'sh8000}, // w_64[16]: R: 0,     I: -32768 (-1.0)
    {16'shF374, 16'shFE9E}, // w_64[17]: R: -3212, I: -32610
    {16'shE907, 16'sh8275}, // w_64[18]: R: -6393, I: -32139
    {16'shDAC8, 16'sh8583}, // w_64[19]: R: -9512, I: -31357
    {16'shCE01, 16'sh89BF}, // w_64[20]: R: -12543,I: -30273
    {16'shC398, 16'sh8F1D}, // w_64[21]: R: -15464,I: -28899
    {16'shB8E4, 16'sh9593}, // w_64[22]: R: -18204,I: -27245
    {16'shADCC, 16'sh9D0E}, // w_64[23]: R: -20788,I: -25330
    {16'shA57E, 16'shA57E}, // w_64[24]: R: -23170,I: -23170 (-sqrt(2)/2)
    {16'sh9D0E, 16'shADCC}, // w_64[25]: R: -25330,I: -20788
    {16'sh9593, 16'shB8E4}, // w_64[26]: R: -27245,I: -18204
    {16'sh8F1D, 16'shC398}, // w_64[27]: R: -28899,I: -15464
    {16'sh89BF, 16'shCE01}, // w_64[28]: R: -30273,I: -12543
    {16'sh8583, 16'shDAC8}, // w_64[29]: R: -31357,I: -9512
    {16'sh8275, 16'shE907}, // w_64[30]: R: -32139,I: -6393
    {16'shFE9E, 16'shF374}  // w_64[31]: R: -32610,I: -3212
};
typedef enum logic [2:0] {RESET, STAGE1, STAGE2, STAGE3, STAGE4, STAGE5, STAGE6, DONE} State;

State curr, next;

function [5:0] bit_reversal (input [5:0] in_val);

	bit_reversal[0] = in_val[5];
	bit_reversal[1] = in_val[4];
	bit_reversal[2] = in_val[3];
	bit_reversal[3] = in_val[2];
	bit_reversal[4] = in_val[1];
	bit_reversal[5] = in_val[0];
	
endfunction
always_ff @(posedge clk) begin
    if (reset)
        curr <= RESET;
    else
        curr <= next;
    
	case (curr)
		RESET: begin
            for (int i = 0; i < 32; i++) begin
                f_a[i] <= 0;
                f_b[i] <= 0;
                f_w[i] <= 0;
            end
            for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
            status <= 0;
		end
		STAGE1: begin
            for (int i = 0; i < 32; i++) begin
					 
                f_a[i] <= in[bit_reversal(2 * i)];
                f_b[i] <= in[2 * i + 1];
                f_w[i] <= w_64[0];
            end
            for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
			status <= 0;
		end
		STAGE2: begin
			for (int i = 0; i < 16; i++) begin
                f_a[2 * i] <= f_out0[i];
                f_b[2 * i] <= f_out0[i + 1];
                f_w[2 * i] <= w_64[0];

                f_a[2 * i + 1] <= f_out1[i];
                f_b[2 * i + 1] <= f_out1[i + 1];
                f_w[2 * i + 1] <= w_64[16];
            end
            for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
			status <= 0;
		end
		STAGE3: begin
            for (int i = 0; i < 8; i++) begin
                f_a[4 * i] <= f_out0[i];
                f_b[4 * i] <= f_out0[i + 2];
                f_w[4 * i] <= w_64[0];

                f_a[4 * i + 1] <= f_out0[i + 1];
                f_b[4 * i + 1] <= f_out0[i + 3];
                f_w[4 * i + 1] <= w_64[8];

                f_a[4 * i + 2] <= f_out1[i];
                f_b[4 * i + 2] <= f_out1[i + 2];
                f_w[4 * i + 2] <= w_64[16];

                f_a[4 * i + 3] <= f_out1[i + 1];
                f_b[4 * i + 3] <= f_out1[i + 3];
                f_w[4 * i + 3] <= w_64[24];
            end
			for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
			status <= 0;
		end
		STAGE4: begin
            for (int i = 0; i < 4; i++) begin
                f_a[8 * i] <= f_out0[i];
                f_b[8 * i] <= f_out0[i + 4];
                f_w[8 * i] <= w_64[0];

                f_a[8 * i + 1] <= f_out0[i + 1];
                f_b[8 * i + 1] <= f_out0[i + 5];
                f_w[8 * i + 1] <= w_64[4];

                f_a[8 * i + 2] <= f_out0[i + 2];
                f_b[8 * i + 2] <= f_out0[i + 6];
                f_w[8 * i + 2] <= w_64[8];

                f_a[8 * i + 3] <= f_out0[i + 3];
                f_b[8 * i + 3] <= f_out0[i + 7];
                f_w[8 * i + 3] <= w_64[12];

                f_a[8 * i + 4] <= f_out1[i];
                f_b[8 * i + 4] <= f_out1[i + 4];
                f_w[8 * i + 4] <= w_64[16];

                f_a[8 * i + 5] <= f_out1[i + 1];
                f_b[8 * i + 5] <= f_out1[i + 5];
                f_w[8 * i + 5] <= w_64[20];

                f_a[8 * i + 6] <= f_out1[i + 2];
                f_b[8 * i + 6] <= f_out1[i + 6];
                f_w[8 * i + 6] <= w_64[24];

                f_a[8 * i + 7] <= f_out1[i + 3];
                f_b[8 * i + 7] <= f_out1[i + 7];
                f_w[8 * i + 7] <= w_64[28];
            end
			for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
			status <= 0;
		end
		STAGE5: begin
            for (int i = 0; i < 2; i++) begin
                f_a[16 * i] <= f_out0[i];
                f_b[16 * i] <= f_out0[i + 8];
                f_w[16 * i] <= w_64[0];

                f_a[16 * i + 1] <= f_out0[i + 1];
                f_b[16 * i + 1] <= f_out0[i + 9];
                f_w[16 * i + 1] <= w_64[2];

                f_a[16 * i + 2] <= f_out0[i + 2];
                f_b[16 * i + 2] <= f_out0[i + 10];
                f_w[16 * i + 2] <= w_64[4];

                f_a[16 * i + 3] <= f_out0[i + 3];
                f_b[16 * i + 3] <= f_out0[i + 11];
                f_w[16 * i + 3] <= w_64[6];

                f_a[16 * i + 4] <= f_out0[i + 4];
                f_b[16 * i + 4] <= f_out0[i + 12];
                f_w[16 * i + 4] <= w_64[8];

                f_a[16 * i + 5] <= f_out0[i + 5];
                f_b[16 * i + 5] <= f_out0[i + 13];
                f_w[16 * i + 5] <= w_64[10];

                f_a[16 * i + 6] <= f_out0[i + 6];
                f_b[16 * i + 6] <= f_out0[i + 14];
                f_w[16 * i + 6] <= w_64[12];

                f_a[16 * i + 7] <= f_out0[i + 7];
                f_b[16 * i + 7] <= f_out0[i + 15];
                f_w[16 * i + 7] <= w_64[14];

                f_a[16 * i + 8] <= f_out1[i];
                f_b[16 * i + 8] <= f_out1[i + 8];
                f_w[16 * i + 8] <= w_64[16];

                f_a[16 * i + 9] <= f_out1[i + 1];
                f_b[16 * i + 9] <= f_out1[i + 9];
                f_w[16 * i + 9] <= w_64[18];

                f_a[16 * i + 10] <= f_out1[i + 2];
                f_b[16 * i + 10] <= f_out1[i + 10];
                f_w[16 * i + 10] <= w_64[20];

                f_a[16 * i + 11] <= f_out1[i + 3];
                f_b[16 * i + 11] <= f_out1[i + 11];
                f_w[16 * i + 11] <= w_64[22];

                f_a[16 * i + 12] <= f_out1[i + 4];
                f_b[16 * i + 12] <= f_out1[i + 12];
                f_w[16 * i + 12] <= w_64[24];

                f_a[16 * i + 13] <= f_out1[i + 5];
                f_b[16 * i + 13] <= f_out1[i + 13];
                f_w[16 * i + 13] <= w_64[26];

                f_a[16 * i + 14] <= f_out1[i + 6];
                f_b[16 * i + 14] <= f_out1[i + 14];
                f_w[16 * i + 14] <= w_64[28];

                f_a[16 * i + 15] <= f_out1[i + 7];
                f_b[16 * i + 15] <= f_out1[i + 15];
                f_w[16 * i + 15] <= w_64[30];
            end
                
			for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
			status <= 0;
		end
		STAGE6: begin
            for (int i = 0; i < 1; i++) begin
                f_a[32 * i] <= f_out0[i];
                f_b[32 * i] <= f_out0[i + 16];
                f_w[32 * i] <= w_64[0];

                f_a[32 * i + 1] <= f_out0[i + 1];
                f_b[32 * i + 1] <= f_out0[i + 17];
                f_w[32 * i + 1] <= w_64[1];

                f_a[32 * i + 2] <= f_out0[i + 2];
                f_b[32 * i + 2] <= f_out0[i + 18];
                f_w[32 * i + 2] <= w_64[2];

                f_a[32 * i + 3] <= f_out0[i + 3];
                f_b[32 * i + 3] <= f_out0[i + 19];
                f_w[32 * i + 3] <= w_64[3];

                f_a[32 * i + 4] <= f_out0[i + 4];
                f_b[32 * i + 4] <= f_out0[i + 20];
                f_w[32 * i + 4] <= w_64[4];

                f_a[32 * i + 5] <= f_out0[i + 5];
                f_b[32 * i + 5] <= f_out0[i + 21];
                f_w[32 * i + 5] <= w_64[5];

                f_a[32 * i + 6] <= f_out0[i + 6];
                f_b[32 * i + 6] <= f_out0[i + 22];
                f_w[32 * i + 6] <= w_64[6];

                f_a[32 * i + 7] <= f_out0[i + 7];
                f_b[32 * i + 7] <= f_out0[i + 23];
                f_w[32 * i + 7] <= w_64[7];

                f_a[32 * i + 8] <= f_out0[i + 8];
                f_b[32 * i + 8] <= f_out0[i + 24];
                f_w[32 * i + 8] <= w_64[8];

                f_a[32 * i + 9] <= f_out0[i + 9];
                f_b[32 * i + 9] <= f_out0[i + 25];
                f_w[32 * i + 9] <= w_64[9];

                f_a[32 * i + 10] <= f_out0[i + 10];
                f_b[32 * i + 10] <= f_out0[i + 26];
                f_w[32 * i + 10] <= w_64[10];

                f_a[32 * i + 11] <= f_out0[i + 11];
                f_b[32 * i + 11] <= f_out0[i + 27];
                f_w[32 * i + 11] <= w_64[11];

                f_a[32 * i + 12] <= f_out0[i + 12];
                f_b[32 * i + 12] <= f_out0[i + 28];
                f_w[32 * i + 12] <= w_64[12];

                f_a[32 * i + 13] <= f_out0[i + 13];
                f_b[32 * i + 13] <= f_out0[i + 29];
                f_w[32 * i + 13] <= w_64[13];

                f_a[32 * i + 14] <= f_out0[i + 14];
                f_b[32 * i + 14] <= f_out0[i + 30];
                f_w[32 * i + 14] <= w_64[14];

                f_a[32 * i + 15] <= f_out0[i + 15];
                f_b[32 * i + 15] <= f_out0[i + 31];
                f_w[32 * i + 15] <= w_64[15];

                f_a[32 * i + 16] <= f_out1[i];
                f_b[32 * i + 16] <= f_out1[i + 16];
                f_w[32 * i + 16] <= w_64[16];

                f_a[32 * i + 17] <= f_out1[i + 1];
                f_b[32 * i + 17] <= f_out1[i + 17];
                f_w[32 * i + 17] <= w_64[17];

                f_a[32 * i + 18] <= f_out1[i + 2];
                f_b[32 * i + 18] <= f_out1[i + 18];
                f_w[32 * i + 18] <= w_64[18];

                f_a[32 * i + 19] <= f_out1[i + 3];
                f_b[32 * i + 19] <= f_out1[i + 19];
                f_w[32 * i + 19] <= w_64[19];

                f_a[32 * i + 20] <= f_out1[i + 4];
                f_b[32 * i + 20] <= f_out1[i + 20];
                f_w[32 * i + 20] <= w_64[20];

                f_a[32 * i + 21] <= f_out1[i + 5];
                f_b[32 * i + 21] <= f_out1[i + 21];
                f_w[32 * i + 21] <= w_64[21];

                f_a[32 * i + 22] <= f_out1[i + 6];
                f_b[32 * i + 22] <= f_out1[i + 22];
                f_w[32 * i + 22] <= w_64[22];

                f_a[32 * i + 23] <= f_out1[i + 7];
                f_b[32 * i + 23] <= f_out1[i + 23];
                f_w[32 * i + 23] <= w_64[23];

                f_a[32 * i + 24] <= f_out1[i + 8];
                f_b[32 * i + 24] <= f_out1[i + 24];
                f_w[32 * i + 24] <= w_64[24];

                f_a[32 * i + 25] <= f_out1[i + 9];
                f_b[32 * i + 25] <= f_out1[i + 25];
                f_w[32 * i + 25] <= w_64[25];

                f_a[32 * i + 26] <= f_out1[i + 10];
                f_b[32 * i + 26] <= f_out1[i + 26];
                f_w[32 * i + 26] <= w_64[26];

                f_a[32 * i + 27] <= f_out1[i + 11];
                f_b[32 * i + 27] <= f_out1[i + 27];
                f_w[32 * i + 27] <= w_64[27];

                f_a[32 * i + 28] <= f_out1[i + 12];
                f_b[32 * i + 28] <= f_out1[i + 28];
                f_w[32 * i + 28] <= w_64[28];

                f_a[32 * i + 29] <= f_out1[i + 13];
                f_b[32 * i + 29] <= f_out1[i + 29];
                f_w[32 * i + 29] <= w_64[29];

                f_a[32 * i + 30] <= f_out1[i + 14];
                f_b[32 * i + 30] <= f_out1[i + 30];
                f_w[32 * i + 30] <= w_64[30];

                f_a[32 * i + 31] <= f_out1[i + 15];
                f_b[32 * i + 31] <= f_out1[i + 31];
                f_w[32 * i + 31] <= w_64[31];
            end

			for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
			status <= 0;
		end
		DONE: begin
            for (int i = 0; i < 32; i++) begin
                out[i] <= f_out0[i];
                out[32 + i] <= f_out1[i];
            end
			status <= 1;
		end
		default: begin
            for (int i = 0; i < 32; i++) begin
                f_a[i] <= 0;
                f_b[i] <= 0;
                f_w[i] <= 0;
            end
			for (int i = 0; i < 64; i++) begin
                out[i] <= 0;
            end
			status <= 0;

		end
	endcase
end

always_comb begin
	case(curr)
		RESET: begin
			if (start) next = STAGE1;
			else next = RESET;
		end
		STAGE1: begin
			next = STAGE2;
		end
		STAGE2: begin
			next = STAGE3;
		end
		STAGE3: begin
			next = STAGE4;
		end
		STAGE4: begin
			next = STAGE5;
		end
		STAGE5: begin
			next = STAGE6;
		end
		STAGE6: begin
			next = DONE;
		end
		DONE: begin
			if (start) next = STAGE1;
			else next = DONE;
		end
		default: begin
			next = RESET;
		end
	endcase
end



endmodule
