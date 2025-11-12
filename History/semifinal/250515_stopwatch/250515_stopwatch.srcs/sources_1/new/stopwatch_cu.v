`timescale 1ns / 1ps


module stopwatch(
    input        clk,
    input        rst,
    input        brnL_Clear,
    input        brnR_RunStop,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire w_clear, w_runstop;


    stopwatch_cu U_Stopwatch_CU(
    .clk(clk),
    .rst(rst),
    .i_clear(brnL_Clear),
    .i_runstop(brnR_RunStop),
    .o_clear(w_clear),
    .o_runstop(w_runstop)
    );

   stopwatch_dp  U_Stopwatch_DP(
    .clk(clk),
    .rst(rst),
    .run_stop(w_runstop),
    .clear(w_clear),
    .msec(w_msec),
    .sec(w_sec)
);


    fnd_controllr U_FND_CNTL(
    .clk(clk),
    .reset(rst),
    .msec(w_msec),
    .sec(w_sec),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
    );

endmodule




`timescale 1ns / 1ps


module stopwatch_cu(
    input clk,
    input rst,
    input i_clear,
    input i_runstop,
    output o_clear,
    output o_runstop
    );
     
    parameter STOP = 0,  RUN = 1, CLEAR = 2;
    
    reg [1:0] n_state, c_state;


    //output

    assign o_clear = (c_state == CLEAR) ? 1:0; 
    assign o_runstop = (c_state == RUN) ? 1:0; 

    //sl state register
    always @(posedge clk, posedge rst) begin
        if (rst ) begin 
            c_state <= STOP;
            
        end else begin
             c_state <= n_state; 
        end
    end


    //next_state
    always @(*) begin
        n_state = c_state;
        case (c_state)
            STOP: begin
                if (i_runstop) begin
                    n_state = RUN;
                end else if (i_clear) begin
                    n_state = CLEAR;
                end
            end
            RUN: begin
                if (i_runstop) begin
                    n_state = STOP;
                end
            end
            CLEAR: begin
                if (i_clear) begin
                    n_state = STOP;
                end
            end
            default: n_state = c_state;
        endcase
    end


endmodule


/*
module stopwatch_cu(
    input clk,
    input rst,
    input i_clear,
    input i_runstop,
    output o_clear,
    output o_runstop
    );

    reg [1:0] n_state, c_state;
     
    parameter STOP = 2'b00,  RUN = 2'b01, CLEAR = 2'b10;
    //state 
    always @(posedge clk, posedge rst) begin
        if (rst == 1 )  c_state <= CLEAR;
        else c_state <= n_state; 
    end


    //next_state
    always @(c_state or i_clear or i_runstop) begin
        case (c_state)
            STOP: if (i_runstop ==1) n_state = RUN;
                  else if (i_clear ==1) n_state = CLEAR;
                  else n_state = STOP;
            RUN:  if (i_runstop ==1) n_state = STOP;
                  else n_state = STOP;
            CLEAR:if (i_runstop ==1) n_state = STOP;
                  else n_state = STOP;
            default: n_state = STOP;
        endcase
    end


    //output

    assign o_clear = ((c_state== STOP) && (i_clear ==1)) ? 1:0; 
    assign o_runstop = ((c_state== STOP) && (i_runstop ==1)) ? 1:0; 

endmodule
*/