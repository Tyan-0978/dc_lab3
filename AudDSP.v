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
wire slow_valid;
wire slow_pause;
reg  slow_begin, next_slow_begin, delayed_slow_begin;
reg  [15:0] slow_audio_data;
reg  [3:0] counter_bound;
reg  [3:0] slow_count;
reg  reach_bound;

// state
reg  [1:0] state, next_state;

// outputs
reg  [15:0] audio_data, next_audio_data;
reg  [19:0] sram_addr, next_sram_addr;

// ----------------------------------------------------------------------
// modules
// ----------------------------------------------------------------------

BoundedCounter bc0 (
    .i_rst_n(i_rst_n),
    .i_clk(i_clk),
    .i_bound(counter_bound),
    .i_pause(slow_pause),
    .o_count(slow_count),
    .o_reach_bound(reach_bound)
);
Interp itp0 (
    .i_rst_n(i_rst_n),
    .i_clk(i_clk),
    .i_valid(slow_valid),
    .i_pause(slow_pause),
    .i_data(i_sram_data),
    .i_mode(i_slow_1),
    .i_speed(i_speed),
    .o_slow_data(slow_audio_data)
);

// ----------------------------------------------------------------------
// combinational part
// ----------------------------------------------------------------------

// slow mode signals
assign slow_mode = (i_slow_0 || i_slow_1);
assign slow_pause = (state == PAUSE);
assign slow_valid = (reach_bound || slow_begin);
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

    // slow mode signals ----------------------------------
    // next slow begin
    if (state == STOP) begin
        if (i_start) begin
            next_slow_begin = 1;
        end
        else begin
            next_slow_begin = 0;
        end
    end
    else begin
        next_slow_begin = (slow_begin && !delayed_slow_begin);
    end
    // counter bound
    if (state == START) begin
        counter_bound = i_speed - 1; // minus 1 for correct timing
    end
    else begin
        counter_bound = 0;
    end

    // outputs ---------------------------------------
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
	    if (slow_valid) begin
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

always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= STOP;
	slow_valid <= 0;
        slow_begin <= 0;
        delayed_slow_begin <= 0;
	audio_data <= 0;
	sram_addr <= 0;
    end
    else begin
        state <= next_state;
	slow_valid <= next_slow_valid;
        slow_begin <= next_slow_begin;
        delayed_slow_begin <= slow_begin;
	audio_data <= next_audio_data;
	sram_addr <= next_sram_addr;
    end
end

endmodule
