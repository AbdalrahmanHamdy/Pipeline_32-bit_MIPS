module data_mem_FIXED (
    input  wire        clk,
    input  wire        WE,
    input  wire [31:0] A,
    input  wire [31:0] WD,
    output wire  [31:0] RD
);

    // 128-word 32-bit Data Memory Array (128 locations, 32-bit each)
    reg [31:0] RAM [0:127]; 

    // FIX: RAM contents were never initialized -> stayed 'x' forever in
    // simulation, since 'rst' only blanked the READ MUX output for one
    // cycle and never touched the array itself. Zero it once at time 0
    // (matches the golden model's memset(dmem,0,...)).
    integer k;
    wire [6:0] word_addr;
    wire       aligned;

    assign word_addr = A[8:2];
    assign aligned   = (A[1:0] == 2'b00);

    // ReadData 
    assign RD =  aligned ? RAM[word_addr] : 32'b0;
    // Synchronous Write Logic
    always @(posedge clk) begin
        if (WE && aligned) 
            RAM[word_addr] <= WD; // A[11:2] provides 10 bits for 128 words (word-aligned)
    end

    initial begin
        for (k = 0; k < 128; k = k + 1)
            RAM[k] = 32'b0;
    end

endmodule
