module alu (
    input  wire [31:0] SrcA,
    input  wire [31:0] SrcB,
    input  wire [3:0]  ALUControl,
    output reg  [31:0] ALUResult,
    output wire        Zero
);
   
    always @(*) begin
        case (ALUControl)
            // سيتم كتابة الحالات هنا خطوة بخطوة
        4'b0000 : ALUResult = SrcA & SrcB ;
        4'b0001 : ALUResult = SrcA | SrcB ;
        4'b0010 : ALUResult = SrcA + SrcB ;
        4'b0110 : ALUResult = SrcA - SrcB ;

        4'b0111 : ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0 ;
        4'b1100 : ALUResult = ~(SrcA | SrcB) ;
            default: ALUResult = 32'b0;
        endcase
    end
     // تذكر استخدام $signed() في الـ SLT للعمليات الإشارتية
    assign Zero = (ALUResult == 32'b0);

endmodule
