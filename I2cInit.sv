module I2cInitializer (
    input i_rst_n,
    input i_clk,
    input i_start,
    output o_finished,
    output o_sclk,
    output o_sdat,
    output o_oen
);
logic [23:0] sda_data [0:7-1];
logic [5-1:0] counter32_w, counter32_r;
logic [24-1:0] data_w, data_r;
logic [3-1:0] counter8_w, counter8_r;
logic data_finish;

assign sda_data = {
    {1'b1,1'b0,27'b0011_0100_1_000_1111_0_1_0000_0000_1,1'b0,2'b00},
    {1'b1,1'b0,27'b0011_0100_1_000_0100_0_1_0001_0101_1,1'b0,2'b00},
    {1'b1,1'b0,27'b0011_0100_1_000_0101_0_1_0000_0000_1,1'b0,2'b00},
    {1'b1,1'b0,27'b0011_0100_1_000_0110_0_1_0000_0000_1,1'b0,2'b00},
    {1'b1,1'b0,27'b0011_0100_1_000_0111_0_1_0100_0010_1,1'b0,2'b00},
    {1'b1,1'b0,27'b0011_0100_1_000_1000_0_1_0001_1001_1,1'b0,2'b00},
    {1'b1,1'b0,27'b0011_0100_1_000_1001_0_1_0000_0001_1,1'b0,2'b00}    
};
assign o_finished = finish_r;
assign data = sda_data[counter8_r+1];
assign o_sdat = sdat_r[0];
assign o_oen = oen_r;

//assign reset = 24'b0011_0100_000_1111_0_0000_0000;
//assign aa_pathctrl = 24'b0011_0100_000_0100_0_0001_0101;
//assign da_pathctrl = 24'b0011_0100_000_0101_0_0000_0000;
//assign power_down_ctrl = 24'b0011_0100_000_0110_0_0000_0000;
//assign da_interfaceform = 24'b0011_0100_000_0111_0_0100_0010;
//assign samplingctrl = 24'b0011_0100_000_1000_0_0001_1001;
//assign activectrl = 24'b0011_0100_000_1001_0_0000_0001;


// 5-bits counter 
always_comb begin
    if (i_rst_n) begin
        counter32_w = counter32_r + 1;
    end
    else begin 
        counter32_w = counter32_r;
    end
end
// decide sclk signals
always_comb begin
    case (counter32_r) 
        5'd0: o_sclk = 1'b1;
        5'd1: o_sclk = 1'b1;
        5'd30: o_sclk = 1'b1;
        5'd31: o_sclk = 1'b1;
        default: o_sclk = i_clk; 
    endcase
end
// decide data finish 
always_comb begin
    if (counter32_r == 5'd31) begin
        data_finish = 1'b1;
    end
    else data_finish = 1'b0;
end
// decide sdat signals
always_comb begin
    data_w = (data_finish) ? data : data_r >> 1; 
end
// decide output enable
always_comb begin
    case (counter32_r)
        5'd10: oen_w = 1'b0;
        5'd19: oen_w = 1'b0;
        5'd28: oen_w = 1'b0;
        default: oen_w = 1'b1; 
    endcase
end
// 3-bits counter
always_comb begin
    if (counter32_r == 5'd31) begin
        counter8_w = counter8_r + 1;
    end
    else begin
        counter8_w = counter8_r;
    end
end
// decide finish signal
always_comb begin
    if (counter8_r == 3'd7) begin
        finish_w = 1'b1;
    end
    else finish_w = 1'b0;
end

always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        counter32_r <= 5'd0;
        counter8_r <= 3'd0;
        sdat_r <= 1'b1;
        finish_r <= 1'b0;
        oen_r <= 1'b1;
        sdat_r <= {1'b1,1'b0,27'b0011_0100_1_000_1111_0_1_0000_0000_1,1'b0,2'd0};
    end
    else begin
        counter32_r <= counter32_w;
        counter8_r <= counter8_w;
        sdat_r <= sdat_w;
        finish_r <= finish_w;
        oen_r <= oen_w;
        sdat_r <= sdat_w;
    end
end
endmodule