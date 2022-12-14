// ----------------------------------------------------------------------
// audio DSP module
// ----------------------------------------------------------------------

module AudDSP (
    input         i_rst_n,
    input         i_clk,
    input         i_start,
    input         i_pause,
    input         i_stop,
    input  [16:0]  i_speed,
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

// play mode signals
wire [14:0] play_vector;
reg [3:0] play_speed;
// slow mode signals
wire slow_mode;
wire slow_valid;
wire slow_pause;
reg  slow_begin, next_slow_begin, delayed_slow_begin;
wire [15:0] slow_audio_data;
reg  [3:0] counter_bound;
wire [3:0] slow_count;
wire reach_bound;
wire [1:0] slow_vector;
reg slow_0, slow_1;
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
    .i_mode(slow_1),
    .i_speed(play_speed),
    .o_slow_data(slow_audio_data)
);

// ----------------------------------------------------------------------
// combinational part
// ----------------------------------------------------------------------

// slow mode signals
assign slow_mode = (slow_0 || slow_1);
assign slow_pause = (state == PAUSE);
assign slow_valid = (reach_bound || slow_begin);
// outputs
assign o_dac_data = audio_data;
assign o_sram_addr = sram_addr;
// decide speed mode
assign play_vector[14] = i_speed[14];
assign play_vector[13] = ( (|i_speed[14] == 0) && (i_speed[13]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[12] = ( (|i_speed[14:13] == 0) && (i_speed[12]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[11] = ( (|i_speed[14:12] == 0) && (i_speed[11]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[10] = ( (|i_speed[14:11] == 0) && (i_speed[10]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[9] = ( (|i_speed[14:10] == 0) && (i_speed[9]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[8] = ( (|i_speed[14:9] == 0) && (i_speed[8]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[7] = ( (|i_speed[14:8] == 0) && (i_speed[7]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[6] = ( (|i_speed[14:7] == 0) && (i_speed[6]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[5] = ( (|i_speed[14:6] == 0) && (i_speed[5]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[4] = ( (|i_speed[14:5] == 0) && (i_speed[4]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[3] = ( (|i_speed[14:4] == 0) && (i_speed[3]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[2] = ( (|i_speed[14:3] == 0) && (i_speed[2]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[1] = ( (|i_speed[14:2] == 0) && (i_speed[1]==1'b1) ) ? 1'b1:1'b0;
assign play_vector[0] = ( (|i_speed[14:1] == 0) && (i_speed[0]==1'b1) ) ? 1'b1:1'b0;

always@(*) begin
    case (play_vector)
       15'b10000_00000_00000:  play_speed = 4'd8;
       15'b01000_00000_00000:  play_speed = 4'd7;
       15'b00100_00000_00000:  play_speed = 4'd6;
       15'b00010_00000_00000:  play_speed = 4'd5;
       15'b00001_00000_00000:  play_speed = 4'd4;
       15'b00000_10000_00000:  play_speed = 4'd3;
       15'b00000_01000_00000:  play_speed = 4'd2;
       15'b00000_00100_00000:  play_speed = 4'd8;
       15'b00000_00010_00000:  play_speed = 4'd7;
       15'b00000_00001_00000:  play_speed = 4'd6;
       15'b00000_00000_10000:  play_speed = 4'd5;
       15'b00000_00000_01000:  play_speed = 4'd4;
       15'b00000_00000_00100:  play_speed = 4'd3;
       15'b00000_00000_00010:  play_speed = 4'd2;
       15'b00000_00000_00001:  play_speed = 4'd1;
       default: play_speed = 4'd1;
    endcase
end
// decide slow mode or not

assign slow_vector[1] = i_speed[16];
assign slow_vector[0] = ((|i_speed[16] == 1'b0)&&(i_speed[15] == 1'b1)) ? 1'b1 : 1'b0;

always@(*) begin
    case(slow_vector)
        2'b10: begin
            slow_1 = 1'b1;
            slow_0 = 1'b0;
        end
        2'b01: begin
            slow_1 = 1'b0;
            slow_0 = 1'b1;
        end
        default: begin
            slow_1 = 1'b0;
            slow_0 = 1'b0;
        end
    endcase
end

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
        counter_bound = play_speed - 1; // minus 1 for correct timing
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
		next_sram_addr = sram_addr + play_speed;
	    end
	end
	PAUSE: begin
	    next_sram_addr = sram_addr;
	end
	STOP: begin
	    next_sram_addr = 0;
	end
	default: next_sram_addr = 0;
    endcase
end

// ----------------------------------------------------------------------
// sequential part
// ----------------------------------------------------------------------

always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= STOP;
        slow_begin <= 0;
        delayed_slow_begin <= 0;
	audio_data <= 0;
	sram_addr <= 0;
    end
    else begin
        state <= next_state;
        slow_begin <= next_slow_begin;
        delayed_slow_begin <= slow_begin;
	audio_data <= next_audio_data;
	sram_addr <= next_sram_addr;
    end
end

endmodule
