// ----------------------------------------------------------------------
// interpolation calculation module
// ----------------------------------------------------------------------

module itp5 (
    input  [15:0] i_data_1,
    input  [15:0] i_data_2,
    output [15:0] o_data_1,
    output [15:0] o_data_2,
    output [15:0] o_data_3,
    output [15:0] o_data_4,
);

wire [17:0] data_1x4, data_2x4;
wire [19:0] data_1x16, data_2x16;
wire [20:0] data_1x32, data_2x32;
wire [21:0] sum_1_4_16_32, sum_2_4_16_32;
wire [16:0] sum_15, sum_35, sum_25, sum_45;
wire [15:0] out_arr [0:3];

assign data_1x4 = {i_data_1, 2'd0};
assign data_1x32 = {i_data_1, 5'd0};
assign data_1x64 = {i_data_1, 6'd0};
assign sum_1_4_16_32 = data_1x4 + data_1x16 + data_1x32;
assign data_2x4 = {i_data_2, 2'd0};
assign data_2x32 = {i_data_2, 5'd0};
assign data_2x64 = {i_data_2, 6'd0};
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
    output [15:0] o_data_5,
);

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
    output [15:0] o_data_6,
);

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
    output [15:0] o_data_7,
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
