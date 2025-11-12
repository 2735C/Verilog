`timescale 1ns / 1ps


FA_4 dut(
    .a0(a0),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .b0(b0),
    .b1(b1),
    .b2(b2),
    .b3(b3),
    .cin(cin),

    .s0(s0),
    .s1(s1),
    .s2(s2),
    .s3(s3),
    .cout(cout)
);
integer i, k;

    initial begin
        cin =0;
            
        for (i=0; i<16; i=i+1) begin
            
            {a3, a2, a1, a0} = i;
            for (k=0; k<16; k=k+1) begin
                {b3, b2, b1, b0} = k;
            #10;
            end
            
         end
        #10 $finish;
    end
        

endmodule
