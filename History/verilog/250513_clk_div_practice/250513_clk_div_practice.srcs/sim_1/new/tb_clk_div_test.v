`timescale 1ns / 1ps

module tb_clk_div_test();


    reg clk, reset;
    wire clk_div;

    clk_div_test dut(
    .clk(clk),
    .reset(reset),
    .clk_div3(clk_div3)

);

    always #5 clk = ~clk;

    initial begin
        #0;
        reset = 1'b1;
        clk = 1'b0;
        #20;
        reset = 1'b0;
         $stop;
    end


endmodule
