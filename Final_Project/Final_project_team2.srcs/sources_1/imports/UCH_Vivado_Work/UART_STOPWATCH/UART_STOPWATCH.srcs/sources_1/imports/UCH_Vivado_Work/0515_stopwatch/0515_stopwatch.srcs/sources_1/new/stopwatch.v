`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////
/******************************** Top Module *******************************/
//////////////////////////////////////////////////////////////////////////////
module stopwatch (
    input       clk,
    input       rst,
    input       btnL,
    input       btnR,
    input       btnU,
    input       btnD,
    input [1:0] sw,

    input watch_o_clear,
    input watch_o_run,
    input watch_o_stop,
    input watch_o_watch_mode,
    input watch_o_mode,
    input watch_o_up,
    input watch_o_down,
    input watch_o_left,
    input watch_o_right,
    input watch_o_esc,

    input uart_sw,

    output [3:0] led_out,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire w_btnL, w_btnR, w_btnU, w_btnD;
    wire w_runstop, w_clear;

    wire use_uart_mode;
    assign use_uart_mode = uart_sw;  // 스위치로 UART 제어 모드 on/off

    wire [6:0] watch_msec, stop_msec, out_msec;
    wire [5:0] watch_sec, stop_sec, out_sec;
    wire [5:0] watch_min, stop_min, out_min;
    wire [4:0] watch_hour, stop_hour, out_hour;

    wire o_w_btnL, o_w_btnR, o_w_btnU, o_w_btnD;

    // wire btn_L, btn_R, btn_U, btn_D;
    wire btn_clear, btn_run, btn_stop, h_o_stop, btn_moveL, btn_moveR, btn_up, btn_down;

    // assign sw_mode[1] = (watch_o_watch_mode) | sw[1];
    // assign sw_mode[0] = (watch_o_mode) | sw[0];

    reg uart_sw0, uart_sw1;
    reg sw1_check = 0;

    always @(posedge clk or posedge rst) begin
        if (rst || watch_o_esc) begin
            if (uart_sw1 == 1 & !sw1_check) begin
                uart_sw0  <= 0;
                sw1_check <= 1;
            end else begin
                uart_sw0  <= 0;
                uart_sw1  <= 0;
                sw1_check <= 0;
            end
        end else begin
            if (watch_o_mode) uart_sw0 <= ~uart_sw0;
            if (watch_o_watch_mode) uart_sw1 <= ~uart_sw1;
        end
    end

    wire [1:0] sw_mode;

    assign sw_mode[0] = use_uart_mode ? uart_sw0 : sw[0];
    assign sw_mode[1] = use_uart_mode ? uart_sw1 : sw[1];
    // assign sw_mode[0] = uart_sw0 | sw[0];
    // assign sw_mode[1] = uart_sw1 | sw[1];
    // assign sw_mode[0] = uart_sw0 ? 1 : sw[0];
    // assign sw_mode[1] = uart_sw1 ? 1 : sw[1];


    LED U_LED (
        .sw (sw_mode),
        .led(led_out)
    );

    btn_debounce U_btn_left (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );

    btn_debounce U_btn_right (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );

    btn_debounce U_btn_up (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),
        .o_btn(w_btnU)
    );

    btn_debounce U_btn_down (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );

    // assign btn_L      = w_btnL | watch_o_clear | watch_o_left;
    // assign btn_R      = w_btnR | watch_o_run | watch_o_stop | watch_o_right ;
    // assign btn_U      = w_btnU | watch_o_up;
    // assign btn_D      = w_btnD | watch_o_down;

    assign btn_clear = w_btnL | watch_o_clear;
    assign btn_run   = w_btnR | watch_o_run;
    assign btn_stop  = w_btnR | watch_o_stop;

    assign btn_moveL = w_btnL | watch_o_left;
    assign btn_moveR = w_btnR | watch_o_right;
    assign btn_up    = w_btnU | watch_o_up;
    assign btn_down  = w_btnD | watch_o_down;

    stopwatch_cu U_StopWatch_CU (
        .clk(clk),
        .rst(rst | watch_o_esc),
        .i_btn_run(btn_run),
        .i_btn_stop(btn_stop),
        .i_btn_clear(btn_clear),
        .o_runstop(w_runstop),
        .o_clear(w_clear)
    );

    stopwatch_dp U_StopWatch_DP (
        .clk(clk),
        .rst(rst | watch_o_esc),
        .run_stop(w_runstop),
        .clear(w_clear),
        .msec(stop_msec),
        .sec(stop_sec),
        .min(stop_min),
        .hour(stop_hour)
    );

    realwatch_cu U_RealWatch_CU (
        .clk(clk),
        .rst(rst | watch_o_esc),
        .i_up(btn_up),
        .i_down(btn_down),
        .i_move_left(btn_moveL),
        .i_move_right(btn_moveR),
        .o_up(o_w_btnU),
        .o_down(o_w_btnD),
        .o_move_right(o_w_btnR),
        .o_move_left(o_w_btnL)
    );


    realwatch_dp U_RealWatch_DP (
        .clk(clk),
        .rst(rst | watch_o_esc),
        .up(o_w_btnU),
        .down(o_w_btnD),
        .moveL(o_w_btnL),
        .moveR(o_w_btnR),
        .msec(watch_msec),
        .sec(watch_sec),
        .min(watch_min),
        .hour(watch_hour)
    );

    mux_2x1_watch_stopwatch U_mux_2x1_watch_stopwatch (
        .sel(sw_mode[1]),
        .s_msec(stop_msec),
        .s_sec(stop_sec),
        .s_min(stop_min),
        .s_hour(stop_hour),
        .w_msec(watch_msec),
        .w_sec(watch_sec),
        .w_min(watch_min),
        .w_hour(watch_hour),
        .o_msec(out_msec),
        .o_sec(out_sec),
        .o_min(out_min),
        .o_hour(out_hour)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(rst | watch_o_esc),
        .sw_mode(sw_mode[0]),
        .msec(out_msec),
        .sec(out_sec),
        .min(out_min),
        .hour(out_hour),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );


endmodule

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



module mux_2x1_watch_stopwatch (
    input sel,
    input [6:0] s_msec,
    input [5:0] s_sec,
    input [5:0] s_min,
    input [4:0] s_hour,
    input [6:0] w_msec,
    input [5:0] w_sec,
    input [5:0] w_min,
    input [4:0] w_hour,
    output reg [6:0] o_msec,
    output reg [5:0] o_sec,
    output reg [5:0] o_min,
    output reg [4:0] o_hour
);
    always @(*) begin
        case (sel)
            1'b0: begin
                o_msec = w_msec;
                o_sec  = w_sec;
                o_min  = w_min;
                o_hour = w_hour;
            end
            1'b1: begin
                o_msec = s_msec;
                o_sec  = s_sec;
                o_min  = s_min;
                o_hour = s_hour;
            end
        endcase
    end
endmodule

module LED (
    input [1:0] sw,
    output reg [3:0] led
);
    always @(*) begin
        case (sw)
            2'b00:   led = 4'b0001;
            2'b01:   led = 4'b0010;
            2'b10:   led = 4'b0100;
            2'b11:   led = 4'b1000;
            default: led = 0;
        endcase
    end


endmodule
