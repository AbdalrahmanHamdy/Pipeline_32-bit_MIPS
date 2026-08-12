module pc_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire        EN,       // EN = ~StallF
    input  wire [31:0] PC_next,
    output reg  [31:0] PC
);
    always @(posedge clk or posedge reset) begin
        if (reset) PC <= 32'b0;
        else if(EN)      PC <= PC_next;
    end
endmodule
