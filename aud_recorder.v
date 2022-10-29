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
wire [19:0] o_address_w;
wire [15:0] o_data_w;

// SRAM address 
wire [19:0] counter_w;
reg [19:0] counter_r; 
counter_w = counter_r + 1;

// state
wire [1:0] state_w;
reg [1:0] state_r;
parameter STOP = 0;
parameter START = 1;
parameter PAUSE = 2;


always @(*) begin
    // determine next state
    case (state)
        STOP: begin
            if (i_start) begin
	            next_state = START;
	        end
	        else begin
	            next_state = STOP;
	        end
        end
        START: begin
            if (i_stop) begin
                next_state = STOP;
            end
            else if (i_pause) begin
                next_state = PAUSE;
            end
            else begin
                next_state = START;
            end
	    end

        PAUSE: begin
            if (i_start) begin
                next_state = START;
            end
            else if (i_stop) begin
                next_state = STOP;
            end
            else begin
                next_state = PAUSE;
            end
	    end

	    default: next_state = STOP;
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