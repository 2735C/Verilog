`timescale 1ns / 1ps

module tb_10000_counter();
    reg clk, reset;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    TOP_10000_counter dut(
    .clk(clk),
    .reset(reset),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;  // clk 생성 -> 5ns 마다 반전 -> 주기 10ns 100MHz 1KHz 1msec

    initial begin
        #0;
        clk = 1'b0;
        reset = 1'b1;  // positive reset

        #20 reset = 1'b0;

        $stop;
    end
endmodule


