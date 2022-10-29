// ----------------------------------------------------------------------                            
// counter module with upper bound
// ----------------------------------------------------------------------

module BoundedCounter (
    input        i_rst_n,
    input        i_clk,
    input  [3:0] i_bound,
    input        i_pause,
    output [3:0] o_count,
    output       o_reach_bound
);

reg  [3:0] count, next_count;

assign o_count = count;
assign o_reach_bound = (count == i_bound);

always @ (*) begin
    if (i_pause) begin
        next_count = count;
    end
    else begin
        if (count == i_bound) begin // reach upper bound; restart from 0
            next_count = 0;
        end
        else begin
            next_count = count + 1;
        end
    end
end

always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        count <= 0;
    end
    else begin
        count <= next_count;
    end
end

endmodule
