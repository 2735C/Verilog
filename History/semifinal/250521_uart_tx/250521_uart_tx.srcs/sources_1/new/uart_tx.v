`timescale 1ns / 1ps

module uart_tx (
    input        clk,
    input        rst,
    input        baud_tick,
    input        start,
    input  [7:0] din,
    output       o_tx_done,
    output       o_tx_busy,
    output       o_tx
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3, WAIT = 4;

    reg [2:0] c_state, n_state;
    reg tx_reg, tx_next;
    reg [2:0] data_cnt_reg, data_cnt_next;
    reg [3:0] b_cnt_reg, b_cnt_next;
    reg tx_done_reg, tx_done_next;
    reg tx_busy_reg, tx_busy_next;

    //output
    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg;
    assign o_tx_busy = tx_busy_reg;
    //assign o_tx_done = ((c_state == STOP) & (b_cnt_reg == 7)) ? 1'b1: 1'b0; //길게 나옴 이슈. b_count가 7일 동안 계속 나옴. 

    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state      <= 0;
            tx_reg       <= 1'b1;  //출력 초기를 High로
            data_cnt_reg <= 0;  // data bit 전송 반복 구간을 위해서 
            b_cnt_reg    <= 0;  // baud tick 을 0부터 7까지 count
            tx_done_reg  <= 0;
            tx_busy_reg  <= 0;

        end else begin
            c_state      <= n_state;
            tx_reg       <= tx_next;
            data_cnt_reg <= data_cnt_next;
            b_cnt_reg    <= b_cnt_next;
            tx_done_reg  <= tx_done_next;
            tx_busy_reg  <= tx_busy_next;

        end
    end

    //next state CL
    always @(*) begin  // 조합 논리는 * 넣으면 무난
        n_state = c_state;  // 초기화는 case 바깥깥
        tx_next = tx_reg;
        data_cnt_next = data_cnt_reg;
        b_cnt_next    = b_cnt_reg; // 8배수로 만들면 에러가 좋아지긴 해서 만드는 코드임. 
        tx_done_next = 0;
        case (c_state)

            IDLE: begin
                b_cnt_next = 0;
                data_cnt_next = 0;
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tx_busy_next = 1'b0;

                if (start == 1'b1) begin
                    n_state = START;
                    tx_busy_next = 1'b1;
                end
            end
            START: begin
                if (baud_tick == 1'b1) begin
                    tx_next = 1'b0;
                    if (b_cnt_reg == 8) begin  //7-> 8
                        n_state       = DATA;
                        data_cnt_next = 0;
                        b_cnt_next    = 0;
                    end else begin
                        b_cnt_next = b_cnt_reg +1; // 0->1로 바로 떨어지기 때문에 b_cnt_reg = 8로 해줘야 하는 것임.
                    end
                end
            end
            DATA: begin
                tx_next = din[data_cnt_reg]; // if문 안에 들어가면 baud tick이 오기까지 쉬는 구간이 발생한다. (문제)
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin  //7-> 8 
                        if (data_cnt_reg == 3'b111) begin
                            n_state = STOP;
                        end
                        b_cnt_next = 0;
                        data_cnt_next = data_cnt_reg + 1;
                    end else begin
                        b_cnt_next = b_cnt_reg + 1;
                    end

                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin
                        n_state = IDLE;
                        tx_done_next = 1'b1;
                        tx_busy_next = 1'b0;
                    end 
                    b_cnt_next = b_cnt_reg + 1;
                end
            end
        endcase
    end
endmodule

