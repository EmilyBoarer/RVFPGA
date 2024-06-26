package Types;

export PC_T;
export Word_T;
export Valid_T;
export RF_T (..);
export CL_T (..);


// define types used throughout the implementation
typedef Bit#(32)  PC_T;
typedef Bit#(32)  Word_T;  // Used in most places in the computer
typedef Bit#(4)  Valid_T;

typedef struct  {
    Word_T r1;
    Word_T r2;
    Word_T r3;
    Word_T r4;
    Word_T r5;
    Word_T r6;
    Word_T r7;
    Word_T r8;
    Word_T r9;
    Word_T r10;
    Word_T r11;
    Word_T r12;
    Word_T r13;
    Word_T r14;
    Word_T r15;
    Word_T r16;
    Word_T r17;
    Word_T r18;
    Word_T r19;
    Word_T r20;
    Word_T r21;
    Word_T r22;
    Word_T r23;
    Word_T r24;
    Word_T r25;
    Word_T r26;
    Word_T r27;
    Word_T r28;
    Word_T r29;
    Word_T r30;
    Word_T r31;
} RF_T deriving (Bits, Eq);

typedef struct { // Control Lines
    Bool alu_pc_in;
    Bool alu_imm_in;
    Bool alu_add;
    Bool alu_br_eq;
    Bool alu_pc_out;
    Bool data_read;
    Bool data_write;
    Bool rf_update;
    Bool branch_eq;
} CL_T deriving (Bits, Eq);


endpackage