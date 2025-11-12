`timescale 1ns / 1ps

//calculator
module calculator (
    input  [7:0] a,
    input  [7:0] b,
    input  [1:0] select,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [7:0] w_sum;
    wire [8:0] w_s;
    wire carry;
    assign w_s = {carry, w_sum[7:0]}; 

    fnd_controller U_FND_CNTR (
        .sum(w_s),
        .select(select), 
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    Adder U_ADDER (
        .a(a),
        .b(b),
        .s(w_sum),
        .cout(carry)
    );

endmodule

// 8bit adder
module Adder (
    input  [7:0] a,
    input  [7:0] b,
    //    input        cin,
    output [7:0] s,
    output       cout
);

    wire w_c;

    full_adder_4bit U_FA4_H (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(w_c),
        .s(s[7:4]),
        .cout(cout)

    );
    full_adder_4bit U_FA4_L (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .s(s[3:0]),
        .cout(w_c)

    );

endmodule



module full_adder_4bit (
    input  [3:0] a,    //intput wire 4bit a
    input  [3:0] b,
    input        cin,
    output [3:0] s,
    output       cout

);
    wire w_c0, w_c1, w_c2;

    full_adder U_FA3 (
        .a(a[3]),
        .b(b[3]),
        .cin(w_c2),
        .s(s[3]),
        .cout(cout)
    );
    full_adder U_FA2 (
        .a(a[2]),
        .b(b[2]),
        .cin(w_c1),
        .s(s[2]),
        .cout(w_c2)
    );

    full_adder U_FA1 (
        .a(a[1]),
        .b(b[1]),
        .cin(w_c0),
        .s(s[1]),
        .cout(w_c1)
    );
    full_adder U_FA0 (
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .s(s[0]),
        .cout(w_c0)
    );

endmodule


module full_adder (
    input  a,
    input  b,
    input  cin,
    output s,
    output cout
);

    wire s_1, c_1, c_2;
    //instance 화, 실체화

    assign cout = c_1 | c_2;

    half_adder HA2 (
        .a(s_1),
        .b(cin),
        .s(s),
        .c(c_2)
    );

    half_adder HA1 (
        .a(a),
        .b(b),
        .s(s_1),
        .c(c_1)
    );



endmodule

module half_adder (
    input  a,
    input  b,
    output s,
    output c
);

    // assign s = a ^ b;
    xor (s, a, b);  // (출력, 입력 1, 입력 2, ....)
    and (c, a, b);  // 비트 연산과 속도 차이 X

endmodule
    /*
module full_adder_8bit (
    input  [7:0] a,    //intput wire 4bit a
    input  [7:0] b,
    input        cin,
    output [7:0] s,
    output       cout

);
    wire [6:0]w_c;

    full_adder U_FA7 (
        .a(a[7]),
        .b(b[7]),
        .cin(w_c[6]),
        .s(s[7]),
        .cout(cout)
    );
    full_adder U_FA6 (
        .a(a[6]),
        .b(b[6]),
        .cin(w_c[5]),
        .s(s[6]),
        .cout(w_c[6])
    );

    full_adder U_FA5 (
        .a(a[5]),
        .b(b[5]),
        .cin(w_c[4]),
        .s(s[5]),
        .cout(w_c[5])
    );
    full_adder U_FA4 (
        .a(a[4]),
        .b(b[4]),
        .cin(w_c[3]),
        .s(s[4]),
        .cout(w_c[4])
    );

    full_adder U_FA3 (
        .a(a[3]),
        .b(b[3]),
        .cin(w_c[2]),
        .s(s[3]),
        .cout(w_c[3])
    );
    full_adder U_FA2 (
        .a(a[2]),
        .b(b[2]),
        .cin(w_c[1]),
        .s(s[2]),
        .cout(w_c[2])
    );

    full_adder U_FA1 (
        .a(a[1]),
        .b(b[1]),
        .cin(w_c[0]),
        .s(s[1]),
        .cout(w_c[1])
    );
    full_adder U_FA0 (
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .s(s[0]),
        .cout(w_c[0])
    );
*/