`timescale 1ns / 1ps


module gates(
    input a,
    input b,
    output y0,
    output y1,
    output y2,
    output y3,
    output y4,
    output y5
);

    // gates
    assign y0 = a & b;
    assign y1 = a | b;
    assign y2 = ~ (a & b);
    assign y3 = ~ (a | b);
    assign y4 = a ^ b;  //exor
    assign y5 = ~ a;

endmodule
