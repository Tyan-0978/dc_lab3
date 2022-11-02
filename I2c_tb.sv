`timescale 1ns/100ps

module tb;

parameter CYC = 10;
parameter HALF_CYC = CYC / 2;

logic i_clk, i_rst_n;

I2cInitializer i2c0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .o_finished(o_finished),
    .o_sclk(o_sclk),
    .o_sdat(o_sdat),
    .o_oen(o_oen)
);
initial i_clk = 0;
always #HALF_CYC i_clk = ~i_clk;

initial begin
    $fsdbDumpfile("i2c.fsdb");
    $fsdbDumpvars;
end

initial begin
    i_rst_n = 0;
    #(CYC * 2)
    i_rst_n = 1;
    #(CYC * 300)
    $finish;
end

endmodule