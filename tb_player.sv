`timescale 1ns/100ps

module tb3;

parameter CYC = 10;
parameter HALF_CYC = CYC / 2;
parameter TWENTY_CYC = CYC*20;

logic i_AUD_BCLK, i_rst_n, i_AUD_DACLRCK;
logic play;
logic [15:0] dac_data;
logic o_AUD_DACDAT;

AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(play), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

initial i_AUD_BCLK = 0;
always #HALF_CYC i_AUD_BCLK = ~i_AUD_BCLK;
initial i_AUD_DACLRCK = 0;
always #TWENTY_CYC i_AUD_DACLRCK = ~i_AUD_DACLRCK;

initial begin
    $fsdbDumpfile("aud_player.fsdb");
    $fsdbDumpvars;
end

initial begin
    i_rst_n = 0;
    play = 0;
    #(CYC * 2)
    i_rst_n = 1;
    #(CYC * 10)
    @(negedge i_AUD_BCLK) play = 1;
    #(CYC * 300)
    $finish;
end

initial dac_data = 0;
always @(negedge i_AUD_DACLRCK) dac_data = dac_data + 7;

endmodule
