`timescale 1ns/1ps

module t81_top (
    input  logic [2:0] opcode,
    input  logic signed [1:0] trit_a,
    input  logic signed [1:0] trit_b,
    output logic signed [1:0] trit_y,
    output logic valid
);
    localparam logic [2:0] OP_NOP    = 3'd0;
    localparam logic [2:0] OP_PASSA  = 3'd1;
    localparam logic [2:0] OP_ADD    = 3'd2;
    localparam logic [2:0] OP_SUB    = 3'd3;
    localparam logic [2:0] OP_NEG    = 3'd4;
    localparam logic [2:0] OP_MIN    = 3'd5;
    localparam logic [2:0] OP_MAX    = 3'd6;
    localparam logic [2:0] OP_ISZERO = 3'd7;

    function automatic logic signed [2:0] sxt_trit(input logic signed [1:0] value);
        sxt_trit = {value[1], value};
    endfunction

    function automatic logic signed [1:0] clamp_trit(input logic signed [2:0] value);
        if (value > 1) begin
            clamp_trit = 2'sd1;
        end else if (value < -1) begin
            clamp_trit = -2'sd1;
        end else begin
            clamp_trit = value[1:0];
        end
    endfunction

    always @(*) begin
        valid = 1'b1;
        case (opcode)
            OP_NOP: begin
                trit_y = 2'sd0;
            end
            OP_PASSA: begin
                trit_y = clamp_trit(sxt_trit(trit_a));
            end
            OP_ADD: begin
                trit_y = clamp_trit(sxt_trit(trit_a) + sxt_trit(trit_b));
            end
            OP_SUB: begin
                trit_y = clamp_trit(sxt_trit(trit_a) - sxt_trit(trit_b));
            end
            OP_NEG: begin
                trit_y = clamp_trit(-sxt_trit(trit_a));
            end
            OP_MIN: begin
                trit_y = (trit_a < trit_b) ? clamp_trit(sxt_trit(trit_a)) : clamp_trit(sxt_trit(trit_b));
            end
            OP_MAX: begin
                trit_y = (trit_a > trit_b) ? clamp_trit(sxt_trit(trit_a)) : clamp_trit(sxt_trit(trit_b));
            end
            OP_ISZERO: begin
                trit_y = (trit_a == 0) ? 2'sd1 : -2'sd1;
            end
            default: begin
                trit_y = 2'sd0;
                valid = 1'b0;
            end
        endcase
    end
endmodule
