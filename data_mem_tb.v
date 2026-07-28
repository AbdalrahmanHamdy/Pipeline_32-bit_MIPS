`timescale 1ns / 1ps

module data_mem_tb;

    // Inputs
    reg        clk;
    reg        WE;
    reg [31:0] A_D;
    reg [31:0] WD;

    // Output
    wire [31:0] RD_D;

    // Unit Under Test (UUT)
    data_mem uut (
        .clk(clk),
        .WE(WE),
        .A_D(A_D),
        .WD(WD),
        .RD_D(RD_D)
    );

    // Clock Generation (100MHz / 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Monitor output values in simulation
        $monitor("Time=%0t | clk=%b | WE=%b | Address=0x%h | WriteData=0x%h | ReadData=0x%h", 
                 $time, clk, WE, A_D, WD, RD_D);

        // Initialize signals to Zero
        clk = 0;
        WE  = 0;
        A_D = 32'd0;
        WD  = 32'd0;
        #10;

        // Basic Write & Read Checks (Default standard test)
        #10 WE = 1; A_D = 32'h00000004; WD = 32'hDEADBEEF; // Write DEADBEEF to Word address 1
        #10 WE = 0; A_D = 32'h00000004;                   // Read back from Address 4
        #10 A_D = 32'h00000000;                            // Read back default initial zero
        #10;

        $finish;
    end

endmodule
