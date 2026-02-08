`timescale 1ns/1ps

module t81_core_seq (
    input  logic clk,
    input  logic rst_n,
    input  logic cmd_valid,
    input  logic [1:0] cmd,
    input  logic [2:0] opcode,
    input  logic [1:0] src_a,
    input  logic [1:0] src_b,
    input  logic [1:0] dst,
    input  logic signed [1:0] imm_trit,
    output logic signed [1:0] store_data,
    output logic store_valid,
    output logic signed [1:0] last_y,
    output logic last_valid,
    output logic signed [1:0] dbg_r0,
    output logic signed [1:0] dbg_r1,
    output logic signed [1:0] dbg_r2,
    output logic signed [1:0] dbg_r3
);
    localparam logic [1:0] CMD_LOAD  = 2'd0;
    localparam logic [1:0] CMD_EXEC  = 2'd1;
    localparam logic [1:0] CMD_STORE = 2'd2;
    localparam logic [1:0] CMD_NOP   = 2'd3;

    localparam logic [2:0] OP_NOP    = 3'd0;
    localparam logic [2:0] OP_PASSA  = 3'd1;
    localparam logic [2:0] OP_ADD    = 3'd2;
    localparam logic [2:0] OP_SUB    = 3'd3;
    localparam logic [2:0] OP_NEG    = 3'd4;
    localparam logic [2:0] OP_MIN    = 3'd5;
    localparam logic [2:0] OP_MAX    = 3'd6;
    localparam logic [2:0] OP_ISZERO = 3'd7;

    logic signed [1:0] regfile [0:3];
    logic signed [1:0] alu_y;
    logic alu_valid;

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

    task automatic eval_alu(
        input logic [2:0] alu_opcode,
        input logic signed [1:0] a,
        input logic signed [1:0] b,
        output logic signed [1:0] y,
        output logic is_valid
    );
        begin
            is_valid = 1'b1;
            case (alu_opcode)
                OP_NOP: begin
                    y = 2'sd0;
                end
                OP_PASSA: begin
                    y = clamp_trit(sxt_trit(a));
                end
                OP_ADD: begin
                    y = clamp_trit(sxt_trit(a) + sxt_trit(b));
                end
                OP_SUB: begin
                    y = clamp_trit(sxt_trit(a) - sxt_trit(b));
                end
                OP_NEG: begin
                    y = clamp_trit(-sxt_trit(a));
                end
                OP_MIN: begin
                    y = (a < b) ? clamp_trit(sxt_trit(a)) : clamp_trit(sxt_trit(b));
                end
                OP_MAX: begin
                    y = (a > b) ? clamp_trit(sxt_trit(a)) : clamp_trit(sxt_trit(b));
                end
                OP_ISZERO: begin
                    y = (a == 0) ? 2'sd1 : -2'sd1;
                end
                default: begin
                    y = 2'sd0;
                    is_valid = 1'b0;
                end
            endcase
        end
    endtask

    assign dbg_r0 = regfile[0];
    assign dbg_r1 = regfile[1];
    assign dbg_r2 = regfile[2];
    assign dbg_r3 = regfile[3];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regfile[0] <= 2'sd0;
            regfile[1] <= 2'sd0;
            regfile[2] <= 2'sd0;
            regfile[3] <= 2'sd0;
            store_data <= 2'sd0;
            store_valid <= 1'b0;
            last_y <= 2'sd0;
            last_valid <= 1'b0;
        end else begin
            store_data <= 2'sd0;
            store_valid <= 1'b0;
            last_valid <= 1'b0;
            last_y <= 2'sd0;

            if (cmd_valid) begin
                case (cmd)
                    CMD_LOAD: begin
                        regfile[dst] <= clamp_trit(sxt_trit(imm_trit));
                    end
                    CMD_EXEC: begin
                        eval_alu(opcode, regfile[src_a], regfile[src_b], alu_y, alu_valid);
                        last_y <= alu_y;
                        last_valid <= alu_valid;
                        if (alu_valid) begin
                            regfile[dst] <= alu_y;
                        end
                    end
                    CMD_STORE: begin
                        store_data <= regfile[src_a];
                        store_valid <= 1'b1;
                    end
                    CMD_NOP: begin
                    end
                    default: begin
                    end
                endcase
            end
        end
    end
endmodule
