`timescale 1ns / 1ps

module TOP_10000_counter(
    input clk,
    input reset,
    input [1:0] sw,
    output [7:0] fnd_data,
    output [3:0] fnd_com
    );
    
    wire [13:0] w_count_data;
    wire  w_clk_100hz;


    // sw 수정 start
    wire w_clear;
    wire w_run_stop_clk;

    assign w_run_stop_clk = clk & sw[0];
    assign w_clear = reset | sw[1];
    // sw 수정 end

    clk_div_100hz #(.F_COUNT (100_000_000))U_CLK_DIV_100 (
    .clk(w_run_stop_clk),
    .reset(w_clear),
    .o_clk_100hz(w_clk_100hz)
);

    counter_1000 U_COUNTER_10000(
    .clk(w_clk_100hz), 
    .reset(w_clear),
    .count_data(w_count_data)
    );

    fnd_controllr U_FND_CNTL(
    .clk(clk),
    .reset(reset),
    .count_data(w_count_data),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
    );


endmodule


module clk_div_100hz #(parameter F_COUNT = 1_000_000)(
    input  clk,
    input  reset,
    output o_clk_100hz
);

    //parameter F_COUNT = 1_000_000;
    reg    [$clog2(F_COUNT)-1:0] r_count;
    reg     r_clk;
    assign o_clk_100hz = r_clk;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_count <=0;
            r_clk <=0;
        end else begin
            if (r_count == F_COUNT -1) begin
                r_count <= 0;
                r_clk <= 1'b1;
            end else if (r_count >= F_COUNT/2) begin // duty 50%
                r_count = r_count + 1;
                r_clk <= 1'b0;
            end else begin // 합성기가 이상한 값 넣는 것을 방지하기 위해 일단 모든 경우를 채우기 위해 else로 마무리, 조건에 부합할 때만 r_clk 설정
                r_count = r_count + 1;
            end
        end
    end
endmodule

module counter_1000 (
    input clk, 
    input reset,
    output [13:0] count_data
);

    // 10000
    reg [13:0] r_counter;
    assign count_data = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if (r_counter == 10000 -1) begin
                r_counter <= 0;
            end else begin 
                r_counter = r_counter + 1;
            end

        end
    end
    
endmodule
