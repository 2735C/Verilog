`timescale 1ns / 1ps

module realwatch_cu (
    input  clk,
    input  rst,
    input  i_up,
    input  i_down,
    input  i_move_left,
    input  i_move_right,
    output o_up,
    output o_down,
    output o_move_right,
    output o_move_left
);

    parameter IDLE = 3'b000, UP = 3'b001, DOWN = 3'b010, MOVE_LEFT = 3'b011, MOVE_RIGHT = 3'b100;
    reg [2:0] n_state, c_state;

    assign o_up = (c_state == UP) ? 1 : 0;
    assign o_down = (c_state == DOWN) ? 1 : 0;
    assign o_move_left = (c_state == MOVE_LEFT) ? 1 : 0;
    assign o_move_right = (c_state == MOVE_RIGHT) ? 1 : 0;

    always @(posedge clk, posedge rst) begin

        if (rst) begin
            c_state <= IDLE;

        end else begin
            c_state <= n_state;

        end
    end

    always @(*) begin
        n_state = c_state;

        case (c_state)
            IDLE: begin
                if (i_up == 1) n_state = UP;
                else if (i_down == 1) n_state = DOWN;
                else if (i_move_left == 1) n_state = MOVE_LEFT;
                else if (i_move_right == 1) n_state = MOVE_RIGHT;
            end
            UP: begin
                n_state = IDLE;
            end

            DOWN: begin
                n_state = IDLE;
            end

            MOVE_LEFT: begin
                n_state = IDLE;
            end

            MOVE_RIGHT: begin
                n_state = IDLE;
            end
        endcase
    end


    // parameter UP = 2'b00, DOWN = 2'b01, MOVE_LEFT = 2'b10, MOVE_RIGHT = 2'b11;
    // reg [1:0] n_state, c_state;

    // assign o_up   = (c_state == UP) ? 1 : 0;
    // assign o_down = (c_state == DOWN) ? 1 : 0;
    // assign o_move_left  = (c_state == MOVE_LEFT) ? 1 : 0;
    // assign o_move_right = (c_state == MOVE_RIGHT) ? 1 : 0;

    // always @(posedge clk, posedge rst) begin

    //     if (rst) begin
    //         c_state <= 0;

    //     end else begin
    //         c_state <= n_state;

    //     end
    // end

    // always @(*) begin
    //     n_state = c_state;

    //     case (c_state)

    //         UP: begin
    //             if (i_up == 1) n_state = UP;
    //             else n_state = c_state;
    //         end

    //         DOWN: begin
    //             if (i_down == 1) n_state = DOWN;
    //             else n_state = c_state;
    //         end

    //         MOVE_LEFT: begin
    //             if (i_move_left == 1) n_state = MOVE_LEFT;
    //             else n_state = c_state;
    //         end

    //         MOVE_RIGHT: begin
    //             if (i_move_right == 1) n_state = MOVE_RIGHT;
    //             else n_state = c_state;
    //         end

    //         default: n_state = c_state;
    //     endcase
    // end

endmodule
