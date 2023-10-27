module toptoplevel();
    reg CLK;
    reg RST_N;

    initial begin
        CLK = 0;
        RST_N = 0;
    end
    always #10 CLK <= ~CLK;

    mkToplevel toplevel(CLK, RST_N);

endmodule