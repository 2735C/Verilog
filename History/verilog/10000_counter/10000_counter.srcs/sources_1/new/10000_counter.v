`timescale 1ns / 1ps

module top_10000_counter (
    input clk,
    input reset,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    
    wire [13:0] w_count_data;

    counter_10000 U_COUNTER_10000(
        .clk(clk),     
        .reset(reset),   
        .count_data(w_count_data) 
    );

    fnd_controller U_FND_CNTL(
        .clk(clk),
        .reset(reset),
        .count_data(w_count_data),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    
endmodule

//////////////////////////////////////////////////////////////////////////
///////////////////////***** fnd_controllr *****//////////////////////////
//////////////////////////////////////////////////////////////////////////

module fnd_controller (
    input        clk,
    input        reset,
    input  [13:0] count_data,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_bcd;
    wire w_oclk;
    wire [1:0] fnd_sel;

    clk_div U_CLK_DIV (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_oclk)
    );

    counter_4 U_Counter_4 (
        .clk(w_oclk),
        .reset(reset),
        .fnd_sel(fnd_sel)
    );

    digit_spliter U_DS (
        .count_data(count_data),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    Mux_4x1 U_MUX_4x1 (
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .sel(fnd_sel),
        .bcd(w_bcd)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

endmodule
//////////////////////////////////////////////////////////////////////////
//************************************************************************
//////////////////////////////////////////////////////////////////////////

//////////////******** 10,000진 Counter ********///////////// 

module counter_10000 (
    input        clk,     // 클럭
    input        reset,   // 비동기 리셋 (active-low)
    output reg [13:0] count_data  // 14비트 출력
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_data <= 14'd0;
        end else begin
            if (count_data == 14'd9999)
                count_data <= 14'd0;
            else
                count_data <= count_data + 1'b1;
        end
    end

endmodule

/////////////////////////////////////////////////////////////

/////////////////******** Clk divider ********//////////////// 

module clk_div (
    input  clk,
    input  reset,
    output o_clk
);

    // reg [16:0] r_counter;
    reg [$clog2(100_000) - 1:0] r_counter;
    reg r_clk;
    assign o_clk = r_clk;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk     <= 1'b0;
        end else begin
            if (r_counter == 100_000 - 1) begin
                r_counter <= 17'd0;
                r_clk     <= 1'b1;  // 1kHz 클럭 
            end else begin
                r_counter <= r_counter + 1;
                r_clk <= 1'b0;
            end
        end
    end

endmodule

/////////////////////////////////////////////////////////////

/////////////////******** 4진 Counter ********//////////////// 

module counter_4 (
    input        clk,     // 클럭
    input        reset,   // 비동기 리셋 (active-low)
    output [1:0] fnd_sel  // 2비트 출력
);

    reg [1:0] r_counter;
    assign fnd_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 2'b00;  // 리셋 시 0
        end else begin
            r_counter <= r_counter + 2'b01;  // 클럭마다 1씩 증가
        end
    end

endmodule

/////////////////////////////////////////////////////////////

/////////////////******** Decoder_2x4 ********/////////////// 

module decoder_2x4 (
    input [1:0] fnd_sel,
    output reg [3:0] fnd_com
);
    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule
/////////////////////////////////////////////////////////////

///////////////////******** Mux_4x1 ********/////////////////
module Mux_4x1 (
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    input  [1:0] sel,
    output [3:0] bcd
);
    // 4:1 mux, always 구문 -> default 설정 안하면 위험함 (Latch)
    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            default: r_bcd = 4'd0;
        endcase
    end

    // // assign 문법 (삼항 연산자)
    // assign bcd = (sel == 2'b00) ? digit_1    :
    //              (sel == 2'b01) ? digit_10   :
    //              (sel == 2'b10) ? digit_100  :
    //                               digit_1000;

endmodule
/////////////////////////////////////////////////////////////

////////////////******** digit_spliter ********////////////// 

module digit_spliter (
    input  [13:0] count_data,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1    = count_data % 10;
    assign digit_10   = (count_data / 10) % 10;
    assign digit_100  = (count_data / 100) % 10;
    assign digit_1000 = (count_data / 1000) % 10;

endmodule
/////////////////////////////////////////////////////////////

/////////////////////******** bcd ********/////////////////// 

module bcd (
    input [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            4'h00:   fnd_data = 8'hC0;
            4'h01:   fnd_data = 8'hF9;
            4'h02:   fnd_data = 8'hA4;
            4'h03:   fnd_data = 8'hB0;
            4'h04:   fnd_data = 8'h99;
            4'h05:   fnd_data = 8'h92;
            4'h06:   fnd_data = 8'h82;
            4'h07:   fnd_data = 8'hF8;
            4'h08:   fnd_data = 8'h80;
            4'h09:   fnd_data = 8'h90;
            default: fnd_data = 8'hFF;  // 모든 segment off
        endcase
    end

endmodule
/////////////////////////////////////////////////////////////
