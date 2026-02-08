`timescale 1ns/1ps

module tb_t81_core_seq;
    localparam int CMD_LOAD  = 0;
    localparam int CMD_EXEC  = 1;
    localparam int CMD_STORE = 2;
    localparam int CMD_NOP   = 3;

    logic clk;
    logic rst_n;
    logic cmd_valid;
    logic [1:0] cmd;
    logic [2:0] opcode;
    logic [1:0] src_a;
    logic [1:0] src_b;
    logic [1:0] dst;
    logic signed [1:0] imm_trit;
    logic signed [1:0] store_data;
    logic store_valid;
    logic signed [1:0] last_y;
    logic last_valid;
    logic signed [1:0] dbg_r0;
    logic signed [1:0] dbg_r1;
    logic signed [1:0] dbg_r2;
    logic signed [1:0] dbg_r3;

    int fd_prog;
    int fd_exp;
    int fd_obs;
    int rc_prog;
    int rc_exp;
    int step_prog;
    int step_exp;

    int i_cmd;
    int i_opcode;
    int i_src_a;
    int i_src_b;
    int i_dst;
    int i_imm;

    int e_store_data;
    int e_store_valid;
    int e_last_y;
    int e_last_valid;
    int e_r0;
    int e_r1;
    int e_r2;
    int e_r3;

    reg [8*256-1:0] header_prog;
    reg [8*256-1:0] header_exp;

    t81_core_seq dut (
        .clk(clk),
        .rst_n(rst_n),
        .cmd_valid(cmd_valid),
        .cmd(cmd),
        .opcode(opcode),
        .src_a(src_a),
        .src_b(src_b),
        .dst(dst),
        .imm_trit(imm_trit),
        .store_data(store_data),
        .store_valid(store_valid),
        .last_y(last_y),
        .last_valid(last_valid),
        .dbg_r0(dbg_r0),
        .dbg_r1(dbg_r1),
        .dbg_r2(dbg_r2),
        .dbg_r3(dbg_r3)
    );

    task automatic tick;
        begin
            #1 clk = 1'b1;
            #1 clk = 1'b0;
        end
    endtask

    task automatic check_known_signals;
        begin
            if (store_valid !== 1'b0 && store_valid !== 1'b1) begin
                $display("FAIL: store_valid is X/Z");
                $fatal(1);
            end
            if (last_valid !== 1'b0 && last_valid !== 1'b1) begin
                $display("FAIL: last_valid is X/Z");
                $fatal(1);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        cmd_valid = 1'b0;
        cmd = CMD_NOP;
        opcode = 3'd0;
        src_a = 2'd0;
        src_b = 2'd0;
        dst = 2'd0;
        imm_trit = 2'sd0;

        tick();
        rst_n = 1'b1;
        tick();

        if ($signed(dbg_r0) !== 0 || $signed(dbg_r1) !== 0 || $signed(dbg_r2) !== 0 || $signed(dbg_r3) !== 0) begin
            $display("FAIL: reset state mismatch r0=%0d r1=%0d r2=%0d r3=%0d",
                $signed(dbg_r0), $signed(dbg_r1), $signed(dbg_r2), $signed(dbg_r3));
            $fatal(1);
        end

        fd_prog = $fopen("sim/vectors/t81_seq_program.tsv", "r");
        if (fd_prog == 0) begin
            $display("FAIL: could not open sim/vectors/t81_seq_program.tsv");
            $fatal(1);
        end

        fd_exp = $fopen("sim/vectors/t81_seq_expected.tsv", "r");
        if (fd_exp == 0) begin
            $display("FAIL: could not open sim/vectors/t81_seq_expected.tsv");
            $fatal(1);
        end

        fd_obs = $fopen("sim/out/t81_seq_observed.tsv", "w");
        if (fd_obs == 0) begin
            $display("FAIL: could not open sim/out/t81_seq_observed.tsv for write");
            $fatal(1);
        end

        $fdisplay(fd_obs, "step\tstore_data\tstore_valid\tlast_y\tlast_valid\tr0\tr1\tr2\tr3");

        rc_prog = $fgets(header_prog, fd_prog);
        rc_exp = $fgets(header_exp, fd_exp);

        while (!$feof(fd_prog) && !$feof(fd_exp)) begin
            rc_prog = $fscanf(fd_prog, "%d\t%d\t%d\t%d\t%d\t%d\t%d\n", step_prog, i_cmd, i_opcode, i_src_a, i_src_b, i_dst, i_imm);
            rc_exp = $fscanf(fd_exp, "%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n", step_exp, e_store_data, e_store_valid, e_last_y, e_last_valid, e_r0, e_r1, e_r2, e_r3);

            if (rc_prog == 7 && rc_exp == 9) begin
                if (step_prog != step_exp) begin
                    $display("FAIL: step mismatch program=%0d expected=%0d", step_prog, step_exp);
                    $fatal(1);
                end

                cmd_valid = 1'b1;
                cmd = i_cmd[1:0];
                opcode = i_opcode[2:0];
                src_a = i_src_a[1:0];
                src_b = i_src_b[1:0];
                dst = i_dst[1:0];
                imm_trit = i_imm;

                tick();
                check_known_signals();

                if ($signed(store_data) !== e_store_data || store_valid !== e_store_valid ||
                    $signed(last_y) !== e_last_y || last_valid !== e_last_valid ||
                    $signed(dbg_r0) !== e_r0 || $signed(dbg_r1) !== e_r1 ||
                    $signed(dbg_r2) !== e_r2 || $signed(dbg_r3) !== e_r3) begin
                    $display("FAIL step=%0d", step_prog);
                    $display("  got: store_data=%0d store_valid=%0d last_y=%0d last_valid=%0d r0=%0d r1=%0d r2=%0d r3=%0d",
                        $signed(store_data), store_valid, $signed(last_y), last_valid,
                        $signed(dbg_r0), $signed(dbg_r1), $signed(dbg_r2), $signed(dbg_r3));
                    $display("  exp: store_data=%0d store_valid=%0d last_y=%0d last_valid=%0d r0=%0d r1=%0d r2=%0d r3=%0d",
                        e_store_data, e_store_valid, e_last_y, e_last_valid,
                        e_r0, e_r1, e_r2, e_r3);
                    $fatal(1);
                end

                $fdisplay(fd_obs, "%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d",
                    step_prog,
                    $signed(store_data),
                    store_valid,
                    $signed(last_y),
                    last_valid,
                    $signed(dbg_r0),
                    $signed(dbg_r1),
                    $signed(dbg_r2),
                    $signed(dbg_r3));
            end
        end

        cmd_valid = 1'b0;
        cmd = CMD_NOP;

        $fclose(fd_prog);
        $fclose(fd_exp);
        $fclose(fd_obs);

        $display("PASS: sequential trace matches expected model output");
        $finish;
    end
endmodule
