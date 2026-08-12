# --- Clear previous work library ---
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# --- Compiling FPU Modules ---
vlog "fpu/fpu_Alignment.v"
vlog "fpu/fpu_Alu.v"
vlog "fpu/fpu_Normalization.v"
vlog "fpu/fpu_Pack.v"
vlog "fpu/fpu_Top.v"
vlog "fpu/fpu_Unpack.v"

# --- Compiling Core & Basic Datapath Modules ---
vlog "module_s/adder.v"
vlog "module_s/alu.v"
vlog "module_s/Control_Unit_Pipline_MIPS_With_FP.v"
vlog "module_s/data_mem_FIXED.v"
vlog "module_s/equal_block.v"
vlog "module_s/instr_mem_FIXED.v"
vlog "module_s/mux2.v"
vlog "module_s/mux3to1.v"
vlog "module_s/reg_file.v"
vlog "module_s/Shift_Left_2_Branch_Pipline_MIPS.v"
vlog "module_s/sign_ext.v"

# --- Compiling Root Level & Top Modules ---
vlog "hazard_unit.v"
vlog "param_reg.v"
vlog "pc_reg.v"
vlog "top/Top_module_pip_FIXED.v"

# --- Compiling Testbench ---
vlog "top/tb_add_sub_final.v"

# --- Starting Simulation ---
vsim -voptargs=+acc work.tb_add_sub_final

# --- Wave Signals & Windows ---
view wave
view structure
view signals

# --- Organized Clean Waves (Matched to your Top module) ---
add wave -divider {System & Clocks}
add wave /tb_add_sub_final/clk_tb
add wave /tb_add_sub_final/rst_tb

add wave -divider {Fetch & Decode}
add wave -radix hexadecimal /tb_add_sub_final/DUT/PCF
add wave -radix hexadecimal /tb_add_sub_final/DUT/Instr_F
add wave -radix hexadecimal /tb_add_sub_final/DUT/Instr_D
add wave /tb_add_sub_final/DUT/BranchD
add wave /tb_add_sub_final/DUT/EqualD

add wave -divider {Execute Stage}
add wave -radix hexadecimal /tb_add_sub_final/DUT/ALUResult_E
add wave -radix hexadecimal /tb_add_sub_final/DUT/Fpu_Result_E
add wave /tb_add_sub_final/DUT/WriteReg_E

add wave -divider {Memory Stage}
add wave -radix hexadecimal /tb_add_sub_final/DUT/ALUResult_M
add wave -radix hexadecimal /tb_add_sub_final/DUT/WriteData_M
add wave -radix hexadecimal /tb_add_sub_final/DUT/ReadData_M
add wave /tb_add_sub_final/DUT/MemWrite_M

add wave -divider {Writeback & Hazards}
add wave -radix hexadecimal /tb_add_sub_final/DUT/Result_W
add wave /tb_add_sub_final/DUT/RegWrite_W
add wave /tb_add_sub_final/DUT/StallF
add wave /tb_add_sub_final/DUT/StallD
add wave /tb_add_sub_final/DUT/flushE
add wave /tb_add_sub_final/DUT/ForwardAE
add wave /tb_add_sub_final/DUT/ForwardBE

run -all
wave zoom full
