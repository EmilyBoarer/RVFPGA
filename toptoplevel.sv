`include "verilog/mkToplevel.v"

module toptoplevel();
    reg CLK;
    reg RST_N;

    initial begin
        CLK = 0;
        RST_N = 1; // active low
    end
    always #10 CLK <= ~CLK;

    mkToplevel toplevel(CLK, RST_N);

endmodule
