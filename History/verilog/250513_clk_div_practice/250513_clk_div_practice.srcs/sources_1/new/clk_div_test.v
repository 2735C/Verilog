`timescale 1ns / 1ps

module clk_div_test (
    input  clk,
    input  reset,
    output clk_div3
);

    reg [2:0] r_count, r_count_neg;


    assign clk_div3 = ((r_count ==2) | (r_count_neg==2));

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_count <= 0;
        end else begin
            if (r_count ==2) begin
                r_count <=0;
            end else begin
                r_count <= r_count +1;
            end
        end
    end

    always @(negedge clk, posedge reset) begin
        if (reset) begin
            r_count_neg <= 0;
        end else begin
            if (r_count_neg ==2) begin
                r_count_neg <=0;
            end else begin
            r_count_neg <= r_count_neg +1;
            end
        end
    end
endmodule
