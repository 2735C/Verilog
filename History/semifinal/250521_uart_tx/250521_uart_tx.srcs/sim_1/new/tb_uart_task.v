`timescale 1ns / 1ps

module tb_uart_task();

    uart_controller (

    .clk(clk),
    .rst(rst),
    .btn_start(start), 
    .tx_din,
    .rx,
    .rx_data,
    .rx_done,
    .tx,
    .tx_done
);

endmodule
