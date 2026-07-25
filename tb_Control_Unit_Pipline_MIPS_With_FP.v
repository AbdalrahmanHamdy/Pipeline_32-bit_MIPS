`timescale 1ns/1ps
module tb_Control_Unit_Pipeline_MIPS_with_FP;
// Inputs
reg  [5:0] funct;
reg  [5:0] op;
// Outputs
wire MemtoRegD;
wire MemWriteD;
wire BranchD;
wire ALUSrcD;
wire RegDstD;
wire RegWriteD;
wire [2:0] ALUControlD;
wire FpuRegD;
wire FpuConD;

//====================================================
// Instantiate DUT
//====================================================
Control_Unit_Pipeline_MIPS_with_FP uut
(
    .funct(funct),
    .op(op),
    .MemtoRegD(MemtoRegD),
    .MemWriteD(MemWriteD),
    .BranchD(BranchD),
    .ALUControlD(ALUControlD),
    .ALUSrcD(ALUSrcD),
    .RegDstD(RegDstD),
    .RegWriteD(RegWriteD),
    .FpuRegD(FpuRegD),
    .FpuConD(FpuConD)
);

// Task: check_control_outputs
// Compares all control outputs against the expected values.
// Prints PASS if all outputs match, otherwise prints FAIL
// along with the expected and actual values for debugging.
//==============================================================
task check_control_outputs;
    input exp_RegWrite, exp_RegDst, exp_ALUSrc, exp_Branch, exp_MemWrite, exp_MemtoReg;
    input [2:0] exp_ALUControl;
    input exp_FpuReg, exp_FpuCon;
    input [8*80-1:0] test_name;
    begin
        if (RegWriteD   === exp_RegWrite   &&
            RegDstD     === exp_RegDst     &&
            ALUSrcD     === exp_ALUSrc     &&
            BranchD     === exp_Branch     &&
            MemWriteD   === exp_MemWrite   &&
            MemtoRegD   === exp_MemtoReg   &&
            ALUControlD === exp_ALUControl &&
            FpuRegD     === exp_FpuReg     &&
            FpuConD     === exp_FpuCon) begin
            $display("[PASS] %s", test_name);
        end else begin
           $display(
"[FAIL] %s (op=%b funct=%b)\nExpected: RW=%b RD=%b ASrc=%b Br=%b MW=%b M2R=%b ALU=%b FpuR=%b FpuC=%b\nGot     : RW=%b RD=%b ASrc=%b Br=%b MW=%b M2R=%b ALU=%b FpuR=%b FpuC=%b",
test_name,
op,
funct,
exp_RegWrite,
exp_RegDst,
exp_ALUSrc,
exp_Branch,
exp_MemWrite,
exp_MemtoReg,
exp_ALUControl,
exp_FpuReg,
exp_FpuCon,
RegWriteD,
RegDstD,
ALUSrcD,
BranchD,
MemWriteD,
MemtoRegD,
ALUControlD,
FpuRegD,
FpuConD
);
        end
    end
endtask

//====================================================
// Test Sequence
//====================================================

initial begin

$display("==================================================");
$display("Starting Comprehensive Control Unit Testbench...");
$display("==================================================");


//====================================================
// SECTION 1: Integer R-Type Instructions (op = 000000)
// Verification: Full signal check for each operation
//====================================================

// Test 1.1: R-Type ADD (funct = 100000)
op=6'b000000; funct=6'b100000; #10;
check_control_outputs(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b0, 1'b0, "R-Type ADD");

// Test 1.2: R-Type SUB (funct = 100010)
op=6'b000000; funct=6'b100010; #10;
check_control_outputs(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b110, 1'b0, 1'b0, "R-Type SUB");

// Test 1.3: R-Type AND (funct = 100100)
op=6'b000000; funct=6'b100100; #10;
check_control_outputs(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, "R-Type AND");

// Test 1.4: R-Type OR (funct = 100101)
op=6'b000000; funct=6'b100101; #10;
check_control_outputs(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b001, 1'b0, 1'b0, "R-Type OR");

// Test 1.5: R-Type SLT (funct = 101010)
op=6'b000000; funct=6'b101010; #10;
check_control_outputs(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b111, 1'b0, 1'b0, "R-Type SLT");

// Test 1.6: Unsupported R-Type Function (funct = 111111) -> Should fallback to default ADD
op=6'b000000; funct=6'b111111; #10;
check_control_outputs(1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b0, 1'b0, "Unsupported R-Type Function -> Default ALU");


//====================================================
// SECTION 2: Memory & Immediate Instructions
// Verification: Full signal validation including RegDstD = 0 for Immediate formats
//====================================================

// Test 2.1: Load Word LW (op = 100011)
op=6'b100011; funct=6'b000000; #10;
check_control_outputs(1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 3'b010, 1'b0, 1'b0, "LW Instruction");

// Test 2.2: Store Word SW (op = 101011)
op=6'b101011; funct=6'b000000; #10;
check_control_outputs(1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 3'b010, 1'b0, 1'b0, "SW Instruction");

// Test 2.3: Add Immediate ADDI (op = 001000)
op=6'b001000; funct=6'b000000; #10;
check_control_outputs(1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 3'b010, 1'b0, 1'b0, "ADDI Instruction");


//====================================================
// SECTION 3: Control Flow & Overlap Edge Cases
// Verification: Ensure Branch logic doesn't clash with funct bits in casex
//====================================================

// Test 3.1: Normal BEQ (op = 000100, funct = 000000)
op=6'b000100; funct=6'b000000; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b110, 1'b0, 1'b0, "BEQ Instruction");

// Test 3.2: BEQ with ADD funct (op = 000100, funct = 100000)
// Tests if alu_op (2'b01) gets incorrectly matched by R-type patterns in casex
op=6'b000100; funct=6'b100000; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b110, 1'b0, 1'b0, "BEQ with R-Type Funct Pattern (Casex Safety Check)");


//====================================================
// SECTION 4: Floating Point Instructions & Unsupported FP
// Verification: Ensures FPU control flags are precise and safety defaults work
//====================================================

// Test 4.1: Floating Point ADD (add.s) (op = 010001, funct = 000000)
op=6'b010001; funct= 6'b000000; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b1, 1'b0, "Floating Point ADD (add.s)");

// Test 4.2: Floating Point SUB (sub.s) (op = 010001, funct =000001)
op=6'b010001; funct=6'b000001; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b1, 1'b1, "Floating Point SUB (sub.s)");

// Test 4.3: Unsupported FP Function #1 (funct = 000010)
op=6'b010001; funct=6'b000010; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b0, 1'b0, "Unsupported FP Function (000010)");

// Test 4.4: Unsupported FP Function #2 (funct = 111111)
op=6'b010001; funct=6'b111111; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b0, 1'b0, "Unsupported FP Function (111111)");
// Test 4.5: Verify ALUControl remains at default ADD during FP instructions
// The integer ALU is not used by the FPU, but alu_op = 00 should force ALUControlD = 010.
op = 6'b010001;
funct = 6'b000000;
#10;

if (ALUControlD === 3'b010)
    $display("[PASS] ALUControl Default During Floating Point Instruction");
else
    $display("[FAIL] ALUControl Changed Unexpectedly During Floating Point Instruction");

//====================================================
// SECTION 5: Illegal Opcode & Default Safety Verification
// Verification: Ensure all control outputs are completely de-asserted
//====================================================

// Test 5.1: Unknown Opcode (op = 111111)
op=6'b111111; funct=6'b000000; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b0, 1'b0, "Illegal Opcode (111111) -> Full Safety Check");

// Test 5.2: Another Unknown Opcode (op = 000011)
op=6'b000011; funct=6'b101010; #10;
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b0, 1'b0, "Illegal Opcode (000011)");

//====================================================
// SECTION 6: State Transition Tests (Latch & Sticky-Bits Detection)
// Verification: Ensure state doesn't leak across different instruction boundaries
//====================================================

// Test 6.1: Floating Point -> Integer Transition
// Step 1: Set FP ADD to assert FpuRegD
op=6'b010001; funct=6'b000000; #10; 
// Step 2: Transition to LW and check if FpuRegD/FpuConD correctly clear to 0
op=6'b100011; funct=6'b000000; #10; 
check_control_outputs(1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 3'b010, 1'b0, 1'b0, "Floating -> Integer Transition (LW)");


// Test 6.2: Integer -> Floating Point Transition
// Step 1: Set LW to assert MemtoRegD and ALUSrcD
op=6'b100011; funct=6'b000000; #10; 
// Step 2: Transition to FP SUB and check if integer control signals clear
op=6'b010001; funct=6'b000001; #10; 
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b1, 1'b1, "Integer -> Floating Transition (FP SUB)");


// Test 6.3: R-Type -> Floating Point Transition
// Step 1: Set R-Type SUB
op=6'b000000; funct=6'b100010; #10; 
// Step 2: Transition to FP ADD and check RegWriteD resets while FpuRegD sets
op=6'b010001; funct=6'b000000; #10; 
check_control_outputs(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b010, 1'b1, 1'b0, "R-Type SUB -> FP ADD Transition");
//====================================================
// End Simulation
//====================================================

$display("==================================================");
$display("All Test Cases Completed.");
$display("==================================================");

$finish;

end

endmodule
