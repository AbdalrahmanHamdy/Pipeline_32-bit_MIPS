// Module      : Register_File
// Description : 32 x 32-bit Integer Register File
// - Two asynchronous read ports
// - One synchronous write port
// - Synchronous active-high reset
// - Register $zero is hardwired to zero
// - Same-cycle write-through forwarding

module reg_file (
    input  wire        clk,
    input  wire        rst, 
    input  wire        WE3,
    input  wire [4:0]  A1,
    input  wire [4:0]  A2,
    input  wire [4:0]  A3,
    input  wire [31:0] WD3,
    output wire [31:0] RD1,
    output wire [31:0] RD2,
    output wire [3:0]  s0_reg

);
    reg [31:0] rf [1023:0];
    integer i;
    always @(posedge clk) begin
    // Clear all registers during synchronous reset
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] <= 32'b0;
    end
    // Write data on the rising clock edge , Register zero cannot be written
    else if (WE3 && (A3 != 5'd0)) begin
        rf[A3] <= WD3;
    end
end
    // Combinational Read with Register 0 Protection
    //assign RD1 = (A1 == 5'b00000) ? 32'b0 : rf[A1];
    //assign RD2 = (A2 == 5'b00000) ? 32'b0 : rf[A2];
    
    // Asynchronous read port 1 , Return zero for $zero ,Forward write data if reading and writing the same register
    assign RD1 = (A1 == 5'b0)? 32'b0 :
                (WE3 && (A3 != 5'd0)  && (A1 == A3) )? WD3 :
                rf[A1];
   // Asynchronous read port 2 , Return zero for $zero ,Forward write data if reading and writing the same register
    assign RD2 = (A2 == 5'b0)? 32'b0 :
                (WE3 && (A3 != 5'd0)  && (A2 == A3) )? WD3 :
                rf[A2];
    // Debug output: lower 4 bits of register $s0
    assign s0_reg = rf[16][3:0];


endmodule
