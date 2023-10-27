package Toplevel;

// define types used throughout the implementation
typedef Bit#(32)  Word_T;
typedef UInt#(32) Word_UI_T;
typedef UInt#(3)  Valid_T;

// instruction types
typedef Bit#(7)   OPCODE_T;
typedef UInt#(5)  RF_field_T;
typedef Bit#(3)   Funct3_T;
typedef Bit#(3)   Funct7_T;
// typedef Int#(7)  I_IMM_T; // TODO IMM types

typedef struct {
    OPCODE_T   opcode;
    RF_field_T rd;
    Funct3_T   funct3;
    RF_field_T rs1;
    RF_field_T rs2;
    Funct7_T   funct7;
} ITypeInstruction_T deriving (Bits, Eq);

module mkToplevel();
    // rule increment;
    //     $display("Hello World");
    //     $finish();
    // endrule

    // // DECODE output registers in terms of combinational logic on instruction and RF
    // Reg#(RF_field_T) rd <- mkReg(0);
    // method Action set_instr(Word_T instr);
    //     // TODO put instr to ITypeInstruction_T and then decode.
    // endmethod

    // TEMP: pipeline experiments
    Reg#(Valid_T) s0 <- mkReg(0);
    Reg#(Valid_T) s1 <- mkReg(0);
    Reg#(Valid_T) s2 <- mkReg(0);

    

    rule increment;
        $display("s0:", fshow(s0));
        $display("s1:", fshow(s1));
        $display("s2:", fshow(s2));
        s0 <= s0 + 1;
        s1 <= s0;
        if (s1 == 2) begin
            s2 <= s1;
        end
    endrule

endmodule


endpackage