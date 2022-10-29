module AudRecorder(
	input i_rst_n, 
	input i_clk,
	input i_lrc,
	input i_start,
	input i_pause,
	input i_stop,
	input i_data,
	output o_address,
	output o_data,
);

always @(*) begin

end

always @(posedge i_clk or negedge i_rst_n) begin

end

endmodule