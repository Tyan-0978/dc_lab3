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
reg o_aud_dacdat_w;
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
reg [4:0] counter_r;
reg [4:0] counter_w;

always @(*) begin
    if (counter_r < 17 && i_en && !i_daclrck) begin
        o_aud_dacdat_w = i_dac_data[16-counter_r];
        counter_w = counter_r + 1; 
    end
    else begin 
        o_aud_dacdat_w = 0;
        counter_w = 0;
    end
end

always @(posedge i_bclk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        counter_r <= 0;
        o_aud_dacdat_r <= 0;
    end
    else begin
        counter_r <= counter_w;
        o_aud_dacdat_r <= o_aud_dacdat_w;
    end
end

endmodule