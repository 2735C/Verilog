`timescale 1ns / 1ps

module tb_baudrate (); 
 reg clk;
 reg rst;
 wire baud_tick;

 baudrate test_wire_reg(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick)
    );

 always #5 clk =~clk;

 initial begin
  #0;
  rst = 1;
  clk = 0;
  
  #20;
  rst = 0;
  
  #100_000;
  $stop;
 end
endmodule