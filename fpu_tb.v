`timescale 1ns / 1ps

module fpu_tb;

    reg  [31:0] A;
    reg  [31:0] B;
    reg         Op_Sub;
    
    wire [31:0] Final_Result;

    fpu_top uut (
        .A(A),
        .B(B),
        .Op_Sub(Op_Sub),
        .Final_Result(Final_Result)
    );

    initial begin
        $monitor("Time=%0t | Op_Sub=%b | A=%h | B=%h | Result=%h", $time, Op_Sub, A, B, Final_Result);

        // A = 1.5, B = 1.25, Operation = Addition
        // Expected Result = 2.75
        A = 32'h3FC00000;
        B = 32'h3FA00000;
        Op_Sub = 1'b0;
        #10;

        // A = 5.0, B = 2.0, Operation = Subtraction
        // Expected Result = 3.0
        A = 32'h40A00000;
        B = 32'h40000000;
        Op_Sub = 1'b1;
        #10;

        // A = 1.0, B = -1.0, Operation = Addition
        // Expected Result = 0.0
        A = 32'h3F800000;
        B = 32'hBF800000;
        Op_Sub = 1'b0;
        #10;

        $stop;
    end

endmodule