`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input [8:0] sum,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_bcd, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire w_oclk;
    wire [1:0] fnd_sel;
    // fnd_sel 연결하기 

    clk_div U_CLK_Div (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_oclk)
    );

    counter_4 U_Counter_4 (
        .clk(w_oclk),
        .reset(reset),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)

    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    mux_4x1 U_MUX_4x1 (
        .sel(fnd_sel),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .bcd(w_bcd)
    );

    digit_splitter U_DS (
        .sum(sum),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );



endmodule

//clk divider
//1kHz
module clk_div (
    input  clk,
    input  reset,
    output o_clk
);
    // clk 100_000_000 100MHz, r_count = 100_000 1KHz
    //reg [16:0] r_counter;  //log 2base 에 1000_0000 계산 16.6....2^17 : 17bit 이 필요함함
    reg [$clog2(100_000)-1:0] r_counter;
    reg                        r_clk;
    assign o_clk = r_clk;

    always @(posedge clk, posedge reset) begin  // always 문에서는 항상 reg 타입입
        if (reset) begin
            r_counter <= 0;
            r_clk     <= 1'b0; // reset 조건에서 내가 정한 변수 초기화 필, 신호 등은 bit 수 지정하는 것이 좋음음
        end else begin
            if (r_counter == 100_000-1) begin //1kHz period
                r_counter <= 0;
                r_clk <= 1'b1;  // <= 띄어쓰기 없이 붙여쓰기 
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end

    end

endmodule


// 4진 카운터
module counter_4 (
    input        clk,
    input        reset,
    output [1:0] fnd_sel
);
    reg [1:0] r_counter;
    assign fnd_sel = r_counter;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;  //non block
        end else begin
            r_counter <= r_counter +1; //overflow 발생해도 2bit로 설정되어 carry가 보이지 않음 11 -> 00 -> 01 -> 10 반복
        end

    end
endmodule

module decoder_2x4 (
    input [1:0] fnd_sel,
    output reg [3:0] fnd_com

);

    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00: begin
                fnd_com = 4'b1110;
            end
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;

        endcase
    end


endmodule
module mux_4x1 (  // 입출력 비트 수 동일일
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 4:1 mux, always
    always @(*) begin  //*, sel 입력 모두, 순차논리와 조합논리 같이 사용 시 문제 가능성 있음,
        // 조합논리만 쓸 때는 괜춘
        case (sel)
            2'b00: r_bcd = digit_1;
            2'b01: r_bcd = digit_10;
            2'b10: r_bcd = digit_100;
            2'b11: r_bcd = digit_1000;

        endcase


    end


endmodule


module digit_splitter (
    input  [8:0] sum,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1 = sum % 10;
    assign digit_10 = (sum / 10) % 10;
    assign digit_100 = (sum / 100) % 10;
    assign digit_1000 = (sum / 1000) % 10;


endmodule

module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    reg [7:0] r_find_data;
    assign fnd_data = r_find_data;

    // 조합논리
    //wire s;
    //assign s= a^b;
    // 조합논리 combinational, 행위수준 모델링
    always @(bcd) begin // 항상 괄호 안의 이벤트가 발생하면 begin부터 end까지 실행하라
        case (bcd)
            4'h00:   r_find_data = 8'hc0;
            4'h01:   r_find_data = 8'hf9;
            4'h02:   r_find_data = 8'ha4;
            4'h03:   r_find_data = 8'hb0;
            4'h04:   r_find_data = 8'h99;
            4'h05:   r_find_data = 8'h92;
            4'h06:   r_find_data = 8'h82;
            4'h07:   r_find_data = 8'hf8;
            4'h08:   r_find_data = 8'h80;
            4'h09:   r_find_data = 8'h90;
            default: r_find_data = 8'hff;
        endcase

    end

endmodule
