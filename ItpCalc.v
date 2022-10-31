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
