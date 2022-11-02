module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0, // record
	input i_key_1, // play
	input i_key_2, // stop
	// input [3:0] i_speed, // design how user can decide mode on your own
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr
);

// design the FSM and states as you like
parameter S_IDLE       = 0;
parameter S_RECD       = 1;
parameter S_PLAY       = 2;
parameter S_PLAY_PAUSE = 3;
logic [2:0] state_r, state_w;

logic i2c_oen, i2c_sdat;
logic init_finish;
logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;

logic play, pause, stop;

// 
assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;
assign play = (state_r == S_PLAY);
assign pause = (state_r == S_PLAY_PAUSE);
assign stop = (state_r == S_IDLE) || (state_r == S_RECD);

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially send out settings to initialize WM8731 with I2C protocol
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100K),
	.i_start(),
	.o_finished(init_finish),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_AUD_ADCLRCK),
	.i_start(play),
	.i_pause(pause),
	.i_stop(stop),
	.i_speed(),
	.i_fast(),
	.i_slow_0(), // constant interpolation
	.i_slow_1(), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to send to WM8731 with I2S protocol
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(play), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocol and save to SRAM

// start, stop, pause for AudRecorder
logic rec_start_w, rec_stop_w, rec_pause_w;
logic rec_start_r, rec_stop_r, rec_pause_r;

AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(rec_start_r),
	.i_pause(rec_pause_r),
	.i_stop(rec_stop_r),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record)
);

always_comb begin
    // next state
    if (init_finish) begin
        case(state_r)
            S_IDLE: begin
                if (i_key_0) begin // record
                    state_w = S_RECD;
                end
                else if (i_key_1) begin // play
                    state_w = S_PLAY;
                end
                else begin
                    state_w = S_IDLE;
                end
            end
            S_RECD: begin
                if (i_key_2) begin // stop
                    state_w = S_IDLE;
                end
                else begin
                    state_w = S_RECD;
                end
            end
            S_PLAY: begin
                if (i_key_1) begin // pause
                    state_w = S_PLAY_PAUSE;
                end
                if (i_key_2) begin // stop
                    state_w = S_IDLE;
                end
                else begin
                    state_w = S_PLAY;
                end
            end
            S_PLAY_PAUSE: begin
                if (i_key_1) begin // continue to play
                    state_w = S_PLAY;
                end
                if (i_key_2) begin // stop
                    state_w = S_IDLE;
                end
                else begin
                    state_w = S_PLAY_PAUSE;
                end
            end
            default: state_w = S_IDLE;
        endcase
    end
    else begin
        state_w = S_IDLE;
    end

	// design your control here
	case (state_r)
		S_RECD: begin
			rec_start_w = i_key_0;
			rec_stop_w = i_key_1;
			rec_pause_w = i_key_2;
		end

end

always_ff @(posedge i_AUD_BCLK or posedge i_rst_n) begin
	if (!i_rst_n) begin
		rec_stop_r = 0;
		rec_pause_r = 0;
		rec_start_r = 0;
		state_r = S_IDLE;
	end
	else begin
		rec_stop_r = rec_stop_w;
		rec_pause_r = rec_pause_w;
		rec_start_r = rec_start_w;
		state_r = state_w;
	end
end

endmodule
