module data_mem (
    input  wire        clk,
    input  wire        WE,
    input  wire [31:0] A_D,
    input  wire [31:0] WD,
    output wire [31:0] RD_D
);
  reg [31:0] RAM[127:0];  // ذاكرة بيانات بحجم مناسب للتجربة
  assign RD_D = RAM[A_D[31:2]];  // Word aligned access

  always @(posedge clk) begin
    if (WE) RAM[A_D[31:2]] <= WD;
  end
  integer i;

  initial begin
    for (i = 0; i < 128; i = i + 1) RAM[i] = 32'd0;
  end
endmodule
