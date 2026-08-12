// File: top_module_pip
// Created for Abdelrahman_Hamdy
// Description : 5-stage pipelined MIPS processor
//               with single-cycle floating-point add.s and sub.s
// ===========================================================

module top_module_pip_FIXED(
    // ---------------- input Interface ----------------
    input wire clk,                 // Clock signal
    input wire rst,                 // Reset signal

    output wire [3:0] s0_reg

    // ---------------- output Interface ----------------
    // Outputs from the top module
    /*output wire  [31:0] RD1,                     // Read Data 1 from Register File                    
    output wire  [31:0] RD2,                     // Read Data 2 from Register File            
    output wire  [31:0] Alu_Result,              // ALU Result from Execute Stage
    output wire  [31:0] Fpu_Result,              // Floating Point Unit Result from Execute Stage
    output wire  [31:0] Read_Data_W,              // Read Data from Data Memory in Write Back Stage
    output wire  [31:0] SrcAE,                   // Source A for ALU in Execute Stage    
    output wire  [31:0] SrcBE,                   // Source B for ALU in Execute Stage
    output wire          RegWriteW,               // Register Write Enable in Write Back Stage
    // Control signals for forwarding and stalling  
    output wire          StallF,                  // Stall Fetch Stage
    output wire          StallD,                  // Stall Decode Stage   
    output wire          ForwardAD,               // Forwarding for Decode Stage Source A
    output wire          ForwardBD,                // Forwarding for Decode Stage Source B    
    output wire [1:0]    ForwardAE,         // Forwarding for Execute Stage Source A
    output wire [1:0]    ForwardBE          // Forwarding for Execute Stage Source B
    */
);
    

    // =========================================================
    // 1. Fatch Wire declarations
    // =========================================================
        // Mux Note: Decode Wire (EqualD)
        
            wire [31:0]     PC_nextF;       // PC
            wire [31:0]     PCF;    
            wire [31:0]     Instr_F;         // instractian
            wire [31:0]     PCPlus4_F;      // PC+4
            wire            StallF;           // controal
       

    // =========================================================
    // 2.Decode Wire declarations
    // =========================================================
        // 2.1 Register File Wire declarations

        // 2.2 Control Unit Wire declarations
            wire        RegWriteD;                 // Register Write Enable in Decode Stage
            wire        MemtoRegD;                 // Memory to Register Control Signal in Decode Stage
            wire        MemWriteD;                 // Memory Write Enable in Decode Stage
            wire [2:0] ALUControlD;                // ALU Control Signal in Decode Stage
            wire        ALUSrcD;                   // ALU Source Control Signal in Decode Stage 
            wire        RegDstD;                    // Register Destination Control Signal in Decode Stage
            wire        BranchD;                   // Branch Control Signal in Decode Stage
            // Floating Point Control Signals
            wire        FpuRegD;                   // Floating Point Register File Control Signal in Decode Stage
            wire        FpuConD;                   // Floating Point Control Signal in Decode Stage
            wire        ForwardAD;
            wire        ForwardBD;
        // 2.3 Sign Extension Wire declarations
            wire [31:0] Instr_D;                   // Instruction in Decode Stage
            wire [31:0] SignImm_D;                 // Sign Extended Immediate Value in Decode Stage
        // 2.4 Shift Left 2 for Branch Wire declarations
            wire [31:0] SignImmShifted_D;           // Shifted Sign Extended Immediate Value in Decode Stage 
        // 2.5 Pc Wire declarations
            wire [31:0] PCPlus4_D;                  // PC + 4 in Decode Stage
            wire [31:0] PCBranch_D;                 // Branch Target Address in Decode Stage
        // Mux RD1
            wire [31:0] RD1_D;
            wire [31:0] BranchSrcA_D; //output
        // Mux RD2
            wire [31:0] RD2_D;
            wire [31:0] BranchSrcB_D; //output 
        // Compare 
            wire            EqualD;
            wire            PCSrcD;
        // Floating Point wire Src
            wire [31:0] RawFRD1D;
            wire [31:0] RawFRD2D;
            wire [31:0] FRD1D;
            wire [31:0] FRD2D;
         
    // =========================================================
    // 3. Execute Wire declarations     
    // =========================================================

        // 3.1 ALU Wire declarations
            
            wire [31:0] SrcA_E;                    // Source A for ALU in Execute Stage
            wire [31:0] SrcB_E;                    // Source B for ALU in Execute Stage
            wire [31:0] WriteData_E;              //output // Source B for ALU in Execute Stage after Mux
            wire [31:0] ALUResult_E;               // ALU Result from Execute Stage
            wire        Zero_E;
        // 3.2 Floating Point Unit Wire declarations
            wire [4:0] FRdE;                      // Floating Point Destination Register Number in Execute Stage
        // 3.3 Control Unit Wire declarations
            wire        RegWrite_E;                 // Register Write Enable in Execute Stage
            wire        MemtoReg_E;                 // Memory to Register Control Signal in Execute Stage    
            wire        MemWrite_E;                 // Memory Write Enable in Execute Stage
            wire [2:0]  ALUControl_E;                // ALU Control Signal in Execute Stage
            wire        ALUSrc_E;                    // ALU Source Control Signal in Execute Stage
            wire        RegDst_E;                    // Register Destination Control Signal in Execute Stage
            
            // Floating Point Control Signals
            wire        FpuRegE;                   // Floating Point Register File Control Signal in Execute Stage
            wire        FpuCon_E;  
            wire [1:0] ForwardAE;
            wire [1:0] ForwardBE;                 // Floating Point Control Signal in Execute Stage

            wire [1:0]  FForwardAE;
            wire [1:0]  FForwardBE;

        // 3.4 Mux Wire declarations
            // Mux3 for ALU Source A
                wire [31:0] RD1_E;
                wire [31:0] RD2_E;
                wire [4:0] RsE;                 // Hazard Unit wire


            // Mux3 for ALU Source B
                wire [31:0] SrcB_E_mux;

                
            // Mux2 for ALUScrD Control Signal
                wire [4:0] RtE;    // input
                wire [4:0] RdE;    // input
            // mux For Forwarding for Execute Stage Source A,B

            wire [31:0] FRD1E;             // FPU operand A, post decode-forward, latched
            wire [31:0] FRD2E;             // FPU operand B, post decode-forward, latched
            wire [31:0] SrcA_EF;           // FPU operand A, post Execute-forward mux -> fpu_top
            wire [31:0] SrcB_EF;           // FPU operand B, post Execute-forward mux -> fpu_top

            
            //  Register Write  for Write Back Stage

                wire [4:0]    WriteReg_E;  // Write Register Number in Execute Stage  and output mux ALUScrD

               // wire FForwardSrcA, FForwardSrcB;                    // Forwarding for Execute Stage Source A and Source B for FPU
                wire [31:0] Fpu_Result_E;
                
       // Sign Extended Immediate Value in Execute Stage
                wire [31:0] SignImm_E;                  // Sign Extended Immediate Value in Execute Stage          
        


    // =========================================================    
    // 4. Memory Wire declarations
    // =========================================================
  
        // 4.1 Data Memory Wire declarations
            wire [31:0] ALUResult_M;        // ALU Result from Execute
            wire [31:0] WriteData_M;       // Write Result from Execute
            wire [4:0]  WriteReg_M;          // Write Register from Execute
            wire [31:0] ReadData_M;           // Read Data from Data Memory in Memory Stage
            //
            wire [31:0] Fpu_Result_M;

        // 4.2 Control signals for Memory Stage
            wire        RegWrite_M;             // Register Write Enable in Memory Stage
            wire        MemtoReg_M;             // Memory to Register Control Signal in Memory Stage
            wire        MemWrite_M;             // Memory Write Enable in Memory Stage
        //
            wire [4:0]  FRdM;
            wire        FpuRegM;
    // =========================================================
    // 5. Write Back Wire declarations
    // =========================================================
        // 5.1 Control signals for Write Back Stage
            wire        RegWrite_W;             // Register Write Enable in Write Back Stage
            wire        MemtoReg_W;             // Memory to Register Control Signal in Write Back Stage
            wire        FpuRegW;
        // 5.2 Write Back Mux Wire declarations
            wire [31:0] Result_W;            // Data to be written back to Register File in Write Back Stage
        // Mux2 MemtoReg_W
            wire [31:0] ReadData_W;             //  output pipe  and input0 mux2 MemtoReg_W
            wire [31:0] ALUResult_W;
            wire [31:0] Fpu_Result_W;
        // Pipe
            wire [4:0] WriteReg_W;             // Write Register from Memory Stage and input1 mux2 MemtoReg_W
            wire [4:0]  FRdW;
    // ________________________________________________
    // Note: All Hazard Unit  
    // ---------------- Hazard Unit shared wires ----------------
        wire  FForwardSrcA, FForwardSrcB;
        wire  flushE, flushD, StallD;
        wire [5:0] OpD;  
    // =========================================================
    // 1.(Fetch Stage)
    // =========================================================
      
        // *********************************************************************
        // *** [ PC / FETCH PIPELINE REGISTER ]                               ***
        // *********************************************************************

        pc_reg Dut_pc_register (
            .clk(clk),
            .reset(rst),
            .EN(~StallF),      // Direct connection: StallF freezes the PC when high
            .PC_next(PC_nextF),      // Input: Next PC value
            .PC(PCF)           // Output: Current PC value for Fetch Stage
        );

       
        // Instruction Memory Module (Fetch Stage)
        instr_mem_FIXED #(
        .DEPTH     (1024),
        .INIT_FILE ("program.txt"))
         Dut_instr_mem(
            .A(PCF),
            .RD(Instr_F)

        );

        // PCPlus4_F
        adder Dut_PCPlus4_F (
            .a(PCF),
            .b(32'd4),
            .y(PCPlus4_F)
        );
        // Mux for PC Source (Branch or Next PC)
        mux2 #(.WIDTH(32))
        Dut_mux2_pc_source(
            .d0(PCPlus4_F),
            .d1(PCBranch_D),
            .sel(PCSrcD),
            .y(PC_nextF)
        );

        // *********************************************************************
        // *** [ IF/ID PIPELINE REGISTERS (Combined: Instruction & PC+4) ]    ***
        // *********************************************************************

        param_reg #(.WIDTH(64)) pipe_if_id_combined (
            .clk(clk),
            .rst(rst),
            .clear(flushD),             // Flush signal controlled by the Hazard Unit
            .en(~StallD),                // Stall signal controlled by the Hazard Unit
            .d({Instr_F, PCPlus4_F}),   // Inputs: 32-bit instruction and 32-bit PC+4
            .q({Instr_D, PCPlus4_D})    // Outputs: passed to Decode stage in exact order
        );


    // =========================================================
    // 2. (Decode Stage)
    // =========================================================
        // 2.1 Register File 
        reg_file Dut_reg_file(
            .clk(clk),
            .rst(rst),
            .WE3(RegWrite_W),
            .A1(Instr_D[25:21]),
            .A2(Instr_D[20:16]),
            .A3(WriteReg_W),
            .WD3(Result_W),
            .RD1(RD1_D),
            .RD2(RD2_D),
            .s0_reg(s0_reg)
        
        );


        // 2.2 Control Unit Module (Decode Stage)
        Control_Unit_Pipeline_MIPS_with_FP DUT_control_Unit_Pipeline_MIPS_with_FP(
            .funct(Instr_D[5:0]),
            .op(Instr_D[31:26]),
            .fmt(Instr_D[25:21]),
            .MemtoRegD(MemtoRegD),
            .MemWriteD(MemWriteD),
            .ALUControlD(ALUControlD),
            .ALUSrcD(ALUSrcD),
            .RegDstD(RegDstD),
            .RegWriteD(RegWriteD),
            .BranchD(BranchD),
            // Floating Point Control Signals
            .FpuRegD(FpuRegD),
            .FpuConD(FpuConD)

        );

        assign OpD = Instr_D[31:26];

    
        // 2.3 Sign Extension Module (Decode Stage)
        sign_ext Dut_sign_ext(
            .a(Instr_D[15:0]),
            .y(SignImm_D)   
        );
        // 2.4 Shift Left 2 for Branch Module (Decode Stage)
        Shift_Left_2_Branch_Pipline_MIPS Dut_shift_left_2_branch(
            .SignImmD(SignImm_D),
            .SignImmShiftedD(SignImmShifted_D)
        );
        // 2.5 Mux (Decode Stage)
        mux2 #(.WIDTH(32))
        Dut_out_mux2_RD1(
            .d0(RD1_D),
            .d1(ALUResult_M),
            .sel(ForwardAD),
            .y(BranchSrcA_D)
        );
        mux2 #(.WIDTH(32))
         Dut_out_mux2_RD2(
            .d0(RD2_D),
            .d1(ALUResult_M),
            .sel(ForwardBD),
            .y(BranchSrcB_D)
        );
    equal branch_comparator (
        .SrcA  (BranchSrcA_D),
        .SrcB  (BranchSrcB_D),
        .Equal (EqualD)
    );        // 2.6 Adder (PCPlus4_D+SignImmShifted_D)  Equal       PCBranch_D 
         // Do not take a branch while its operands are stalled
        assign PCSrcD =
                        BranchD &&
                        EqualD  &&
                        !StallD;
        assign flushD = PCSrcD;
        adder Dut_PCBranch_D(
            .a(SignImmShifted_D),
            .b(PCPlus4_D),
            .y(PCBranch_D)
        );
        // 
        // 2.7 Register File (float_reg)
        reg_file Dut_float_reg(
            .clk(clk),
            .rst(rst),
            .WE3(FpuRegW),
            .A1(Instr_D[25:21]),
            .A2(Instr_D[20:16]),
            .A3(FRdW),
            .WD3(Fpu_Result_W),
            .RD1(RawFRD1D),
            .RD2(RawFRD2D)


        );
          // fpu_decode_a_mux / fpu_decode_b_mux exactly, driven by
        // hazard_unit's FForwardSrcA/FForwardSrcB (WB-stage match).
        mux2 #(.WIDTH(32))
        Dut_FPU_decode_A(
            .d0(RawFRD1D),
            .d1(Fpu_Result_W),
            .sel(FForwardSrcA),
            .y(FRD1D)
        );
        mux2 #(.WIDTH(32))
        Dut_FPU_decode_B(
            .d0(RawFRD2D),
            .d1(Fpu_Result_W),
            .sel(FForwardSrcB),
            .y(FRD2D)
        );
       
        // *********************************************************************
        // *** [ ID/EX PIPELINE REGISTERS (Combined: Control, Data, and PC+4) ] ***
        // *********************************************************************

        param_reg #(.WIDTH(185)) Dut_param_reg_id_ex(
            .clk(clk),
            .rst(rst),
            .clear(flushE),             // Flush signal controlled by the Hazard Unit
            .en(1'b1),                  // No stall for ID/EX pipeline register
            .d({RegWriteD, MemtoRegD, MemWriteD, 
                ALUControlD, ALUSrcD, RegDstD, 
                FpuRegD, FpuConD,RD1_D, RD2_D, 
                SignImm_D, Instr_D[25:21], 
                Instr_D[20:16], Instr_D[15:11]
                ,FRD1D,FRD2D}),
            .q({RegWrite_E, MemtoReg_E, MemWrite_E,
                 ALUControl_E, ALUSrc_E, RegDst_E, 
                 FpuRegE, FpuCon_E,RD1_E, RD2_E, 
                 SignImm_E, RsE, RtE, RdE,
                 FRD1E,FRD2E})
        );


    // =========================================================
    // 3. (Execute Stage)
    // =========================================================
        // Mux3 for ALU Source A
        mux3to1 #(.WIDTH(32))
        Dut_Alu_A (
            .d0(RD1_E),
            .d1(Result_W),
            .d2(ALUResult_M),
            .sel(ForwardAE),
            .y(SrcA_E)
        );

        // Mux3 for ALU Source B
        mux3to1 #(.WIDTH(32))
        Dut_Alu_B (
            .d0(RD2_E),
            .d1(Result_W),
            .d2(ALUResult_M),
            .sel(ForwardBE),
            .y(SrcB_E_mux)
        );

        assign WriteData_E = SrcB_E_mux;
        // Mux2 for ALU Control Signal (ALUSrcD)
        mux2 #(.WIDTH(32))
        Dut_ALUSrcD(
            .d0(SrcB_E_mux),
            .d1(SignImm_E),
            .sel(ALUSrc_E),
            .y(SrcB_E)
        );
        // Mux2 Register Write (RegDstD) for Write Back Stage
        mux2 #(.WIDTH(5))
        Dut_RegDstD(
            .d0(RtE),
            .d1(RdE),
            .sel(RegDst_E),
            .y(WriteReg_E)
        );

        // 3.1 ALU Module (Execute Stage)
        alu Dut_alu(
            .SrcA(SrcA_E),
            .SrcB(SrcB_E),
            .ALUControl(ALUControl_E),
            .ALUResult(ALUResult_E),
            .Zero(Zero_E)
        );


         // mux For Forwarding for Decode Stage Source A (FForwardSrcA)
        mux3to1 #(.WIDTH(32))
        Dut_FPU_A(
            .d0(FRD1E),
            .d1(Fpu_Result_W),
            .d2(Fpu_Result_M),
            .sel(FForwardAE),
            .y(SrcA_EF)
        );


        // mux For Forwarding for Decode Stage Source B (FForwardSrcB)
        mux3to1 #(.WIDTH(32))
        Dut_FPU_B(
            .d0(FRD2E),
            .d1(Fpu_Result_W),
            .d2(Fpu_Result_M),
            .sel(FForwardBE),
            .y(SrcB_EF)
        );

        assign FRdE = RdE;

        // 3.2 Floating Point Unit Module (Execute Stage)
        fpu_top Dut_fpu_Top(
            .A(SrcA_EF),                  // input
            .B(SrcB_EF),                  // input
            .Op_Sub(FpuCon_E),          // Control signal to determine addition or subtraction
            .Final_Result(Fpu_Result_E)   // 32-bit floating point result
        );


        // *********************************************************************
        // *** [ EX/MEM PIPELINE REGISTERS (Combined: Control, Data,*** and PC+4) ] ***
        // *********************************************************************

        // WriteReg_E 5_bits
        param_reg #(.WIDTH(110)) Dut_param_reg_ex_mem(
                .clk(clk),
                .rst(rst),
                .clear(1'b0),
                .en(1'b1),
                .d({RegWrite_E, MemtoReg_E, MemWrite_E, ALUResult_E, WriteData_E, WriteReg_E,
                    FpuRegE, Fpu_Result_E, FRdE}),
                .q({RegWrite_M, MemtoReg_M, MemWrite_M, ALUResult_M, WriteData_M, WriteReg_M,
                    FpuRegM, Fpu_Result_M, FRdM})
            );

    // =========================================================
    // 4. Data Memory Module (Memory Stage)
    // =========================================================

    data_mem_FIXED Dut_data_mem(
        .clk(clk),
        .WE(MemWrite_M),
        .A(ALUResult_M),
        .WD(WriteData_M),
        .RD(ReadData_M)
    );
    

    // *********************************************************************
    // *** [ MEM/WB PIPELINE REGISTERS (Combined: Control, Data,
    // *** and Write Register Number) ] ***
    // *********************************************************************
    param_reg #(.WIDTH(109)) Dut_param_reg_mem_wb(
        .clk(clk),
        .rst(rst),
        .clear(1'b0),
        .en(1'b1),
        .d({RegWrite_M, MemtoReg_M, ReadData_M,
             ALUResult_M, WriteReg_M,
            FpuRegM, Fpu_Result_M, FRdM}),
        .q({RegWrite_W, MemtoReg_W, ReadData_W, 
            ALUResult_W, WriteReg_W,
            FpuRegW, Fpu_Result_W, FRdW})
    );


    // =========================================================
    // 5. Write Back Stage
    // =========================================================

    // Mux  (RegDstD) for Write Back Stage
        mux2 #(.WIDTH(32))
        Dut_MemtoReg_M(
            .d0(ALUResult_W),
            .d1(ReadData_W),
            .sel(MemtoReg_W),
            .y(Result_W)
        );
    

    // =========================================================
    // Hazard Unit Int
    // =========================================================
    // Note: All Hazard Unit wires are declared in their respective 
    // pipeline stage sections above to prevent duplicate declarations.
    Hazard_Unit  Dut_hazard_unit(
        .OpD          (OpD),
        .RsD          (Instr_D[25:21]),
        .RtD          (Instr_D[20:16]),
        .RsE          (RsE),
        .RtE          (RtE),
        .WriteRegE    (WriteReg_E),
        .WriteRegM    (WriteReg_M),
        .WriteRegW    (WriteReg_W),
        .RegWriteE    (RegWrite_E),
        .RegWriteM    (RegWrite_M),
        .RegWriteW    (RegWrite_W),
        .MemtoRegE    (MemtoReg_E),
        .MemtoRegM    (MemtoReg_M),
        .BranchD      (BranchD),
        .FRsD         (Instr_D[25:21]),
        .FRtD         (Instr_D[20:16]),
        .FRsE         (RsE),
        .FRtE         (RtE),
        .FRdM         (FRdM),
        .FRdW         (FRdW),
        .FpuRegD      (FpuRegD),
        .FpuRegE      (FpuRegE),
        .FpuRegM      (FpuRegM),
        .FpuRegW      (FpuRegW),
        .ForwardAD    (ForwardAD),
        .ForwardBD    (ForwardBD),
        .ForwardAE    (ForwardAE),
        .ForwardBE    (ForwardBE),
        .FForwardAE   (FForwardAE),
        .FForwardBE   (FForwardBE),
        .FForwardSrcA (FForwardSrcA),
        .FForwardSrcB (FForwardSrcB),
        .StallF       (StallF),
        .StallD       (StallD),
        .FlushE       (flushE)
    );


endmodule

