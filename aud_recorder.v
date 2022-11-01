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
parameter STORE = 3; // store the received data
parameter IDLE = 4; // wait for next data

always @(*) begin
    // determine next state & what to do accordingly
    case (state_r)
        STOP: begin
            counter_w = 0;
            o_address_w = 0;
            o_data_w = 0;
            if (i_start) begin
	            state_w = START;
	        end
	        else begin
	            state_w = STOP;
	        end
        end
        START: begin
            o_data_w = (o_data_r << 1) + i_data;
            o_address_w = o_address_r;
            counter_w = counter_r + 1;
            if (counter_r == 15) begin
                state_w = STORE;
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

        PAUSE: begin
            counter_w = 0;
            o_address_w = o_address_r;
            o_data_w = 0;
            if (i_start) begin
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
            o_data_w = o_data_r;
            counter_w = 0;
            o_address_w = o_address_r;
            if (i_lrc == 1) begin 
                state_w = IDLE;
            end
            else begin
                state_w = state_r;
            end
        end

        IDLE: begin
            if (o_address_r == 20'b0) begin
                state_w = STOP;
                o_address_w = o_address_r;
            end
            else if (i_lrc == 0) begin  
                state_w = START;
                o_address_w = o_address_r + 1;
            end
            else
                state_w = state_r;
                o_address_w = o_address_r;
            counter_w = 0;
            o_data_w = o_data_r;
        end
        
        // only if bugs exist will it go to default block
	    default: begin 
            state_w = STOP;
            counter_w = 0;
            o_address_w = 0;
            o_data_w = 0;
        end
    endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n) begin
        o_address_r <= o_address_w;
        o_data_r <= o_data_w;
        counter_r <= counter_w;
        state_r <= state_w;
    end
    else begin
        o_address_r <= 0;
        o_data_r <= 0;
        counter_r <= 0;
        state_r <= STOP;
    end
end

endmodule