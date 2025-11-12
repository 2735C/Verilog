`timescale 1ns / 1ps


module stopwatch_re(
    input        clk,
    input        rst,
    input        brnL_Clear,
    input        brnR_RunStop,
    input        switch,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;
    wire w_clear, w_runstop;
    wire w_db_clear, w_db_runstop;

    btn_debounce_0519 U_b_clear(
        .clk(clk),
        .rst(rst),
        .i_btn(brnL_Clear),
        .o_btn(w_db_clear)
    );

    btn_debounce_0519 U_b_runtstop(
        .clk(clk),
        .rst(rst),
        .i_btn(brnR_RunStop),
        .o_btn(w_db_runstop)
    );

    stopwatch_cu U_Stopwatch_CU(
    .clk(clk),
    .rst(rst),
    .i_clear(w_db_clear),
    .i_runstop(w_db_runstop),
    .o_clear(w_clear),
    .o_runstop(w_runstop)
    );

   stopwatch_dp  U_Stopwatch_DP(
    .clk(clk),
    .rst(rst),
    .run_stop(w_runstop),
    .clear(w_clear),
    .msec(w_msec),
    .sec(w_sec),
    .min(w_min),
    .hour(w_hour)
);


    fnd_controllr U_FND_CNTL(
    .clk(clk),
    .reset(rst),
    .msec(w_msec),
    .sec(w_sec),
    .min(w_min),
    .hour(w_hour),
    .switch(switch),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
    );

endmodule
