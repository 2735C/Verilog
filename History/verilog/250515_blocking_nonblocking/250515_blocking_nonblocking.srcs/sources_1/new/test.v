`timescale 1ns / 1ps


module blk;
    reg clk,a,b;
     initial begin
        a = 0;
        b= 1;
        clk = 0;
     end

     always 
        clk = #5 ~clk;

    always @(posedge clk) begin
        a = b;
        b = a;          
    end
endmodule



module non_blk;
    reg clk,a,b;
     initial begin
        a = 0;
        b= 1;
        clk = 0;
     end

     always 
        clk = #5 ~clk;

    always @(posedge clk) begin
        a <= b;
        b <= a;          
    end
endmodule

module MUX21_case ( input [1:0] a, input [1:0] b, input [1:0] c, input [1:0] d, input [1:0]sel, output [1:0] out);
    
    /*
    always @(*) begin
        case(sel)
        0: out = a;
        1: out = b;
        2: out = c;
        3: out = d;
        endcase
    end 
    */
     /*
    always @(*) begin
        if (sel ==0) out a;
        else if (sel ==1) out b;
        else if (sel ==2) out b;
        else out d;

    end
    */
    assign out = (sel ==0) ? a: ((sel == 1) ?  b : ((sel ==2) ? c : d));

endmodule


        