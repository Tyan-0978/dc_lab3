module AudPlayer(
	input i_rst_n,
	input i_bclk,
	input i_daclrck,
	input i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input [15:0] i_dac_data, //dac_data
	output o_aud_dacdat
);

// output
reg o_aud_dacdat_r;
wire o_aud_dacdat_w;
assign o_aud_dacdat = o_aud_dacdat_r;

/*
// FSM
parameter IDLE = 0;
parameter WAIT_A_CYCLE = 1;
parameter SEND_DATA = 2;

reg state_r [1:0];
wire state_w [1:0];
*/

// counter
reg counter_r [15:0];
wire counter_w [15:0];
assign counter_w = counter_r + 1;

always @(*) begin
    if (counter_r < 16)
        o_aud_dacdat_w = i_dac_data[15-counter_r];
    else 
        o_aud_dacdat_w = 0;
end

always @(negedge i_bclk or negedge i_rst_n) begin
    if (i_en && i_rst_n && ! i_daclrck) begin
        counter_r <= counter_w;
        o_aud_dacdat_r <= o_aud_dacdat_w;
    end
    else begin
        counter_r <= 0;
        o_aud_dacdat_r <= 0;
    end
end

endmodule