`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/12 16:31:18
// Design Name: 
// Module Name: counter_10000
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module top_10000_counter(
    input clk,
    input reset,
    output [7:0] fnd_data,
    output [3:0] fnd_com

);
wire [13:0] 

counter_10000(
    .clk(clk),
    .reset(reset),
    .count_data(w_count_data)

    );

fnd_controller U_FND_CNTL(
    .clk(clk),
    .reset(reset),
    .count_data(),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
);
endmodule


module counter_10000(
    input clk,
    input reset,
    output [13:0] count_data

    );

    //10000
    reg [13:0] r_counter;

    assign count_data = r_counter;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
        end else begin
            if(r_counter ==10000-1) begin
                r_counter <=0;
            end else begin
                r_counter = r_counter +1;
            end
        end

    end
endmodule
