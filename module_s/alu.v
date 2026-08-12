// File: alu.v
// Created for 02_Abdelrahman_Hamdy

module alu (
    input  wire signed [31:0] SrcA,
    input  wire signed [31:0] SrcB,
    input  wire        [2:0]  ALUControl,
    output reg  signed [31:0] ALUResult,
    output wire        Zero
);

    // Zero Flag for Branch conditions
    assign Zero = (ALUResult == 32'b0);

    always @(*) begin
        case (ALUControl)
            // ALU operation selection
            3'b000 : ALUResult = SrcA & SrcB;                       // AND
            3'b001 : ALUResult = SrcA | SrcB;                       // OR
            3'b010 : ALUResult = SrcA + SrcB;                       // ADD
            3'b110 : ALUResult = SrcA - SrcB;                       // SUB
            3'b111 : ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0; // SLT
            default : ALUResult = 32'b0;
        endcase
    end

endmodule
