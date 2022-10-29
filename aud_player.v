module AudPlayer(
	input i_rst_n,
	input i_bclk,
	input i_daclrck,
	input i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input i_dac_data, //dac_data
	output o_aud_dacdat
);

// FSM
parameter IDLE = 0;
parameter WAIT_A_CYCLE = 1;
parameter SEND_DATA = 2;

reg state_r;
wire state_w; 


always @(*) begin
    if 
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (i_en == 1 && i_rst_n == 1) begin
        o_aud_dacdat <= ;
    end
    else begin
        o_aud_dacdat <= 0;

    end
end

endmodule