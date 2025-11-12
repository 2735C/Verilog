`timescale 1ns / 1ps

module tb_uart_ctrl ();

    reg clk, rst, start, rx;
    wire tx;

    uart_controller U_UART (
        .clk(clk),
        .rst(rst),
        .btn_start(start),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk   = 0;
        rst   = 1;
        start = 0;
        rx =1;
        #20;
        rst = 0;

        #100;
        start = 1'b1;
        #100000; // debounce
        start = 1'b0;
        #2000000;
        
        
        rx = 0;   //start
        #(10416*10);   
        rx=1;     //d0
       #(10416*10);
        rx=0; 
      #(10416*10);
        rx=0;       
      #(10416*10);
        rx=0;   
      #(10416*10);
        rx=1;  
      #(10416*10);
        rx=1; 
      #(10416*10);
        rx=0;   
      #(10416*10);
        rx=0;    //d7
      #(10416*10);
        rx=1;    //stop

        #104160;  

        #2000000;
        $stop;
    end

endmodule
