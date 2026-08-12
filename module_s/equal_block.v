// File: equal_block.v

module equal (

    input  wire [31:0] SrcA,
    input  wire [31:0] SrcB,
    output wire Equal

);

    assign Equal = (SrcA == SrcB);

endmodule

