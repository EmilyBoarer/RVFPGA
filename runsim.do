# set up the "work" library
vlib work
# compile our SystemVerilog files
vlog toptoplevel.sv
vlog verilog/mkToplevel.v
vlog lib/VerilogBlockRAM_OneCycle.v
vlog lib/VerilogBlockRAM_TrueDualPort_OneCycle.v
# point the simulator at the compiled design
vsim work.toptoplevel
# add waveforms to the "Wave" pane
add wave -position insertpoint \
  /toptoplevel/CLK                 \
  /toptoplevel/RST_N                 \
  /toptoplevel/toplevel/s_control_num_enabled                 \
  /toptoplevel/toplevel/s_control_valid_register                 \
  /toptoplevel/toplevel/s_control_valid_valid                 \
  /toptoplevel/toplevel/s_fetch_valid                 \
  /toptoplevel/toplevel/s_decode_valid                 \
  /toptoplevel/toplevel/s_exec_valid                 \
  /toptoplevel/toplevel/s_datmem_valid                 \
  /toptoplevel/toplevel/s_rfup_valid                 \
  /toptoplevel/toplevel/s_control_pc_valid                 \
  /toptoplevel/toplevel/s_control_pc_register                 \
  /toptoplevel/toplevel/s_fetch_pc                 \
  /toptoplevel/toplevel/s_decode_pc                 \
  /toptoplevel/toplevel/s_exec_pc                 \
  /toptoplevel/toplevel/s_datmem_pc                 \
  /toptoplevel/toplevel/s_rfup_pc                 \
  /toptoplevel/CLK \
  /toptoplevel/toplevel/s_rfup_value                 \
  /toptoplevel/toplevel/s_datmem_reserved                 \
  /toptoplevel/toplevel/dataMem_ram/ADDR_B                 \
  /toptoplevel/toplevel/dataMem_ram/DO_B                 \
  /toptoplevel/toplevel/dataMem_ram/DO_VALID_B                 \
  /toptoplevel/toplevel/s_rfup_success                 \
  /toptoplevel/CLK \
  /toptoplevel/toplevel/s_fetch_pc                 \
  /toptoplevel/toplevel/s_decode_pc                 \
  /toptoplevel/toplevel/s_decode_instr                 \
  /toptoplevel/toplevel/s_exec_valid                 \
  /toptoplevel/toplevel/s_exec_rd                 \
  /toptoplevel/toplevel/s_exec_rfrs1                 \
  /toptoplevel/toplevel/s_exec_rfrs2                 \
  /toptoplevel/toplevel/s_exec_imm                 \
  /toptoplevel/toplevel/s_datmem_alu_result                 \
  /toptoplevel/CLK \
  /toptoplevel/toplevel/instrMem_ram/DO\
  /toptoplevel/toplevel/instrMem_ram/DO_VALID\
  /toptoplevel/toplevel/instrMem_ram/RD_ADDR\
  /toptoplevel/toplevel/instrMem_ram/RE\
  /toptoplevel/toplevel/dataMem_ram/ram[0]\
  /toptoplevel/toplevel/dataMem_ram/ram[1]\
  /toptoplevel/toplevel/dataMem_ram/ram[2]\
  /toptoplevel/toplevel/dataMem_ram/ram[3]\
  /toptoplevel/toplevel/dataMem_ram/ram[4]\
  /toptoplevel/toplevel/dataMem_ram/ram[5]\
  /toptoplevel/toplevel/dataMem_ram/ram[6]\
  /toptoplevel/toplevel/dataMem_ram/ram[7]\
  /toptoplevel/toplevel/dataMem_ram/ram[8]\
  /toptoplevel/toplevel/dataMem_ram/ram[9]\
  /toptoplevel/toplevel/dataMem_ram/ram[10]\
  /toptoplevel/toplevel/dataMem_ram/ram[11]\
  /toptoplevel/toplevel/dataMem_ram/ram[12]\
  /toptoplevel/toplevel/dataMem_ram/ram[13]\
  /toptoplevel/toplevel/dataMem_ram/ram[14]\
  /toptoplevel/toplevel/dataMem_ram/ram[15]\
  /toptoplevel/toplevel/dataMem_ram/ram[16]\
  /toptoplevel/toplevel/dataMem_ram/ram[17]\
  /toptoplevel/toplevel/dataMem_ram/ram[18]\
  /toptoplevel/toplevel/dataMem_ram/ram[19]\
  /toptoplevel/toplevel/dataMem_ram/ram[100]\
  /toptoplevel/toplevel/dataMem_ram/ram[101]\
  /toptoplevel/toplevel/dataMem_ram/ram[102]\
  /toptoplevel/toplevel/dataMem_ram/ram[103]\
  /toptoplevel/toplevel/dataMem_ram/ram[104]\
  /toptoplevel/toplevel/dataMem_ram/ram[105]\
  /toptoplevel/toplevel/dataMem_ram/ram[106]\
  /toptoplevel/toplevel/dataMem_ram/ram[107]\
  /toptoplevel/toplevel/dataMem_ram/ram[108]\
  /toptoplevel/toplevel/dataMem_ram/ram[109]\
  /toptoplevel/CLK
# run simulation for 200 nanoseconds
run 100 ps