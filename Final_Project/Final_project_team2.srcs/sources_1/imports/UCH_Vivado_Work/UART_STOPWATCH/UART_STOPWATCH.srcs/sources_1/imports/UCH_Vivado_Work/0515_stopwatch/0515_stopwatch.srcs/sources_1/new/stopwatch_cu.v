`timescale 1ns / 1ps

module stopwatch_cu (
    input clk,
    input rst,
    input i_btn_run,
    input i_btn_stop,
    input i_btn_clear,
    output reg o_runstop,
    output o_clear
);

    // fsm 구조로 CU를 설계
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;

    reg [1:0] state, next;

    assign o_clear = (state == CLEAR) ? 1 : 0;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= STOP;
        end else begin
            state <= next;
        end
    end

    // next state
    always @(*) begin
        next = state;
        case (state)
            STOP: begin
                if (i_btn_run) begin
                    next = RUN;
                end else if (i_btn_clear) begin
                    next = CLEAR;
                end
            end
            RUN: begin
                if (i_btn_stop) begin
                    next = STOP;
                end
            end
            CLEAR: begin
                if (i_btn_clear == 0) begin
                    next = STOP;
                end
            end
            default: next = state;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) o_runstop <= 0;
        else if (next == RUN) o_runstop <= 1;
        else if (next == STOP) o_runstop <= 0;
    end

endmodule

// module stopwatch_cu (
//     input  clk,
//     input  reset,
//     input  i_btn_runstop,
//     input  i_btn_clear,
//     output o_runstop,
//     output o_clear
// );

//     // State 정의
//     parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;
//     reg [1:0] state, next;

//     assign o_clear   = (state == CLEAR) ? 1 : 0;
//     assign o_runstop = (state == RUN) ? 1 : 0;

//     // state register
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             state <= STOP;
//         end else begin
//             state <= next;
//         end
//     end

//     // next state
//     always @(*) begin
//         next = state;
//         case (state)
//             STOP: begin
//                 if (i_btn_runstop) begin
//                     next = RUN;
//                 end else if (i_btn_clear) begin
//                     next = CLEAR;
//                 end
//             end
//             RUN: begin
//                 if (i_btn_runstop) begin
//                     next = STOP;
//                 end
//             end
//             CLEAR: begin
//                 if (i_btn_clear) begin
//                     next = STOP;
//                 end
//             end
//             default: next = state;
//         endcase
//     end

//     // output
//     // always @(*) begin
//     //     o_runstop   = 0;
//     //     o_clear = 0;
//     //     case (state)
//     //         STOP: begin
//     //             o_runstop   = 1'b0;
//     //             o_clear = 1'b0;
//     //         end
//     //         RUN: begin
//     //             o_runstop   = 1'b1;
//     //             o_clear = 1'b0;
//     //         end
//     //         CLEAR: begin
//     //             o_clear = 1'b1;
//     //         end
//     //     endcase
//     // end

// endmodule
