
// File: shift_block.v
// Created for 04_Hagar_Elaban

module Shift_Left_2_Branch_Pipline_MIPS (
    input  wire [31:0] SignImmD,
    output wire [31:0] SignImmShiftedD
);
    assign SignImmShiftedD = {SignImmD[29:0], 2'b00};

endmodule
