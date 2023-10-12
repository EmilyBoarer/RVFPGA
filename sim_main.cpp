#include "VmkToplevel.h"
#include "verilated.h"

// for traces
#include "verilated_vcd_c.h" // for Verilator trace things
#include <sys/stat.h>  // for mkdir

int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    VmkToplevel* top = new VmkToplevel{contextp};

    Verilated::traceEverOn(true);
    VL_PRINTF("Setting up to save traces to vcd/waveforms.vcd\n");
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy (or see below)
    tfp->dumpvars(1, "t");  // trace 1 level under "t"
    mkdir("vcd", 0777);
    tfp->open("vcd/waveforms.vcd");

    int sim_time = 100;

    while (contextp->time() < sim_time && !contextp->gotFinish()) {
        contextp->timeInc(1);
        top->eval();
        tfp->dump(contextp->time());
    }
    tfp->close();
    delete top;
    delete contextp;
    return 0;
}