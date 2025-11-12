
`timescale 1ns / 1ps


module stopwatch(
    input        clk,
    input        rst,
    input        brnL_Clear,
    input        brnR_RunStop,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire w_clear, w_runstop;


    stopwatch_cu U_Stopwatch_CU(
    .clk(clk),
    .rst(rst),
    .i_clear(brnL_Clear),
    .i_runstop(brnR_RunStop),
    .o_clear(w_clear),
    .o_runstop(w_runstop)
    );

   stopwatch_dp  U_Stopwatch_DP(
    .clk(clk),
    .rst(rst),
    .run_stop(w_runstop),
    .clear(w_clear),
    .msec(w_msec),
    .sec(w_sec)
);


    fnd_controllr U_FND_CNTL(
    .clk(clk),
    .reset(rst),
    .msec(w_msec),
    .sec(w_sec),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
    );

endmodule

