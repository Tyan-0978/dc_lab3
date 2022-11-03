module I2cInitializer (
    input i_rst_n,
    input i_clk,
    output o_finished,
    output o_sclk,
    output o_sdat,
    output o_oen
);
//logic [31:0] [0:1] sda_data ;
logic [5-1:0] counter32_w, counter32_r;
logic [30:0] data_w, data_r;
logic [3-1:0] counter8_w, counter8_r;
logic finish;
logic data_finish_w, data_finish_r;
logic oen_w, oen_r;
logic sclk;
logic [30:0] reset;
logic [30:0] aa_pathctrl, da_pathctrl;
logic [30:0] power_down_ctrl;
logic [30:0] da_interfaceform;
logic [30:0] samplingctrl, activectrl;
logic sdat_w, sdat_r;

assign reset = {2'b11,1'b1,27'b1_0000_0000_1_0_1111_000_1_0010_1100,1'b0};
assign aa_pathctrl = {1'b0,2'b11,1'b1,27'b1_1010_1000_1_0_0010_000_1_0010_1100};
assign da_pathctrl = {1'b0,2'b11,1'b1,27'b1_0000_0000_1_0_1010_000_1_0010_1100};
assign power_down_ctrl = {1'b0,2'b11,1'b1,27'b1_0000_0000_1_0_0110_000_1_0010_1100};
assign da_interfaceform = {1'b0,2'b11,1'b1,27'b1_0100_0010_1_0_1110_000_1_0010_1100};
assign samplingctrl = {1'b0,2'b11,1'b1,27'b1_1001_1000_1_0_0001_000_1_0010_1100};
assign activectrl = {1'b0,2'b11,1'b1,27'b1_1000_0000_1_0_1001_000_1_0010_1100};    

assign o_finished = finish;
assign o_sdat = sdat_r;
assign o_oen = oen_r;
assign o_sclk = sclk;
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
        5'd0: sclk = 1'b1;
        5'd1: sclk = 1'b1;
        5'd30: sclk = 1'b1;
        5'd31: sclk = 1'b1;
        default: if (!o_finished) begin 
            sclk = i_clk; 
        end
        else begin 
            sclk = 1'b1;
        end
    endcase
end

// decide sdat signals

always_comb begin
    case (counter8_r)
        3'd0: begin 
            data_w = (data_finish_r) ? reset : data_r >> 1; 
        end
        3'd1: begin 
            data_w = (data_finish_r) ? aa_pathctrl : data_r >> 1; 
        end
        3'd2: begin 
            data_w = (data_finish_r) ? da_pathctrl : data_r >> 1; 
        end
        3'd3: begin 
            data_w = (data_finish_r) ? power_down_ctrl : data_r >> 1; 
        end
        3'd4: begin 
            data_w = (data_finish_r) ? da_interfaceform : data_r >> 1; 
        end
        3'd5: begin 
            data_w = (data_finish_r) ? samplingctrl : data_r >> 1; 
        end
        3'd6: begin 
            data_w = (data_finish_r) ? activectrl : data_r >> 1; 
        end
        default: data_w = 31'b0;
    endcase
    sdat_w = (data_finish_r) ? 1'b0 : data_r[0];
end
// decide output enable
always_comb begin
    case (counter32_r)
        5'd9: oen_w = 1'b0;
        5'd18: oen_w = 1'b0;
        5'd27: oen_w = 1'b0;
        default: oen_w = 1'b1; 
    endcase
end
// 3-bits counter and decide data finish
always_comb begin
    if (counter32_r == 5'd31) begin
        if (counter8_r == 3'd7) begin
            counter8_w = counter8_r;
            data_finish_w = 1'b1;
        end
        else begin
            counter8_w = counter8_r + 1;
            data_finish_w = 1'b1;
        end
    end
    else begin
        counter8_w = counter8_r;
        data_finish_w = 1'b0;
    end
end
// decide finish signals
always_comb begin
    if (counter8_r == 3'd7) begin
        finish = 1'b1;
    end
    else begin
        finish = 1'b0;
    end
end
always @ (negedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        counter32_r <= 5'd0;
        counter8_r <= 3'd0;
        oen_r <= 1'b1;
        data_r <= 30'b0;
        data_finish_r <= 1'b1;
        sdat_r <= 1'b1;
    end
    else begin
        counter32_r <= counter32_w;
        counter8_r <= counter8_w;
        oen_r <= oen_w;
        data_r <= data_w;
        data_finish_r <= data_finish_w;
        sdat_r <= sdat_w;
    end
end
endmodule