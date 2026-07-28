module data_mem (
    input  wire        clk,
    input  wire        WE,
    input  wire [31:0] A_D,
    input  wire [31:0] WD,
    output wire [31:0] RD_D
);

    // 128-word 32-bit Data Memory Array
    reg [31:0] RAM[127:0]; 
    integer i;

    // Word-aligned read access
    assign RD_D = RAM[A_D[31:2]]; 

    // Synchronous Write Logic
    always @(posedge clk) begin
        if (WE) 
            RAM[A_D[31:2]] <= WD;
    end

    // Memory Initialization
    initial begin
        for (i = 0; i < 128; i = i + 1) 
            RAM[i] = 32'd0;
    end

endmodule