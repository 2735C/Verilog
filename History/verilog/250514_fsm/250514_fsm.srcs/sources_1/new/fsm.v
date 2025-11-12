`timescale 1ns / 1ps

module fsm (
    input        clk,
    input        reset,
    input        sw,
    output reg [1:0] led
);

    // 상태 정의.
    parameter STOP  = 1'b0, RUN = 1'b1;
    reg c_state, n_state; // c_state : current state, n_state : next state

    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= 1'b0;
        end else begin
            c_state <= n_state;
        end       
    end

    // next state Combinational Logic
    always @(*) begin  // c_state 만 보는 건 약간 위험함. 왜?
        n_state = c_state; // 이게 있으면 default가 없어도 됨. best이며 default 와 중복 존재 해도 괜찮음. 
        //초기화 안 하고 default만 추가하면 합성기 판단하에 래치가 생길 수도 있음.
        case (c_state)
            STOP: begin
                // 입력 조건에 따라 next state를 처리한다.
                if (sw == 1'b1) begin
                    n_state = RUN;
                end
            end
            RUN: begin
                if (sw == 1'b0) begin
                    n_state = STOP;
                end
            end
        default: n_state = STOP; // 초기화화
        endcase
    end

    // Output Combination Logic
    always @(*) begin // c_state만 봐도 됨. Moore model 인 경우
    led = 2'b10;
        case (c_state)
            STOP: begin
                led = 2'b10;
            end 
            RUN: begin
                led = 2'b01;
            end
            //default: 
        endcase
    end
    //assign led = (c_state == STOP) ? 2'b10 : 2'b01; 

endmodule
