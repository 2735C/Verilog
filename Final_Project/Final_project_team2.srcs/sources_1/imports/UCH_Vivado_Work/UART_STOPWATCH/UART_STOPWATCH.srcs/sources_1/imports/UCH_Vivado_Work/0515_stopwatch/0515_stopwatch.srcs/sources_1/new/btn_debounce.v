`timescale 1ns / 1ps

module btn_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    parameter F_COUNT = 10_000;
    // 10kHz clk devide
    reg [$clog2(F_COUNT)-1:0] r_counter;

    // reg state, next;
    reg [7:0] q_reg, q_next;  // shift register
    reg  r_edge_q;
    wire w_debounce;

    // clk div
    reg  r_10khz;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_10khz   <= 0;
        end else begin
            if (r_counter == F_COUNT - 1) begin
                r_counter <= 0;
                r_10khz   <= 1'b1;
            end else begin  // 10khz 1tick.
                r_counter <= r_counter + 1;
                r_10khz   <= 1'b0;
            end
        end
    end

    // state logic, shift register 
    // debounce
    always @(posedge r_10khz, posedge rst) begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    // next logic
    always @(i_btn, q_reg, r_10khz) begin  // event i_btn, q_reg
        // q_reg 현재의 상위 7비트를 다음 하위 7비트에 넣고,
        // 최상에는 i_btn을 넣어라
        q_next = {i_btn, q_reg[7:1]};  // 8shift 의 동작 설명.
    end

    // 8 input AND gate
    assign w_debounce = &q_reg;

    // edge _ detector  , 100MHz
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_edge_q <= 1'b0;
        end else begin
            r_edge_q <= w_debounce;
        end
    end

    // 최종 출력 rising edge
    assign o_btn = w_debounce & (~r_edge_q);

endmodule
