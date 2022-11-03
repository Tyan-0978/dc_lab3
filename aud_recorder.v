module AudRecorder(
	input i_rst_n, 
	input i_clk,
	input i_lrc,
	input i_start,
	input i_pause,
	input i_stop,
	input i_data,
	output [19:0] o_address,
	output [15:0] o_data
);

// output
reg [19:0] o_address_r;
reg [15:0] o_data_r;
assign o_address = o_address_r;
assign o_data = o_data_r;
reg [19:0] o_address_w;
reg [15:0] o_data_w;

// SRAM address 
reg [3:0] counter_w;
reg [3:0] counter_r;

// state
reg [2:0] state_w;
reg [2:0] state_r;
parameter STOP = 0; // not working
parameter START = 1; // receive data
parameter PAUSE = 2; // wait for start signal
parameter STORE = 3; // store the received data // TB checked
parameter IDLE = 4; // wait for next data
parameter CLEAR = 5;

// i_start_hold
reg i_start_hold_r;
reg i_start_hold_w;

always @(*) begin
    // determine next state & what to do accordingly
    case (state_r)
			CLEAR: begin
				counter_w = 0;
				o_address_w = o_address_r + 1;
				o_data_w = 0;
				i_start_hold_w = 0;
				if (o_address_r == 20'b11111111111111111111) 
					state_w = STOP;
				else 
					state_w = state_r;
			end
        STOP: begin
            counter_w = 0;
            o_address_w = 0;
            o_data_w = 0;
            if (i_start_hold_r && !i_lrc) begin
                i_start_hold_w = 0;
	            state_w = START;
	        end
	        else begin
                i_start_hold_w = i_start_hold_r || i_start;
	            state_w = STOP;
	        end
        end
        START: begin
            i_start_hold_w = 0;
            o_address_w = o_address_r;
            counter_w = counter_r + 1;
            if (counter_r == 15) begin
                state_w = STORE;
                o_data_w = (o_data_r << 1) + i_data;
            end
            else if (counter_r == 0) begin 
                state_w = state_r;
                o_data_w = i_data;
            end
            else if (i_stop) begin
                state_w = STOP;
                o_data_w = (o_data_r << 1) + i_data;
            end
            else if (i_pause) begin
                state_w = PAUSE;
                o_data_w = (o_data_r << 1) + i_data;
            end
            else begin
                state_w = state_r;
                o_data_w = (o_data_r << 1) + i_data;
            end
	    end

        PAUSE: begin
            i_start_hold_w = i_start_hold_r || i_start;
            counter_w = 0;
            o_address_w = o_address_r;
            o_data_w = 0;
            if (i_start_hold_r && !i_lrc) begin
                state_w = START;
            end
            else if (i_stop) begin
                state_w = STOP;
            end
            else begin
                state_w = state_r;
            end
	    end

        STORE: begin
            i_start_hold_w = 0;
            o_data_w = o_data_r;
            counter_w = 0;
            o_address_w = o_address_r;
            if (i_lrc == 1) begin 
                state_w = IDLE;
            end
            else if (i_stop) begin
                state_w = STOP;
            end
            else if (i_pause) begin
                state_w = PAUSE;
            end
            else begin
                state_w = state_r;
            end
        end

        IDLE: begin
            i_start_hold_w = 0;
            if (o_address_r == 20'b11111111111111111111) begin
                state_w = STOP;
                o_address_w = o_address_r;
            end
            else if (i_lrc == 0) begin  
                state_w = START;
                o_address_w = o_address_r + 1;
            end
            else if (i_stop) begin
                state_w = STOP;
            end
            else if (i_pause) begin
                state_w = PAUSE;
            end
            else begin
                state_w = state_r;
                o_address_w = o_address_r;
            end
            counter_w = 0;
            o_data_w = o_data_r;
        end
        
        // only if bugs exist will it go to default block
	    default: begin 
            i_start_hold_w = 0;
            state_w = STOP;
            counter_w = 0;
            o_address_w = 0;
            o_data_w = 0;
        end
    endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_address_r <= 0;
        o_data_r <= 0;
        counter_r <= 0;
        state_r <= CLEAR;
        i_start_hold_r <= 0;
    end
    else begin
        o_address_r <= o_address_w;
        o_data_r <= o_data_w;
        counter_r <= counter_w;
        state_r <= state_w;
        i_start_hold_r <= i_start_hold_w;
    end
end

endmodule