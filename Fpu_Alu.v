module fpu_alu (
    input  wire [23:0] Aligned_Mant_A, 
    input  wire [23:0] Aligned_Mant_B, 
    input  wire        Sign_A,         
    input  wire        Sign_B,        
    input  wire        Op_Sub,         

    output reg  [24:0] Result_Mant,    // 25-bit result (extra MSB for carry/overflow detection)
    output reg         Result_Sign     // Final sign of the calculated result
);

    wire Eff_Sign_B; 
    wire Eff_Op;     // Effective arithmetic operation (0 = Addition, 1 = Subtraction)

   
   
    // If the instruction is Subtraction (Op_Sub = 1), invert the sign of B.
    // If it's Addition (Op_Sub = 0), keep the sign of B as is.
    assign Eff_Sign_B = Sign_B ^ Op_Sub;

  
    // If both operands have the same effective sign, we ADD them.
    // If they have different effective signs, we SUBTRACT them.
    assign Eff_Op = Sign_A ^ Eff_Sign_B;


    // Step 3: Execute the Arithmetic Operation
    always @(*) begin
        if (Eff_Op == 1'b0) begin
            Result_Mant = Aligned_Mant_A + Aligned_Mant_B;
            Result_Sign = Sign_A; 
        end 
        else begin
            if (Aligned_Mant_A >= Aligned_Mant_B) begin
                Result_Mant = Aligned_Mant_A - Aligned_Mant_B;
                Result_Sign = Sign_A;     // Sign follows the larger magnitude
            end 
            else begin
                Result_Mant = Aligned_Mant_B - Aligned_Mant_A;
                Result_Sign = Eff_Sign_B; // Sign follows the larger magnitude
            end
        end
    end

endmodule