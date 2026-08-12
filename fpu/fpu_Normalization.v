module fpu_normalizer (
    input  wire [24:0] ALU_Mant,   // 25-bit result from ALU (Bit 24 is Carry)
    input  wire [7:0]  Common_Exp, // Exponent from the Alignment stage
    
    output reg  [22:0] Final_Mant, // Final 23-bit fraction
    output reg  [7:0]  Final_Exp   // Final adjusted exponent
);

    reg [4:0]  shift_amount; 
    reg [24:0] shifted_mant; 
    integer i;                     // Loop variable for the LZD

    always @(*) begin
        shift_amount = 5'd0;
        shifted_mant = 25'd0;
        Final_Mant   = 23'd0;
        Final_Exp    = 8'd0;
       
        // SCENARIO 1: Result is exactly zero
        if (ALU_Mant == 25'b0) begin
            //shift_amount = 5'd0;
            Final_Mant   = 23'd0;
            Final_Exp    = 8'd0;
        end 
        
       
        // SCENARIO 2: Overflow occurred (Carry bit 24 is 1)
        else if (ALU_Mant[24] == 1'b1) begin
            // Prevent exponent overflow from producing an invalid value
            if (Common_Exp >= 8'd254) begin
                Final_Exp  = 8'hFF;
                Final_Mant = 23'd0;
            end
            else begin
                Final_Mant = ALU_Mant[23:1];
                Final_Exp  = Common_Exp + 8'd1;
            end
        end 
        
       
        // SCENARIOS 3 & 4: Normal or Underflow (Needs Left Shift)
        else begin
            shift_amount = 5'd0; // Default value
            
            // Leading Zero Detector (LZD) using a for-loop
            for (i = 0; i <= 23; i = i + 1) begin
                if (ALU_Mant[i] == 1'b1) begin
                    shift_amount = 23 - i;
                end
            end

            
            shifted_mant = ALU_Mant << shift_amount;
            
             // Simplified underflow handling
            if (shift_amount >= Common_Exp) begin
                Final_Mant = 23'd0;
                Final_Exp  = 8'd0;
            end
            else begin
                Final_Mant = shifted_mant[22:0];
                Final_Exp  = Common_Exp - shift_amount;
            end
        end
    end

endmodule
