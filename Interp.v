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
reg  [15:0][7:0] data_arr, next_data_arr;

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
                case(i_speed) // TODO
                    2: begin
                    end
                    3: begin
                    end
                    4: begin
                    end
                    5: begin
                    end
                    6: begin
                    end
                    7: begin
                    end
                    8: begin
                    end
                    default: begin
                        for (integer i = 0; i <= 7; i = i+1) begin
                            next_data_arr[i] = 0;
                        end
                    end
                endcase
            end
            else begin // constant
                for (integer i = 0; i <= 7; i = i+1) begin
                    next_data_arr[i] = data_1;
                end
            end
        end
        SHIFT: begin
            for (integer i = 0; i <= 6; i = i+1) begin
                next_data_arr[i] = data_arr[i+1];
            end
            next_data_arr[7] = 0;
        end
        default: begin
            for (integer i = 0; i <= 7; i = i+1) begin
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
