// =====================================================================
// tb_add_sub_final.v
// -----------------------------------------------------------------
// Simple, direct sanity testbench for your real top_module_pip_FIXED
// (the byte-addressed instr_mem_FIXED that reads program.txt).
//
// No hierarchical RAM poking needed this time -- instr_mem_FIXED loads
// program.txt on its own via $readmemh at time 0. Just place this file
// and program.txt (provided alongside) in the same folder as your RTL
// and run:
//     vlog *.v
//     vsim -c work.tb_add_sub_final
//     run -all
//
// Program (see program.txt):
//   addi $1, $0, 5      $1 = 5
//   addi $2, $0, 10     $2 = 10
//   add  $3, $1, $2     $3 = 15
//   sub  $5, $2, $1     $5 = 5     (independent instruction, no hazard)
//   sw   $3, 0($0)      mem[0] = 15
//   lw   $4, 0($0)      $4 = 15
//   add  $6, $4, $4     $6 = 30    (load-use hazard: needs $4 the cycle
//                                   right after lw -> forces one Stall)
//   beq  $0, $0, 1      taken -> skips the junk instr right after it
//   addi $7, $0, 99     JUNK: must be flushed, $7 must stay 0
//   addi $8, $0, 77     real target after the taken branch, $8 = 77
//   beq  $1, $2, 1      NOT taken ($1=5 != $2=10) -> falls through
//   addi $9, $0, 55     runs normally right after the not-taken branch
// Everything after these 12 instructions is automatically zero (the
// module zero-fills all of `mem` before $readmemh, and program.txt
// only supplies the first 48 bytes) -- no leftover-instruction problem
// this time.
// =====================================================================
`timescale 1ns/1ps

module tb_add_sub_final;

    reg clk_tb, rst_tb;
    integer i;
    reg stall_seen;         // goes high once if the Hazard Unit ever stalls
    reg branch_flush_seen;  // goes high once if a taken branch ever flushes an instr

    top_module_pip_FIXED DUT (
        .clk    (clk_tb),
        .rst    (rst_tb),
        .s0_reg ()
    );

    initial clk_tb = 1'b0;
    always #5 clk_tb = ~clk_tb;   // 10 ns period

    initial begin
        rst_tb = 1'b1;
        repeat (2) @(negedge clk_tb);
        rst_tb = 1'b0;

        $display("[%0t] Reset released. Running add/sub/lw/sw sanity program...", $time);
        $display("cyc  PCF      Instr_F  Instr_D  RD1_D    RD2_D    ALU_M    Result_W RegWrite_W StallF StallD ForwardAE ForwardBE");

        stall_seen = 1'b0;
        branch_flush_seen = 1'b0;

        for (i = 0; i < 35; i = i + 1) begin
            @(negedge clk_tb);
            if (DUT.StallF || DUT.StallD)
                stall_seen = 1'b1;
            if (DUT.flushE)
                branch_flush_seen = 1'b1;
            $display("%-4d %h %h %h %h %h %h %h %b          %b      %b      %b         %b",
                i, DUT.PCF, DUT.Instr_F, DUT.Instr_D, DUT.RD1_D, DUT.RD2_D,
                DUT.ALUResult_M, DUT.Result_W, DUT.RegWrite_W,
                DUT.StallF, DUT.StallD, DUT.ForwardAE, DUT.ForwardBE);
        end

        $display("=====================================================");
        if (DUT.Dut_reg_file.rf[3] === 32'd15)
            $display(" PASS: reg $3 = %0d (expected 15)", DUT.Dut_reg_file.rf[3]);
        else
            $display(" FAIL: reg $3 = %0d (expected 15)", DUT.Dut_reg_file.rf[3]);

        if (DUT.Dut_reg_file.rf[5] === 32'd5)
            $display(" PASS: reg $5 = %0d (expected 5)", DUT.Dut_reg_file.rf[5]);
        else
            $display(" FAIL: reg $5 = %0d (expected 5)", DUT.Dut_reg_file.rf[5]);

        if (DUT.Dut_reg_file.rf[4] === 32'd15)
            $display(" PASS: reg $4 = %0d (expected 15)  [lw]", DUT.Dut_reg_file.rf[4]);
        else
            $display(" FAIL: reg $4 = %0d (expected 15)  [lw]", DUT.Dut_reg_file.rf[4]);

        if (DUT.Dut_reg_file.rf[6] === 32'd30)
            $display(" PASS: reg $6 = %0d (expected 30)  [load-use hazard]", DUT.Dut_reg_file.rf[6]);
        else
            $display(" FAIL: reg $6 = %0d (expected 30)  [load-use hazard]", DUT.Dut_reg_file.rf[6]);

        if (stall_seen)
            $display(" PASS: Hazard Unit asserted Stall at least once");
        else
            $display(" FAIL: Hazard Unit never asserted Stall (load-use hazard not detected)");

        if (DUT.Dut_reg_file.rf[7] === 32'd0)
            $display(" PASS: reg $7 = %0d (expected 0)   [junk instr correctly flushed]", DUT.Dut_reg_file.rf[7]);
        else
            $display(" FAIL: reg $7 = %0d (expected 0)   [junk instr correctly flushed]", DUT.Dut_reg_file.rf[7]);

        if (DUT.Dut_reg_file.rf[8] === 32'd77)
            $display(" PASS: reg $8 = %0d (expected 77)  [taken-branch target executed]", DUT.Dut_reg_file.rf[8]);
        else
            $display(" FAIL: reg $8 = %0d (expected 77)  [taken-branch target executed]", DUT.Dut_reg_file.rf[8]);

        if (DUT.Dut_reg_file.rf[9] === 32'd55)
            $display(" PASS: reg $9 = %0d (expected 55)  [not-taken branch falls through]", DUT.Dut_reg_file.rf[9]);
        else
            $display(" FAIL: reg $9 = %0d (expected 55)  [not-taken branch falls through]", DUT.Dut_reg_file.rf[9]);

        if (branch_flush_seen)
            $display(" PASS: flushE asserted at least once (taken branch squashed an instr)");
        else
            $display(" FAIL: flushE never asserted (taken branch never squashed the wrong instr)");
        $display("=====================================================");

        $finish;
    end

endmodule
