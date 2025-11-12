`timescale 1ns / 1ps



module tb_uart ();

    reg clk, rst, start;
    wire baud_tick, tx;

    baudrate dut0 (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    uart_tx dut1 (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .start(start),
        .din(8'h30),
        .o_tx(tx)
    );

    always #5 clk = ~clk;  //100MHz

    initial begin
        #0;
        clk   = 0;
        rst   = 1'b1;
        start = 1'b0;
        #20;
        rst = 1'b0;
        #20 start = 1'b1;
        #10 start = 1'b0;
        #100000;
        $stop;
    end
endmodule
