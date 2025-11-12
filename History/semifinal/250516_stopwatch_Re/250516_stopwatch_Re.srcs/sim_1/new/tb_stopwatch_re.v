`timescale 1ns / 1ps


module tb_stopwatch_re();
    reg clk, rst, clear, run_stop, switch;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    stopwatch_re dut (
        .clk(clk),
        .rst(rst),
        .brnL_Clear(clear),
        .brnR_RunStop(run_stop),
        .switch(switch),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    // Clock generation: 500MHz -> 2ns period
    always #2 clk = ~clk;

    initial begin
        // 초기화
        clk = 0;
        rst = 1;
        clear = 0;
        run_stop = 0;
        switch = 0;

        // Reset pulse
        #10;
        rst = 0;

        // ▶️ 스톱워치 시작 (run_stop 누름)
        #20;
        run_stop = 1;    // 누름
        #20;
        run_stop = 0;
        #2000;
        // ⏸ 중간에 일시정지 (run_stop 다시 누름) 및 리셋셋
        run_stop = 1;
        #20;
        run_stop = 0;
        #100;
        clear = 1;
        #20;
        clear = 0;
        #100;
        clear = 1;
        #20;
        clear = 0;
        #100;
        run_stop = 1;
        #20;
        run_stop = 0;
        #100;
        #100;
        switch = 1;
        #100
        switch = 0;
        #100
        switch = 1;        
        #1000;
        switch = 0;
        #120_000_000;
        switch = 1;
        #120_000_00;
        switch = 0;



        // 시뮬레이션 종료
        $finish;
    end
endmodule
