// ----------------------------------------------------------------------                            
// interpolation module for slow speed
// ----------------------------------------------------------------------

module Interp (
    input         i_rst_n,
    input         i_clk,
    input         i_valid,
    input  [15:0] i_data,
    input         i_mode,
    input  [3:0]  i_speed,
    output [15:0] o_slow_data,
);

// ----------------------------------------------------------------------                            
// parameters
// ----------------------------------------------------------------------

parameter INTP = 0;
parameter SEND = 1;

// ----------------------------------------------------------------------                            
// signals
// ----------------------------------------------------------------------

// audio data
reg  [15:0] data_1, next_data_1;
reg  [15:0] data_2, next_data_2;
reg  [15:0][8:0] data_arr, next_data_arr;

// state
reg  state, next_state;

// ----------------------------------------------------------------------                            
// conbinational part
// ----------------------------------------------------------------------

// output 
assign o_slow_data = data_arr[0];

always @ (*) begin
    // next state
    case(state)
        // TODO
    endcase

    // next data
    if (valid) begin // input new data
        next_data_1 = data_2;
        next_data_2 = i_data;
    end
    else begin
        next_data_1 = data_1;
        next_data_2 = data_2;
    end
end

// ----------------------------------------------------------------------                            
// sequential part
// ----------------------------------------------------------------------

always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= INTP;
	data_1 <= 0;
	data_2 <= 0;
    end
    else begin
        state <= next_state;
	data_1 <= next_data_1;
	data_2 <= next_data_2;
    end
end

endmodule
