// ----------------------------------------------------------------------
// interpolation module for slow speed
// ----------------------------------------------------------------------

module Interp (
    input         i_rst_n,
    input         i_clk,
    input         i_valid,
    input         i_pause,
    input  [15:0] i_data,
    input         i_mode,
    input  [3:0]  i_speed,
    output [15:0] o_slow_data,
);

// ----------------------------------------------------------------------
// parameters
// ----------------------------------------------------------------------

parameter INTPL = 0;
parameter SHIFT = 1;

// ----------------------------------------------------------------------
// signals
// ----------------------------------------------------------------------

// state
reg  state, next_state;

// audio data
// input shifting: i_data >> data_2 >> data_1
reg  [15:0] data_1, next_data_1;
reg  [15:0] data_2, next_data_2;
reg  [15:0][6:0] data_arr, next_data_arr;

// interpolation data
reg  [15:0] itp_data_5 [0:3];
reg  [15:0] itp_data_6 [0:4];
reg  [15:0] itp_data_7 [0:5];
reg  [15:0] itp_data_8 [0:6];

// ----------------------------------------------------------------------
// modules
// ----------------------------------------------------------------------

itp5 i5 (
    .i_data_1(data_1),
    .i_data_2(data_2),
    .o_data_1(itp_data_5[0]),
    .o_data_2(itp_data_5[1]),
    .o_data_3(itp_data_5[2]),
    .o_data_4(itp_data_5[3])
);
itp6 i6 (
    .i_data_1(data_1),
    .i_data_2(data_2),
    .o_data_1(itp_data_6[0]),
    .o_data_2(itp_data_6[1]),
    .o_data_3(itp_data_6[2]),
    .o_data_4(itp_data_6[3]),
    .o_data_5(itp_data_6[4])
);
itp7 i7 (
    .i_data_1(data_1),
    .i_data_2(data_2),
    .o_data_1(itp_data_7[0]),
    .o_data_2(itp_data_7[1]),
    .o_data_3(itp_data_7[2]),
    .o_data_4(itp_data_7[3]),
    .o_data_5(itp_data_7[4]),
    .o_data_6(itp_data_7[5])
);
itp8 i8 (
    .i_data_1(data_1),
    .i_data_2(data_2),
    .o_data_1(itp_data_8[0]),
    .o_data_2(itp_data_8[1]),
    .o_data_3(itp_data_8[2]),
    .o_data_4(itp_data_8[3]),
    .o_data_5(itp_data_8[4]),
    .o_data_6(itp_data_8[5]),
    .o_data_7(itp_data_8[6])
);

// ----------------------------------------------------------------------
// conbinational part
// ----------------------------------------------------------------------

// output 
assign o_slow_data = (state) ? data_arr[0] : data_1;

always @ (*) begin
    // next state
    if (i_valid) begin
        next_state = INTPL;
    end
    else begin
        next_state = SHIFT;
    end

    // next input data
    if (i_pause) begin
        next_data_1 = data_1;
        next_data_2 = data_2;
    end
    else begin
        if (i_valid) begin // input new data
            next_data_1 = data_2;
            next_data_2 = i_data;
        end
        else begin
            next_data_1 = data_1;
            next_data_2 = data_2;
        end
    end

    // next data array
    case(state)
        INTPL: begin
            if (i_mode) begin // linear
                case(i_speed)
                    2: begin
                        next_data_arr[0] = itp_data_8[3]; // 4/8
                        for (integer i = 1; i <= 6; i = i+1) begin
                            next_data_arr[i] = 0;
                        end
                    end
                    3: begin
                        next_data_arr[0] = itp_data_6[1]; // 2/6
                        next_data_arr[1] = itp_data_6[3]; // 4/6
                        for (integer i = 2; i <= 6; i = i+1) begin
                            next_data_arr[i] = 0;
                        end
                    end
                    4: begin
                        next_data_arr[0] = itp_data_8[1]; // 2/8
                        next_data_arr[1] = itp_data_8[3]; // 4/8
                        next_data_arr[2] = itp_data_8[5]; // 6/8
                        for (integer i = 3; i <= 6; i = i+1) begin
                            next_data_arr[i] = 0;
                        end
                    end
                    5: begin
                        for (integer i = 0; i <= 3; i = i+1) begin
                            next_data_arr[i] = itp_data_5[i];
                        end
                        next_data_arr[4] = 0;
                        next_data_arr[5] = 0;
                        next_data_arr[6] = 0;
                    end
                    6: begin
                        for (integer i = 0; i <= 4; i = i+1) begin
                            next_data_arr[i] = itp_data_6[i];
                        end
                        next_data_arr[5] = 0;
                        next_data_arr[6] = 0;
                    end
                    7: begin
                        for (integer i = 0; i <= 5; i = i+1) begin
                            next_data_arr[i] = itp_data_7[i];
                        end
                        next_data_arr[6] = 0;
                    end
                    8: begin
                        for (integer i = 0; i <= 6; i = i+1) begin
                            next_data_arr[i] = itp_data_8[i];
                        end
                    end
                    default: begin
                        for (integer i = 0; i <= 6; i = i+1) begin
                            next_data_arr[i] = 0;
                        end
                    end
                endcase
            end
            else begin // constant
                for (integer i = 0; i <= 6; i = i+1) begin
                    next_data_arr[i] = data_1;
                end
            end
        end
        SHIFT: begin
            for (integer i = 0; i <= 5; i = i+1) begin
                next_data_arr[i] = data_arr[i+1];
            end
            next_data_arr[6] = 0;
        end
        default: begin
            for (integer i = 0; i <= 6; i = i+1) begin
                next_data_arr[i] = 0;
            end
        end
    endcase
end

// ----------------------------------------------------------------------
// sequential part
// ----------------------------------------------------------------------

always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= INTPL;
	data_1 <= 0;
	data_2 <= 0;
        for (integer i = 0; i <= 7; i = i+1) begin
            data_arr[i] = 0;
        end
    end
    else begin
        state <= next_state;
	data_1 <= next_data_1;
	data_2 <= next_data_2;
        for (integer i = 0; i <= 7; i = i+1) begin
            data_arr[i] = next_data_arr[i];
        end
    end
end

endmodule
