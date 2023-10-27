# Copyright Emily Boarer 2023

# Used to store generated verilog which can be used for synthesis or simulation
verilog_dir = verilog

# Used to store intermediate temporary files used during compilation
intermediate_dir = tmp

# Information about what to compile
top_level_src_file = src/Toplevel.bsv
top_level_module = mkToplevel

all: verilog verilate simulate analyse

model: verilog verilate

sim: simulate analyse

verilog: clean
	@echo "";
	@echo "Compiling: BSV -> Verilog using Bluespec Compiler";
	mkdir $(intermediate_dir)
	mkdir $(verilog_dir)
	/home/emily/toolchains/bsc/bsc/inst/bin/bsc \
		-verilog \
		-g $(top_level_module) \
		-bdir $(intermediate_dir) \
		-vdir $(verilog_dir) \
		$(top_level_src_file)

verilate:
	@echo "Verilating & Compiling: Verilog -> C++ cycle accurate model using Verilator"
	@echo "Verilating: Verilog -> C++ cycle accurate model using Verilator"
	@echo "Compiling: C++ model -> Binary using GPP"
	verilator --cc --exe --build \
		-j 0 -Wall \
		--timing \
		--trace \
		--coverage \
		-Wno-ZERODLY \
		-Wno-UNUSEDSIGNAL \
		sim_main.cpp \
		toptoplevel.v
# $(verilog_dir)/$(top_level_module).v
	@echo "Verilator done."

simulate:
	@echo "Running Model"
# increased risk of reset bugs, but better performance:
	obj_dir/V$(top_level_module) +trace
# -O3 --x-assign fast --x-initial fast --noassert
# > waveforms.vcd

analyse:
	@echo "Launching GTKWave for analysis"
	gtkwave vcd/waveforms.vcd

clean:
	@echo "cleaning up generated files"
	rm -rf $(intermediate_dir)
	rm -rf $(verilog_dir)
	rm -rf obj_dir
	rm -rf vcd
