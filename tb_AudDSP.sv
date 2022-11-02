`timescale 1ns/100ps

module tb;

parameter CYC = 10;
parameter HALF_CYC = CYC / 2;

logic i_clk, i_rst_n;
logic play, pause, stop;
logic [16:0] i_speed;
logic [15:0] i_data, o_data;
logic [19:0] addr;

AudDSP dsp0(
    .i_rst_n(i_rst_n),
    .i_clk(i_clk),
    .i_start(play),
    .i_pause(pause),
    .i_stop(stop),
    .i_speed(i_speed),
    .i_daclrck(i_clk),
    .i_sram_data(i_data),
    .o_dac_data(o_data),
    .o_sram_addr(addr)
);

initial i_clk = 0;
always #HALF_CYC i_clk = ~i_clk;

initial begin
    $fsdbDumpfile("AudDSP.fsdb");
    $fsdbDumpvars;
end

initial begin
    i_rst_n = 0;
    play = 0;
    pause = 0;
    stop = 0;
    i_speed = 17'b1_0010_0000_0000_0000;
    #(CYC * 2)
    i_rst_n = 1;
    #(CYC * 10)
    @(negedge i_clk) play = 1;
    #(CYC * 300)
    $finish;
end

initial i_data = 0;
always @(negedge i_clk) i_data = i_data + 7;

endmodule
