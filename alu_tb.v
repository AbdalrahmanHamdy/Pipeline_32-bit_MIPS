`timescale 1ns / 1ps

module alu_tb;

    // Inputs
    reg [31:0] SrcA;
    reg [31:0] SrcB;
    reg [3:0]  ALUControl;

    // Outputs
    wire [31:0] ALUResult;
    wire        Zero;

    // Instantiate the Unit Under Test (UUT)
    alu uut (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin
     

        // Initialize Inputs
        SrcA = 0; SrcB = 0; ALUControl = 0;
        #10;

        // Test Cases
        #10 SrcA = 32'h00000010; SrcB = 32'h000000A0; ALUControl = 4'b0000; // AND
        #10 SrcA = 32'h00000010; SrcB = 32'h000000A0; ALUControl = 4'b0001; // OR
        #10 SrcA = 32'h00000010; SrcB = 32'h000000A0; ALUControl = 4'b0010; // ADD
        #10 SrcA = 32'h00000010; SrcB = 32'h000000A0; ALUControl = 4'b0110; // SUB
        #10 SrcA = 32'h00000010; SrcB = 32'h000000A0; ALUControl = 4'b0111; // SLT
        #10 SrcA = 32'h00000010; SrcB = 32'h000000A0; ALUControl = 4'b1100; // NOR
        #10;
        // Monitor outputs in simulation
        $monitor("Time=%0t | SrcA=0x%h | SrcB=0x%h | ALUControl=%b | ALUResult=0x%h | Zero=%b", 
                 $time, SrcA, SrcB, ALUControl, ALUResult, Zero);

        $finish;
    end

endmodule
