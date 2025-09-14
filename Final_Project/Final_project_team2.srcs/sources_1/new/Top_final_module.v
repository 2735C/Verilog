`timescale 1ns / 1ps

module Top_final_module (
    input        clk,
    input        rst,
    input  [3:0] sw,     // sw[3:2]: mode_sel, sw[1:0]: sub_mode
    input        btn_U,
    input        btn_D,
    input        btn_L,
    input        btn_R,
    input        rx,
    output       tx,

    input uart_sw,

    input  echo,
    inout  dht11_data,
    output trig,

    output [2:0] state_led,
    output [3:0] led_out,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [1:0] mode_sel = sw[3:2];
    wire [1:0] hw_sub_mode = sw[1:0];

    reg uart_sw0, uart_sw1;
    reg sw1_check;
    wire use_uart_mode = uart_sw;

    wire [1:0] sub_mode = use_uart_mode ? {uart_sw1, uart_sw0} : hw_sub_mode;

    wire btnL_deb, btnR_deb, btnU_deb, btnD_deb;
    wire [7:0] rx_data;
    wire rx_done;
    wire tx_watch, tx_sensor;

    wire w_done_dht11, w_done_sr04;
    wire pulse_done_dht11, pulse_done_sr04;

    wire [6:0] stop_msec, watch_msec;
    wire [5:0] stop_sec, watch_sec;
    wire [5:0] stop_min, watch_min;
    wire [4:0] stop_hour, watch_hour;
    wire [9:0] dist;
    wire [7:0] t_data, rh_data;

    wire o_clear, o_run, o_stop, o_watch_mode, o_mode, o_up, o_down, o_left, o_right, o_esc;

    reg btn_clear_r, btn_run_r, btn_stop_r, btn_moveL_r, btn_moveR_r, btn_up_r, btn_down_r;
    wire btn_clear = btn_clear_r;
    wire btn_run   = btn_run_r;
    wire btn_stop  = btn_stop_r;
    wire btn_moveL = btn_moveL_r;
    wire btn_moveR = btn_moveR_r;
    wire btn_up    = btn_up_r;
    wire btn_down  = btn_down_r;

    always @(posedge clk or posedge rst) begin
        if (rst || o_esc) begin
            uart_sw0 <= 0;
            uart_sw1 <= 0;
            sw1_check <= 0;
        end else begin
            if (uart_sw1 == 1 && !sw1_check) begin
                uart_sw0 <= 0;
                sw1_check <= 1;
            end
            if (o_mode) uart_sw0 <= ~uart_sw0;
            if (o_watch_mode) uart_sw1 <= ~uart_sw1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_clear_r <= 0;
            btn_run_r   <= 0;
            btn_stop_r  <= 0;
            btn_moveL_r <= 0;
            btn_moveR_r <= 0;
            btn_up_r    <= 0;
            btn_down_r  <= 0;
        end else begin
            btn_clear_r <= btnL_deb | o_clear;
            btn_run_r   <= btnR_deb | o_run;
            btn_stop_r  <= btnR_deb | o_stop;
            btn_moveL_r <= btnL_deb | o_left;
            btn_moveR_r <= btnR_deb | o_right;
            btn_up_r    <= btnU_deb | o_up;
            btn_down_r  <= btnD_deb | o_down;
        end
    end

    assign tx = (mode_sel == 2'b00) ? tx_watch : ((mode_sel == 2'b01 || mode_sel == 2'b10) ? tx_sensor : 1'b1);

    btn_debounce U_btn_L (.clk(clk), .rst(rst), .i_btn(btn_L), .o_btn(btnL_deb));
    btn_debounce U_btn_R (.clk(clk), .rst(rst), .i_btn(btn_R), .o_btn(btnR_deb));
    btn_debounce U_btn_U (.clk(clk), .rst(rst), .i_btn(btn_U), .o_btn(btnU_deb));
    btn_debounce U_btn_D (.clk(clk), .rst(rst), .i_btn(btn_D), .o_btn(btnD_deb));

    stop_uart_controller U_STOP (.clk(clk), .rst(rst), .btn_start(), .rx(rx), .rx_done(rx_done), .rx_data(rx_data), .tx(tx_watch));

    command_to_btn U_CMD (.clk(clk), .rst(rst), .rx_data_command(rx_data), .rx_done_command(rx_done),
        .o_clear(o_clear), .o_run(o_run), .o_stop(o_stop), .o_watch_mode(o_watch_mode),
        .o_mode(o_mode), .o_up(o_up), .o_down(o_down), .o_left(o_left), .o_right(o_right), .o_esc(o_esc));

    stopwatch_cu U_CU (.clk(clk), .rst(rst | o_esc), .i_btn_run(btn_run), .i_btn_stop(btn_stop), .i_btn_clear(btn_clear),
        .o_runstop(w_runstop), .o_clear(w_clear));

    stopwatch_dp U_DP (.clk(clk), .rst(rst | o_esc), .run_stop(w_runstop), .clear(w_clear),
        .msec(stop_msec), .sec(stop_sec), .min(stop_min), .hour(stop_hour));

    realwatch_cu U_RCU (.clk(clk), .rst(rst | o_esc), .i_up(btn_up), .i_down(btn_down), .i_move_left(btn_moveL), .i_move_right(btn_moveR),
        .o_up(o_w_btnU), .o_down(o_w_btnD), .o_move_right(o_w_btnR), .o_move_left(o_w_btnL));

    realwatch_dp U_RDP (.clk(clk), .rst(rst | o_esc), .up(o_w_btnU), .down(o_w_btnD), .moveL(o_w_btnL), .moveR(o_w_btnR),
        .msec(watch_msec), .sec(watch_sec), .min(watch_min), .hour(watch_hour));

    reg prev_done_dht11, prev_done_sr04;
    always @(posedge clk) begin
        prev_done_dht11 <= w_done_dht11;
        prev_done_sr04  <= w_done_sr04;
    end

    assign pulse_done_dht11 = w_done_dht11 & ~prev_done_dht11;
    assign pulse_done_sr04  = w_done_sr04 & ~prev_done_sr04;

    // pipeline mux logic
    reg [15:0] selected_data_raw;
    always @(*) begin
        case (mode_sel)
            2'b01: selected_data_raw = {6'd0, dist};
            2'b10: selected_data_raw = {rh_data, t_data};
            default: selected_data_raw = 16'd0;
        endcase
    end

    reg [15:0] selected_data_reg;
    always @(posedge clk or posedge rst) begin
        if (rst)
            selected_data_reg <= 16'd0;
        else
            selected_data_reg <= selected_data_raw;
    end

    sender_uart U_SEND (.clk(clk), .rst(rst), .rx(rx), .i_send_data(selected_data_reg),
        .btn_sender_up(pulse_done_dht11), .btn_sender_down(pulse_done_sr04), .tx(tx_sensor), .tx_done());

    sr04_controller U_SR04 (.clk(clk), .rst(rst), .start(btnD_deb), .echo(echo), .trig(trig), .dist(dist), .dist_done(w_done_sr04));

    dht11_controller U_DHT (.clk(clk), .rst(rst), .start(btnU_deb), .rh_data(rh_data), .t_data(t_data), .dht11_done(w_done_dht11),
        .dht11_valid(), .state_led(state_led), .dht11_io(dht11_data));

    fnd_controller_top U_FND (.clk(clk), .reset(rst), .sw({mode_sel, sub_mode}),
        .msec_s(stop_msec), .sec_s(stop_sec), .min_s(stop_min), .hour_s(stop_hour),
        .msec_r(watch_msec), .sec_r(watch_sec), .min_r(watch_min), .hour_r(watch_hour),
        .dist(dist), .t_data(t_data), .rh_data(rh_data), .fnd_data(fnd_data), .fnd_com(fnd_com));

    LED U_LED (.sw(sub_mode), .led(led_out));

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




// module Top_final_module (
//     input        clk,
//     input        rst,
//     input  [3:0] sw,     // sw[3:2]: mode_sel, sw[1:0]: sub_mode
//     input        btn_U,
//     input        btn_D,
//     input        btn_L,
//     input        btn_R,
//     input        rx,
//     output       tx,

//     input uart_sw,

//     input  echo,
//     inout  dht11_data,
//     output trig,

//     output [2:0] state_led,
//     output [3:0] led_out,
//     output [3:0] fnd_com,
//     output [7:0] fnd_data
// );

//     wire watch_o_clear;
//     wire watch_o_run;
//     wire watch_o_stop;
//     wire watch_o_watch_mode;
//     wire watch_o_mode;
//     wire watch_o_up;
//     wire watch_o_down;
//     wire watch_o_left;
//     wire watch_o_right;
//     wire watch_o_esc;

//     wire [7:0] w_stop_data;
//     wire w_stop_done;

//     wire w_done_dht11, w_done_sr04;

//     wire [6:0] watch_msec, stop_msec, out_msec;
//     wire [5:0] watch_sec, stop_sec, out_sec;
//     wire [5:0] watch_min, stop_min, out_min;
//     wire [4:0] watch_hour, stop_hour, out_hour;

//     wire [9:0] w_dist;
//     wire [7:0] w_t_data, w_rh_data;

//     wire w_runstop, w_clear;
//     wire o_w_btnU, o_w_btnD, o_w_btnR, o_w_btnL;

//     ///////////////////// 스위치 관련 모드 전환 /////////////////////////////
//     wire use_uart_mode;
//     assign use_uart_mode = uart_sw;  // 스위치로 UART 제어 모드 on/off

//     reg uart_sw0, uart_sw1;
//     reg        sw1_check;

//     wire [1:0] sub_mode;
//     wire [1:0] mode_sel = sw[3:2];

//     wire [2:0] w_o_clk;  //demux 추가


//     always @(posedge clk or posedge rst) begin
//         if (rst || watch_o_esc) begin
//             if (uart_sw1 == 1 && !sw1_check) begin
//                 uart_sw0  <= 0;
//                 sw1_check <= 1;
//             end else begin
//                 uart_sw0  <= 0;
//                 uart_sw1  <= 0;
//                 sw1_check <= 0;
//             end
//         end else begin
//             if (watch_o_mode) uart_sw0 <= ~uart_sw0;
//             if (watch_o_watch_mode) uart_sw1 <= ~uart_sw1;
//         end
//     end

//     assign sub_mode[0] = use_uart_mode ? uart_sw0 : sw[0];
//     assign sub_mode[1] = use_uart_mode ? uart_sw1 : sw[1];

//     //////////////////////////// tx 전환용 //////////////////////////////

//     wire tx_watch, tx_sensor;

//     assign tx = (mode_sel == 2'b00) ? tx_watch :
//             (mode_sel == 2'b01 || mode_sel == 2'b10) ? tx_sensor :
//             1'b1;  // idle

//     ////////////////////// 입력 버튼 디바운스 ////////////////////

//     btn_debounce U_btn_left (
//         .clk  (clk),
//         .rst  (rst),
//         .i_btn(btn_L),
//         .o_btn(w_btnL)
//     );

//     btn_debounce U_btn_right (
//         .clk  (clk),
//         .rst  (rst),
//         .i_btn(btn_R),
//         .o_btn(w_btnR)
//     );

//     btn_debounce U_btn_up (
//         .clk  (clk),
//         .rst  (rst),
//         .i_btn(btn_U),
//         .o_btn(w_btnU)
//     );

//     btn_debounce U_btn_down (
//         .clk  (clk),
//         .rst  (rst),
//         .i_btn(btn_D),
//         .o_btn(w_btnD)
//     );

//     assign btn_clear = w_btnL | watch_o_clear;
//     assign btn_run   = w_btnR | watch_o_run;
//     assign btn_stop  = w_btnR | watch_o_stop;

//     assign btn_moveL = w_btnL | watch_o_left;
//     assign btn_moveR = w_btnR | watch_o_right;
//     assign btn_up    = w_btnU | watch_o_up;
//     assign btn_down  = w_btnD | watch_o_down;

//     /////////////////////// 스탑워치 연결부위 ///////////////////

//     stop_uart_controller U_STOP_UART_CNTL (
//         .clk(w_o_clk[0]),
//         .rst(rst),
//         .btn_start(),
//         .rx(rx),
//         .rx_done(w_stop_done),
//         .rx_data(w_stop_data),
//         .tx(tx_watch)
//     );

//     command_to_btn COM_TO_BTN (
//         .clk(w_o_clk[0]),
//         .rst(rst),
//         .rx_data_command(w_stop_data),
//         .rx_done_command(w_stop_done),
//         .o_clear(watch_o_clear),
//         .o_run(watch_o_run),
//         .o_stop(watch_o_stop),
//         .o_watch_mode(watch_o_watch_mode),
//         .o_mode(watch_o_mode),
//         .o_up(watch_o_up),
//         .o_down(watch_o_down),
//         .o_left(watch_o_left),
//         .o_right(watch_o_right),
//         .o_esc(watch_o_esc)
//     );

//     stopwatch_cu U_StopWatch_CU (
//         .clk(w_o_clk[0]),
//         .rst(rst | watch_o_esc),
//         .i_btn_run(btn_run),
//         .i_btn_stop(btn_stop),
//         .i_btn_clear(btn_clear),
//         .o_runstop(w_runstop),
//         .o_clear(w_clear)
//     );

//     stopwatch_dp U_StopWatch_DP (
//         .clk(w_o_clk[0]),
//         .rst(rst | watch_o_esc),
//         .run_stop(w_runstop),
//         .clear(w_clear),
//         .msec(stop_msec),
//         .sec(stop_sec),
//         .min(stop_min),
//         .hour(stop_hour)
//     );

//     realwatch_cu U_RealWatch_CU (
//         .clk(w_o_clk[0]),
//         .rst(rst | watch_o_esc),
//         .i_up(btn_up),
//         .i_down(btn_down),
//         .i_move_left(btn_moveL),
//         .i_move_right(btn_moveR),
//         .o_up(o_w_btnU),
//         .o_down(o_w_btnD),
//         .o_move_right(o_w_btnR),
//         .o_move_left(o_w_btnL)
//     );


//     realwatch_dp U_RealWatch_DP (
//         .clk(w_o_clk[0]),
//         .rst(rst | watch_o_esc),
//         .up(o_w_btnU),
//         .down(o_w_btnD),
//         .moveL(o_w_btnL),
//         .moveR(o_w_btnR),
//         .msec(watch_msec),
//         .sec(watch_sec),
//         .min(watch_min),
//         .hour(watch_hour)
//     );

//     /////////////////////////////// 센서 sender 공유 ///////////////////////

//     wire [15:0] selected_data;
//     // wire selected_start;

//     reg prev_done_sr04;
//     always @(posedge clk) prev_done_sr04 <= w_done_sr04;
//     wire pulse_done_sr04 = w_done_sr04 & ~prev_done_sr04;  // 상승엣지 1클럭 펄스

//     reg prev_done_dht11;
//     always @(posedge clk) prev_done_dht11 <= w_done_dht11;
//     wire pulse_done_dht11 = w_done_dht11 & ~prev_done_dht11;


//     // assign selected_start = (mode_sel == 2'b01) ? pulse_done_sr04 :
//     //                     (mode_sel == 2'b10) ? pulse_done_dht11 : 1'b0;

//     assign selected_data  = (mode_sel == 2'b01) ? w_dist : (mode_sel == 2'b10) ? ({w_rh_data, w_t_data}) : 16'd0;

//     sender_uart U_sender_uart (
//         .clk(clk),
//         .rst(rst),
//         .rx(rx),
//         .i_send_data(selected_data),
//         .btn_sender_up(w_done_dht11),
//         .btn_sender_down(w_done_sr04),
//         .tx(tx_sensor),
//         .tx_done()
//     );

//     ////////////////////////////// sro4 /////////////////////////////////
//     sr04_controller U_SR04 (
//         .clk(w_o_clk[1]),
//         .rst(rst),
//         .start(w_btnD),
//         .echo(echo),
//         .trig(trig),
//         .dist(w_dist),
//         .dist_done(w_done_sr04)

//     );

//     ////////////////////////////// dht11 //////////////////////////////////
//     dht11_controller U_DHT (
//         .clk        (w_o_clk[2]),
//         .rst        (rst),
//         .start      (w_btnU),
//         .rh_data    (w_rh_data),
//         .t_data     (w_t_data),
//         .dht11_done (w_done_dht11),  // 필요하면 연결
//         .dht11_valid(),              // 필요하면 연결
//         .state_led  (state_led),     // 얘는 베이시스 [15:13] 쓰면 됨 
//         .dht11_io   (dht11_data)
//     );

//     /////////////////////////// fnd final /////////////////////

//     fnd_controller_top U_FND (
//         .clk(clk),
//         .reset(rst),
//         .sw({mode_sel, sub_mode}),

//         .msec_s(stop_msec),
//         .sec_s (stop_sec),
//         .min_s (stop_min),
//         .hour_s(stop_hour),
//         .msec_r(watch_msec),
//         .sec_r (watch_sec),
//         .min_r (watch_min),
//         .hour_r(watch_hour),

//         .dist(w_dist),
//         .t_data(w_t_data),
//         .rh_data(w_rh_data),

//         .fnd_data(fnd_data),
//         .fnd_com (fnd_com)
//     );

//     LED U_LED_WATCH (
//         .sw (sub_mode),  // 이거는 sw[1:0] 의 stopwatch 모드에 따른 led
//         .led(led_out)    // 베이시스 [3:0] 할당당
//     );

//     demux U_demux_3 (  //demux 추가
//         .clk(clk),
//         .sw(sw),
//         .o_clk(w_o_clk)
//     );

// endmodule


// module demux (  // demux 추가
//     input clk,
//     input [3:0] sw,
//     output [2:0] o_clk
// );

//     reg clk_stw, clk_sr04, clk_hdt;

//     assign o_clk = {clk_hdt, clk_sr04, clk_stw};

//     always @(*) begin
//         clk_stw  = (sw[3:2] == 2'b00) ? clk : 0;
//         clk_sr04 = (sw[3:2] == 2'b01) ? clk : 0;
//         clk_hdt  = (sw[3:2] == 2'b10) ? clk : 0;
//     end

// endmodule



// module LED (
//     input [1:0] sw,
//     output reg [3:0] led
// );
//     always @(*) begin
//         case (sw)
//             2'b00:   led = 4'b0001;
//             2'b01:   led = 4'b0010;
//             2'b10:   led = 4'b0100;
//             2'b11:   led = 4'b1000;
//             default: led = 0;
//         endcase
//     end
// endmodule

