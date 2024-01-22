# set up the "work" library
vlib work
# compile our SystemVerilog files
vlog toptoplevel.sv
vlog verilog/mkToplevel.v
# point the simulator at the compiled design
vsim work.toptoplevel
# add waveforms to the "Wave" pane
add wave -position insertpoint \
  /toptoplevel/CLK                 \
  /toptoplevel/RST_N                 \
  /toptoplevel/toplevel/s_control_num_enabled                 \
  /toptoplevel/toplevel/s_control_valid_register                 \
  /toptoplevel/toplevel/s_control_valid_valid                 \
  /toptoplevel/toplevel/s_fetch_valid_register                 \
  /toptoplevel/toplevel/s_decode_valid_register                 \
  /toptoplevel/toplevel/s_exec_valid_register                 \
  /toptoplevel/toplevel/s_datmem_valid_register                 \
  /toptoplevel/toplevel/s_rfup_valid_register                 \
  /toptoplevel/toplevel/s_control_pc_valid                 \
  /toptoplevel/toplevel/s_control_pc_register                 \
  /toptoplevel/toplevel/s_fetch_pc_register                 \
  /toptoplevel/toplevel/s_decode_pc_register                 \
  /toptoplevel/toplevel/s_exec_pc_register                 \
  /toptoplevel/toplevel/s_datmem_pc_register                 \
  /toptoplevel/toplevel/s_rfup_pc_register                 \
  /toptoplevel/toplevel/s_exec_valid_register                 \
  /toptoplevel/toplevel/s_exec_rd                 \
  /toptoplevel/toplevel/s_exec_rfrs1                 \
  /toptoplevel/toplevel/s_exec_rfrs2                 \
  /toptoplevel/toplevel/s_exec_imm                 \
  /toptoplevel/toplevel/s_datmem_alu_result                 \
  /toptoplevel/CLK
# run simulation for 200 nanoseconds
run 100 ps