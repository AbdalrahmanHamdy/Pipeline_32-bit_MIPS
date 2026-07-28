`timescale 1ns/1ps
module data_mem_tb;
    reg         clk;
    reg         WE;
    reg  [31:0] A;
    reg  [31:0] WD;
    wire [31:0] RD;

    data_mem uut (
        .clk(clk),
        .WE(WE),
        .A(A),
        .WD(WD),
        .RD(RD)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; WE = 0; A = 0; WD = 0;
        #10;
        $finish;
    end
endmodule
