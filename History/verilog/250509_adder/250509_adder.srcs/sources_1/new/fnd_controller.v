`timescale 1ns / 1ps

module fnd_controller (
    input [1:0] select,
    input [8:0] sum,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

wire [3:0] w_bcd, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    
    bcd U_BCD(
    .bcd(w_bcd),
    .fnd_data(fnd_data)
    );

    mux_4x1 U_MUX_4x1(  
    .sel(select),
    .digit_1(w_digit_1),
    .digit_10(w_digit_10),
    .digit_100(w_digit_100),
    .digit_1000(w_digit_1000),
    .bcd(w_bcd),
    .fnd_com(fnd_com)
    );

    digit_splitter U_DS(
        .sum(sum),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );



endmodule
module mux_4x1 (  // 입출력 비트 수 동일일
    input [1:0]sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd,
    output [3:0] fnd_com

);
    reg [3:0] r_bcd;
    assign bcd = r_bcd;
    reg [3:0] r_fnd_com;
    assign fnd_com = r_fnd_com;
    
    // 4:1 mux, always
    always @(*) begin  //* == sel 입력 모두, 순차논리와 조합논리 같이 사용 시 문제 가능성 있음,
        // 조합논리만 쓸 때는 괜춘
        case (sel)
            2'b00: begin
                r_bcd = digit_1; 
                r_fnd_com = 4'b1110;
            end
            2'b01: begin
                r_bcd = digit_10;
                r_fnd_com = 4'b1101;

            end

            2'b10: begin
                r_bcd = digit_100;
                r_fnd_com = 4'b1011;

            end
            2'b11: begin
                r_bcd = digit_1000;
                r_fnd_com = 4'b0111;

            end

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
    // 조합논리 combinational, 행위수준 모델링링
    always @(bcd) begin // 항상 괄호 안의 이벤트가 발생하면 begin부터 end까지 실행하라
        case (bcd)
            4'h00: r_find_data = 8'hc0;
            4'h01: r_find_data = 8'hf9;
            4'h02: r_find_data = 8'ha4;
            4'h03: r_find_data = 8'hb0;
            4'h04: r_find_data = 8'h99;
            4'h05: r_find_data = 8'h92;
            4'h06: r_find_data = 8'h82;
            4'h07: r_find_data = 8'hf8;
            4'h08: r_find_data = 8'h80;
            4'h09: r_find_data = 8'h90;
            default: r_find_data = 8'hff;
        endcase

    end

endmodule
