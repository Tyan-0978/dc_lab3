// ----------------------------------------------------------------------
// interpolation calculation module
// ----------------------------------------------------------------------

module itp5 (
    input  [15:0] i_data_1,
    input  [15:0] i_data_2,
    output [15:0] o_data_1,
    output [15:0] o_data_2,
    output [15:0] o_data_3,
    output [15:0] o_data_4
);

wire [17:0] data_1x4, data_2x4;
wire [19:0] data_1x16, data_2x16;
wire [20:0] data_1x32, data_2x32;
wire [21:0] sum_1_4_16_32, sum_2_4_16_32;
wire [16:0] sum_15, sum_35, sum_25, sum_45;
wire [15:0] out_arr [0:3];

assign data_1x4 = i_data_1 << 2;
assign data_1x16 = i_data_1 << 4;
assign data_1x32 = i_data_1 << 5;
assign sum_1_4_16_32 = data_1x4 + data_1x16 + data_1x32;
assign data_2x4 = i_data_2 << 2;
assign data_2x16 = i_data_2 << 4;
assign data_2x32 = i_data_2 << 5;
assign sum_2_4_16_32 = data_2x4 + data_2x16 + data_2x32;

assign sum_15 = sum_1_4_16_32[21:6] + sum_2_4_16_32[21:8];
assign sum_35 = out_arr[0] + i_data_2;
assign sum_25 = out_arr[2] + out_arr[0];
assign sum_45 = out_arr[2] + i_data_2;

assign out_arr[0] = sum_15[15:0];
assign out_arr[1] = sum_25[16:1];
assign out_arr[2] = sum_35[16:1];
assign out_arr[3] = sum_45[16:1];

// outputs
assign o_data_1 = out_arr[0];
assign o_data_2 = out_arr[1];
assign o_data_3 = out_arr[2];
assign o_data_4 = out_arr[3];

endmodule

module itp6 (
    input  [15:0] i_data_1,
    input  [15:0] i_data_2,
    output [15:0] o_data_1,
    output [15:0] o_data_2,
    output [15:0] o_data_3,
    output [15:0] o_data_4,
    output [15:0] o_data_5
);

wire [15:0] out_arr [0:4];
wire [16:0] sum_11;
wire [18:0] data_1x8, data_2x8, midx8;
wire [19:0] data_1x16, data_2x16, midx16;
wire [21:0] data_1x64, data_2x64, midx64;
wire [22:0] sum_1_8_16_64, sum_2_8_16_64, sum_mid_8_16_64;
wire [16:0] sum_16, sum_26, sum_46, sum_56;

assign sum_11 = i_data_1 + i_data_2;
assign data_1x8 = i_data_1 << 3;
assign data_1x16 = i_data_1 << 4;
assign data_1x64 = i_data_1 << 6;
assign sum_1_8_16_64 = data_1x8 + data_1x16 + data_1x64;

assign data_2x8 = i_data_2 << 3;
assign data_2x16 = i_data_2 << 4;
assign data_2x64 = i_data_2 << 6;
assign sum_2_8_16_64 = data_2x8 + data_2x16 + data_2x64;

assign midx8 = out_arr[2] << 3;
assign midx16 = out_arr[2] << 4;
assign midx64 = out_arr[2] << 6;
assign sum_mid_8_16_64 = midx8 + midx16 + midx64;

assign sum_16 = sum_1_8_16_64[22:7] + sum_mid_8_16_64[22:8];
assign sum_26 = sum_1_8_16_64[22:8] + sum_mid_8_16_64[22:7];
assign sum_46 = sum_2_8_16_64[22:8] + sum_mid_8_16_64[22:7];
assign sum_56 = sum_2_8_16_64[22:7] + sum_mid_8_16_64[22:8];

assign out_arr[0] = sum_16[15:0];
assign out_arr[1] = sum_26[15:0];
assign out_arr[2] = sum_11[16:1];
assign out_arr[3] = sum_46[15:0];
assign out_arr[4] = sum_56[15:0];

// outputs
assign o_data_1 = out_arr[0];
assign o_data_2 = out_arr[1];
assign o_data_3 = out_arr[2];
assign o_data_4 = out_arr[3];
assign o_data_5 = out_arr[4];

endmodule

module itp7 (
    input  [15:0] i_data_1,
    input  [15:0] i_data_2,
    output [15:0] o_data_1,
    output [15:0] o_data_2,
    output [15:0] o_data_3,
    output [15:0] o_data_4,
    output [15:0] o_data_5,
    output [15:0] o_data_6
);

wire [15:0] out_arr [0:5];
wire [20:0] data_1x32;
wire [21:0] data_1x64;
wire [22:0] data_1x128;
wire [23:0] sum_1_32_64_128;
wire [17:0] data_2x4;
wire [20:0] data_2x32;
wire [21:0] sum_2_4_32;
wire [16:0] sum_17, sum_27, sum_37, sum_47, sum_57, sum_67;

assign data_1x32 = i_data_1 << 5;
assign data_1x64 = i_data_1 << 6;
assign data_1x128 = i_data_1 << 7;
assign sum_1_32_64_128 = data_1x32 + data_1x64 + data_1x128;

assign data_2x4 = i_data_2 << 2;
assign data_2x32 = i_data_2 << 5;
assign sum_2_4_32 = data_2x4 + data_2x32;

assign sum_17 = sum_1_32_64_128[23:8] + sum_2_4_32[21:8];
assign sum_47 = out_arr[0] + i_data_2;
assign sum_27 = out_arr[3] + i_data_1;
assign sum_37 = out_arr[1] + out_arr[3];
assign sum_57 = out_arr[2] + i_data_2;
assign sum_67 = out_arr[4] + i_data_2;

assign out_arr[0] = sum_17[15:0];
assign out_arr[1] = sum_27[16:1];
assign out_arr[2] = sum_37[16:1];
assign out_arr[3] = sum_47[16:1];
assign out_arr[4] = sum_57[16:1];
assign out_arr[5] = sum_67[16:1];

// outputs
assign o_data_1 = out_arr[0];
assign o_data_2 = out_arr[1];
assign o_data_3 = out_arr[2];
assign o_data_4 = out_arr[3];
assign o_data_5 = out_arr[4];
assign o_data_6 = out_arr[5];

endmodule

module itp8 (
    input  [15:0] i_data_1,
    input  [15:0] i_data_2,
    output [15:0] o_data_1,
    output [15:0] o_data_2,
    output [15:0] o_data_3,
    output [15:0] o_data_4,
    output [15:0] o_data_5,
    output [15:0] o_data_6,
    output [15:0] o_data_7
);

wire [16:0] sum_11;
wire [16:0] sum_31, sum_13;
wire [16:0] sum_71, sum_53, sum_35, sum_17;
wire [15:0] out_arr [0:6];

assign sum_11 = i_data_1 + i_data_2;
assign sum_13 = out_arr[3] + i_data_2;
assign sum_31 = out_arr[3] + i_data_1;
assign sum_71 = out_arr[1] + i_data_1;
assign sum_53 = out_arr[1] + out_arr[3];
assign sum_35 = out_arr[3] + out_arr[5];
assign sum_17 = out_arr[5] + i_data_2;

assign out_arr[0] = sum_71[16:1];
assign out_arr[1] = sum_31[16:1];
assign out_arr[2] = sum_53[16:1];
assign out_arr[3] = sum_11[16:1];
assign out_arr[4] = sum_35[16:1];
assign out_arr[5] = sum_13[16:1];
assign out_arr[6] = sum_17[16:1];

// outputs
assign o_data_1 = out_arr[0];
assign o_data_2 = out_arr[1];
assign o_data_3 = out_arr[2];
assign o_data_4 = out_arr[3];
assign o_data_5 = out_arr[4];
assign o_data_6 = out_arr[5];
assign o_data_7 = out_arr[6];

endmodule
