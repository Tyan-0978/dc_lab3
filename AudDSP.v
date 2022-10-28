// ----------------------------------------------------------------------
// audio DSP module
// ----------------------------------------------------------------------

module AudDSP (
    input         i_rst_n,
    input         i_clk,
    input         i_start,
    input         i_pause,
    input         i_stop,
    input  [3:0]  i_speed,
    input         i_fast,
    input         i_slow_0, // constant interpolation
    input         i_slow_1, // linear interpolation
    input         i_daclrck,
    input  [15:0] i_sram_data,
    output [15:0] o_dac_data,
    output [19:0] o_sram_addr
);

// ----------------------------------------------------------------------
// parameters
// ----------------------------------------------------------------------

// states
parameter STOP  = 0;
parameter START = 1;
parameter PAUSE = 2;

// ----------------------------------------------------------------------
// signals
// ----------------------------------------------------------------------

// slow mode signals
wire slow_mode;
reg  slow_fetch_data;
reg  [15:0] slow_audio_data;

// state
reg  [1:0] state, next_state;

// outputs
reg  [15:0] audio_data, next_audio_data;
reg  [19:0] sram_addr, next_sram_addr;

// ----------------------------------------------------------------------
// modules
// ----------------------------------------------------------------------

// TODO
Interp itp0 (
    .i_rst_n(i_rst_n),
    .i_clk(i_clk),
    .i_data(i_sram_data),
    .i_mode(i_slow_1),
    .i_speed(i_speed),
    .o_slow_data(slow_audio_data),
    .o_fetch_data(slow_fetch_data)
);

// ----------------------------------------------------------------------
// combinational part
// ----------------------------------------------------------------------

// slow mode
assign slow_mode = i_slow_0 || i_slow_1;
// outputs
assign o_dac_data = audio_data;
assign o_sram_addr = sram_addr;

always @ (*) begin
    // next state ---------------------------------------
    case(state)
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

    // next outputs ---------------------------------------
    // next audio data
    if (slow_mode) begin
        next_audio_data = slow_audio_data;
    end
    else begin
        next_audio_data = i_sram_data;
    end
    // next sram address
    case(state)
    START: begin
        if (slow_mode) begin
	    if (slow_fetch_data) begin
	        next_sram_addr = sram_addr + 1;
	    end
	    else begin
	        next_sram_addr = sram_addr;
	    end
        end
        else begin
	    next_sram_addr = sram_addr + i_speed;
        end
    end
    PAUSE: begin
	next_sram_addr = sram_addr;
    end
    STOP: begin
	next_sram_addr = 0;
    end
    default: next_sram_addr = 0;
end

// ----------------------------------------------------------------------
// sequential part
// ----------------------------------------------------------------------

always @ (posedge i_clk || negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= STOP;
	audio_data <= 0;
	sram_addr <= 0;
    end
    else begin
        state <= next_state;
	audio_data <= next_audio_data;
	sram_addr <= next_sram_addr;
    end
end

endmodule
