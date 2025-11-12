`timescale 1ns / 1ps


module tb_stopwatch_re();
    reg clk, rst; 
    reg btn_clear, btn_run_stop, switch;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    stopwatch_re dut (
        .clk(clk),
        .rst(rst),
        .brnL_Clear(btn_clear),
        .brnR_RunStop(btn_run_stop),
        .switch(switch),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    // Clock generation: 500MHz -> 2ns period
    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        btn_clear = 0;
        btn_run_stop = 0;
        switch = 0;
        #10;
        rst = 0;
        #10;
        btn_run_stop=1;
        #1_000_000; //1msec
        btn_run_stop=0;
        #1000;
        $stop;

    end
endmodule
