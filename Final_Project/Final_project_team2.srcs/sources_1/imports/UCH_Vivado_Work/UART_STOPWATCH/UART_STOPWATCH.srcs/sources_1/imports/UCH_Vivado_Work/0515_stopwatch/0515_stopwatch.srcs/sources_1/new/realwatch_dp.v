`timescale 1ns / 1ps

module realwatch_dp (
    input        clk,
    input        rst,
    input        up,
    input        down,
    input        moveL,
    input        moveR,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    reg [1:0] sel_pos;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sel_pos <= 2'b00;
        end else begin
            if (moveL) begin
                sel_pos <= (sel_pos == 2'b10) ? 2'b00 : sel_pos + 1;
            end else if (moveR) begin
                sel_pos <= (sel_pos == 2'b00) ? 2'b10 : sel_pos - 1;
            end
        end
    end

    //////////////////////////////오버 언더플로우 처리////////////////////////////////////

    wire sec_up_to_min;
    assign sec_up_to_min = (sel_pos == 2'b00) && up && (sec == 6'd59);

    wire min_up_to_hour;
    assign min_up_to_hour = (sel_pos == 2'b01) && up && (min == 6'd59);

    wire min_down_to_hour;
    assign min_down_to_hour = (sel_pos == 2'b01) && down && (min == 6'd00);

    wire sec_down_to_min;
    assign sec_down_to_min = (sel_pos == 2'b00) && down && (sec == 6'd0);

    wire hour_down_wrap;
    assign hour_down_wrap = (sel_pos == 2'b00) && down && (sec == 6'd0) && (min == 6'd0) && (hour == 5'd0);

    ////////////////////////////////////////////////////////////////////////////////////////////////

    tick_gen_100hz_watch #(
        .FCOUNT(1_000_000)
    ) U_Tick_100hz_Watch (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );
    ///////////////////////////////////////////////////////////
    real_time_counter #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100),
        .TIME_START(0)
    ) U_MSEC_REAL (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .up(),
        .down(),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    ///////////////////////////////////////////////////////////
    real_time_counter #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .TIME_START(0)
    ) U_SEC_REAL (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),
        .up(sel_pos == 2'b00 ? up : 1'b0),
        .down(sel_pos == 2'b00 ? down : 1'b0),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    ///////////////////////////////////////////////////////////
    real_time_counter #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60),
        .TIME_START(0)
    ) U_MIN_REAL (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),
        .up((sel_pos == 2'b01 ? up : 1'b0) || sec_up_to_min),
        .down((sel_pos == 2'b01 ? down : 1'b0) || sec_down_to_min),
        .o_time(min),
        .o_tick(w_hour_tick)
    );
    ///////////////////////////////////////////////////////////
    real_time_counter #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24),
        .TIME_START(12)
    ) U_HOUR_REAL (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),
        .up((sel_pos == 2'b10 ? up : 1'b0) || min_up_to_hour),
        .down(((sel_pos == 2'b10 ? down : 1'b0) || min_down_to_hour || hour_down_wrap)),
        .o_time(hour),
        .o_tick()
    );
endmodule


module real_time_counter #(
    parameter BIT_WIDTH  = 7,
    parameter TICK_COUNT = 100,
    parameter TIME_START = 0
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input                  up,
    input                  down,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);

    reg [$clog2(TICK_COUNT)-1 : 0] count_reg, count_next;
    reg o_tick_reg, o_tick_next;
    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // State Register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg  <= TIME_START;
            o_tick_reg <= 0;
        end else begin
            count_reg  <= count_next;
            o_tick_reg <= o_tick_next;
        end
    end

    // Combination Logic (CL) next stage
    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 1'b0;
        if (up) begin
            if (count_reg == TICK_COUNT - 1) count_next = 0;
            else count_next = count_reg + 1;
        end
        if (down) begin
            if (count_reg == 0) count_next = TICK_COUNT - 1;
            else count_next = count_reg - 1;
        end
        if (i_tick == 1'b1 && count_reg == TICK_COUNT - 1) begin
            count_next  = 0;
            o_tick_next = 1'b1;
        end else if (i_tick == 1'b1) begin
            count_next  = count_reg + 1;
            o_tick_next = 1'b0;
        end

    end

endmodule

//////////////////////////////////////////////////////////////////////////////

module tick_gen_100hz_watch (
    input      clk,
    input      rst,
    output reg o_tick_100
);
    parameter FCOUNT = 1_000_000;

    reg [$clog2(FCOUNT)-1 : 0] r_counter;

    // State Register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                o_tick_100 <= 1'b1; // 카운트 값이 일치했을 때 O_tick을 상승시킴
                r_counter <= 0;
            end else begin
                o_tick_100 <= 1'b0;
                r_counter  <= r_counter + 1;
            end
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////
