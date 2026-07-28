`timescale 1ns/1ps
module alu_tb;
    reg  [31:0] SrcA;
    reg  [31:0] SrcB;
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire        Zero;

    // Instantiation
    alu uut (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin
        SrcA = 0; SrcB = 0; ALUControl = 0;
        #10;
        // أضف حالات الاختبار هنا
        #10 SrcA = 32'h0A10; SrcB = 32'h01A0; ALUControl = 4'b0000;
        #10 SrcA = 32'h0A10; SrcB = 32'h01A0; ALUControl = 4'b0001;
        #10 SrcA = 32'h0A10; SrcB = 32'h01A0; ALUControl = 4'b0010;
        #10 SrcA = 32'h0A10; SrcB = 32'h01A0; ALUControl = 4'b0110;
        #10 SrcA = 32'h0A10; SrcB = 32'h01A0; ALUControl = 4'b0111;
        #10 SrcA = 32'h0A10; SrcB = 32'h01A0; ALUControl = 4'b1100;  
        $finish;
    end
endmodule
