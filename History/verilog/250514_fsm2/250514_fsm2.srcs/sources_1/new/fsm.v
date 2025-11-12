`timescale 1ns / 1ps

module Mealy_FSM2( 
    input clk,
    input reset, input din_bit,
    output dout_bit 
    );

    reg state_reg, next_state;
    reg [2:0] din_reg;

    // 상태 선언
    parameter start = 1'b0;
    parameter ST1 = 1'b0;
    parameter ST2 = 1'b0;
    parameter ST3 = 1'b0;
    parameter ST4 = 1'b1;

    
    // 다음 상태 결정을 위한 always 조합 회로 블록
    always @(state_reg or din_bit) begin
        case(state_reg)
        start :     if      (din_bit ==0)      next_state = ST1;        // state: 0 input  0 -> 0
                    else if (din_bit ==1)      next_state = start;      // state: 0 input  1 -> 0
                    else                       next_state = start;      // state: 0 input    -> 0
        ST1 :       if      (din_bit ==0)      next_state = ST1;        // state: 0 input  0 -> 0
                    else if (din_bit ==1)      next_state = ST2;        // state: 0 input  1 -> 0
                    else                       next_state = start;      // state: 1 input    -> 0
        ST2 :       if      (din_bit ==0)      next_state = ST1;        // state: 0 input  0 -> 0
                    else if (din_bit ==1)      next_state = ST3;        // state: 0 input  1 -> 0
                    else                       next_state = start;      // state: 0 input    -> 0
        ST3 :       if      (din_bit ==0)      next_state = ST4;        // state: 0 input  0 -> 1
                    else if (din_bit ==1)      next_state = start;      // state: 0 input  1 -> 0
                    else                       next_state = start;      // state: 1 input    -> 0
        ST4 :       if      (din_bit ==0)      next_state = ST1;        // state: 1 input  0 -> 0
                    else if (din_bit ==1)      next_state = ST2;        // state: 1 input  1 -> 0
                    else                       next_state = start;      // state: 1 input    -> 0
        default :                              next_state = start;      //                   -> 0
        endcase 
    end


    // 상태 레지스터를 위한 always 순차 회로 블록
    always @(posedge clk, posedge reset) begin
        if (reset ==1 ) begin state_reg <= start; din_reg = 3'b000; end
        else            state_reg <= next_state;
    end

    // Output combinational logic 출력값 결정
    assign dout_bit = ((state_reg == ST3 )&& (din_bit ==0)) ? 1:0;

endmodule