`timescale 1ns / 1ps

module Mealy_FSM( 
    input clk,
    input rst, input din_bit,
    output dout_bit 
    );

    reg [2:0] state_reg, next_state;

    // 상태 선언
    parameter start = 3'b000;
    parameter rd0_once = 3'b001;
    parameter rd1_once = 3'b010;
    parameter rd0_twice = 3'b011;
    parameter rd1_twice = 3'b100;

    // 다음 상태 결정을 위한 always 조합 회로 블록
    always @(state_reg or din_bit) begin
        case(state_reg)
        start :     if      (din_bit ==0)      next_state = rd0_once;  // state: 0 input  0 -> 1
                    else if (din_bit ==1)      next_state = rd1_once;  // state: 0 input  1 -> 2
                    else                       next_state = start;     // state: 0 input    -> 0
        rd0_once :  if      (din_bit ==0)      next_state = rd0_twice; // state: 1 input  0 -> 3
                    else if (din_bit ==1)      next_state = rd1_once;  // state: 1 input  1 -> 2
                    else                       next_state = start;     // state: 1 input    -> 0
        rd1_once :  if      (din_bit ==0)      next_state = rd0_twice; // state: 2 input  0 -> 3
                    else if (din_bit ==1)      next_state = rd1_once;  // state: 2 input  1 -> 2
                    else                       next_state = start;     // state: 2 input    -> 0
        rd0_twice : if      (din_bit ==0)      next_state = rd0_once;  // state: 3 input  0 -> 1
                    else if (din_bit ==1)      next_state = rd1_twice; // state: 3 input  1 -> 4
                    else                       next_state = start;     // state: 3 input    -> 0
        rd1_twice : if      (din_bit ==0)      next_state = rd0_once;  // state: 4 input  0 -> 1
                    else if (din_bit ==1)      next_state = rd1_twice; // state: 4 input  1 -> 4
                    else                       next_state = start;     // state: 4 input    -> 0
        default :                              next_state = start;     //                   -> 0
        endcase 
    end

    // 상태 레지스터를 위한 always 순차 회로 블록록
    always @(posedge clk, posedge rst) begin
        if (rst ==1 ) state_reg <= start;
        else          state_reg <= next_state;
    end

    // Output combinational logic 출력값 결정
    
    assign dout_bit = (((state_reg ==rd0_twice) && (din_bit ==0) || (state_reg ==rd1_twice) && (din_bit ==1))) ? 1: 0;
    /*
    //Moore로 변환
    // Output combinational logic 출력값 결정
    assign dout_bit = (state_reg ==rd0_twice) || (state_reg ==rd1_twice) ? 1: 0;
    */

endmodule
