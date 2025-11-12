`timescale 1ns / 1ps


// 시뮬레이션 환경 모듈
// 내가 설계한 모듈을 test하기 위해서 
module tb_project_adder ();
    //테스트 할 모듈의 input은 reg로 입력
    // 출력은 wire
    reg [7:0] a, b;
    reg  [1:0] select;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;



    calculator dut (
        .a(a),  //input  [7:0] a
        .b(b),  //input  [7:0] b
        .select(select),  //input  [1:0] select
        .fnd_data(fnd_data),  //output [7:0] fnd_data,
        .fnd_com(fnd_com)  //output [3:0] fnd_com
    );

    integer i, j, k;

    //initial 
    initial begin
        #0; // 0 delay * time scale 시간 (ns) begin end format에서는 시간은 누적. 
        a = 0;  // 8bit 전체가 초기화 된다.
        b = 100;  //[bit]'[진수][값]
        select =0;

        for (i = 0; i < 100; i = i + 10) begin
            for (j = 100; j <= 200; j = j + 10) begin
                for (k = 0; k <4; k = k + 1) begin
                    
                    select =k;
                    a = i;
                    b = j;
                    select =k;
                    #10;
                end
            end

        end
        $stop;
    end




endmodule
/*
module tb_adder ();
    //테스트 할 모듈의 input은 reg로 입력
    // 출력은 wire
    reg [7:0] a, b;
    wire [7:0] s;
    wire cout;



    Adder dut (  //dut: design under test, cut, cct
        .a(a),
        .b(b),
        .s(s),
        .cout(cout)
    );

    integer i, j;

    //initial 
    initial begin
        #0; // 0 delay * time scale 시간 (ns) begin end format에서는 시간은 누적. 
        a = 0;  // 8bit 전체가 초기화 된다.
        b = 8'h00;  //[bit]'[진수][값]

        for (i = 0; i < 100; i = i + 10) begin
            for (j = 100; j <= 200; j = j + 10) begin
                a = i;
                b = j;
                #10;
            end

        end
    
    $finish;
    $stop;


    end




endmodule
*/
