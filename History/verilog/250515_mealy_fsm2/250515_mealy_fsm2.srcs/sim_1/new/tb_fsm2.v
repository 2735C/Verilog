`timescale 1ns / 1ps

module tb_fsm2 ();

    reg clk, reset;
    reg  [2:0] sw;
    wire [2:0] led;

    fsm2 dut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)
    );

    integer i;

    always #5 clk = ~clk;

    initial begin
        #0
        reset = 1'b1;
        clk = 1'b0;
        #20
        reset = 1'b0;

        for (i=0; i<7; i = i+1) begin
            sw = i[2:0];
            #20;
        end
        for (i=0; i<7; i = i+1) begin
            sw = i[2:0];
            #20;
        end
        sw = 3'b000; //IDLE
        #20;
        sw = 3'b111; //ST3
        #20;
        sw = 3'b100; //ST4
        #20;
        reset =1'b1; // reset on goto IDLE
        #20;
        reset =1'b0; // reset off 필수!!!
        #20;
        sw = 3'b000; //IDLE
        #20
        sw = 3'b001; //ST1
        #20;
        sw = 3'b100; //ST4
        #20;
        sw = 3'b101; //ST5
        #20;
        reset =1'b1; // reset goto IDLE
        #20;
        reset =1'b0; // reset off 
        #20;
        sw = 3'b000; //IDLE
        #20

        $stop;

    end
endmodule
