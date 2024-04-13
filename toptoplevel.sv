`include "verilog/mkToplevel.v"
`include "lib/VerilogBlockRAM_OneCycle.v"
`include "lib/VerilogBlockRAM_TrueDualPort_OneCycle.v"

module toptoplevel();
    reg CLK;
    reg RST_N;

    initial begin
        CLK = 0;
        RST_N = 0; // active low
        #2 RST_N = 1; // active low
    end
    always #1 CLK <= ~CLK;

    mkToplevel toplevel(CLK, RST_N);

endmodule
