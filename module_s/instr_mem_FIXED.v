module instr_mem_FIXED #(
    parameter integer DEPTH = 1024,
    parameter         INIT_FILE = "program.txt")
(
    input [31:0] A,
    output [31:0] RD
);
    localparam integer A_WIDTH = $clog2(DEPTH);
    localparam [31:0] LAST_VALID_A = DEPTH - 4;

    // 1024 words memory, each 32-bit wide
    reg [7:0] mem [0:DEPTH-1];

    // Read instruction from memory (A[11:2])

    integer i;

    wire [A_WIDTH-1:0] byte_addr;
    wire                  valid_fetch;

    initial begin

        // Fill unused memory locations with zero instructions
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 8'h00;

        $display("Loading program from %0s", INIT_FILE);
        $readmemh(INIT_FILE, mem);

    end

    assign byte_addr = A[A_WIDTH-1:0];

    // Instructions must be word-aligned and inside the memory range
    assign valid_fetch =
        (A[1:0] == 2'b00) &&
        (A <= LAST_VALID_A);
   // Little-endian instruction assembly
    assign RD = valid_fetch ? {
            	mem[byte_addr + 3],
        		mem[byte_addr + 2],
        		mem[byte_addr + 1],
        		mem[byte_addr]}: 32'h00000000;

endmodule
