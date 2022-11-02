`timescale 1ns/100ps

module tb2;

parameter CYC = 10;
parameter HALF_CYC = CYC / 2;
parameter TWENTY_CYC = CYC*20;

logic i_AUD_ADCLRCK, i_rst_n, i_AUD_BCLK;
logic record_start, record_pause, record_stop;
logic i_AUD_ADCDAT;
logic [19:0] addr_record;
logic [15:0] data_record;

AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(record_start),
	.i_pause(record_pause),
	.i_stop(record_stop),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record)
);

initial i_AUD_BCLK = 0;
always #HALF_CYC i_AUD_BCLK = ~i_AUD_BCLK;
initial i_AUD_ADCLRCK = 0;
always #TWENTY_CYC i_AUD_ADCLRCK = ~i_AUD_ADCLRCK;

initial begin
    $fsdbDumpfile("aud_recorder.fsdb");
    $fsdbDumpvars;
end

initial begin
    i_rst_n = 0;
    record_start = 0;
    record_pause = 0;
    record_stop = 0;
    #(CYC * 2)
    i_rst_n = 1;
    #(CYC * 10)
    @(negedge i_AUD_BCLK) 
        record_start = 1;
    #(CYC * 300)
    @(negedge i_AUD_BCLK) begin 
        record_pause = 1;
        record_start = 0;
    end
    #(CYC * 50)
    @(negedge i_AUD_BCLK) begin 
        record_pause = 1;
        record_start = 0;
    end
    #(CYC * 50)
    @(negedge i_AUD_BCLK) begin 
        record_start = 1;
        record_pause = 0;
    end
    #(CYC * 500)
    @(negedge i_AUD_BCLK) begin 
        record_start = 0;
        record_stop = 1;
    end
    $finish;
end

initial i_AUD_ADCDAT = 1;
always @(negedge i_AUD_BCLK) i_AUD_ADCDAT = ~i_AUD_ADCDAT;

endmodule
