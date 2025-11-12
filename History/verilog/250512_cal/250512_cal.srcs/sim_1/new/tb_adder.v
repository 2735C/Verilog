`timescale 1ns / 1ps

module tb_calculator ();

    reg clk, reset;
    reg [7:0] a, b;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    calculator dut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    integer i, j;

    always #5 clk = ~clk;  // clk 생성 -> 5ns 마다 반전 -> 주기 10ns

    initial begin
        #0;
        clk = 1'b0;
        reset = 1'b1;  // positive reset
        a = 8'h00;
        b = 8'h00;

        #20 reset = 1'b0;

        for (i = 100; i <= 110; i = i + 1) begin
            for (j = 100; j <= 110; j = j + 1) begin
                a = i;
                b = j;
                #10;
            end
        end
        $stop;
    end
endmodule

