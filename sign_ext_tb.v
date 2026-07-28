`timescale 1ns/1ps
module sign_ext_tb;
    reg  [15:0] a;
    wire [31:0] y;

    sign_ext uut (
        .a(a),
        .y(y)
    );

    initial begin
        a = 16'h0000; #10;
        a = 16'h8000; #10;
        $finish;
    end
endmodule
