package Types;

export PC_T;
export Word_T;
export Valid_T;
export RF_T (..);
export CL_T (..);
export AluOps (..);
export BraT (..);
export DatSize (..);


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

typedef enum {
    AluOps_Unset,
    AluOps_Add,
    AluOps_Sub,
    AluOps_Slt,
    AluOps_And,
    AluOps_Or,
    AluOps_Xor,
    AluOps_Lshift,
    AluOps_Rshift,
    AluOps_Passthrough
} AluOps deriving (Eq, Bits);

typedef enum {
    BraT_Unset,
    BraT_Eq,
    BraT_Neq,
    BraT_Lt,
    BraT_Ge
} BraT deriving (Eq, Bits);

typedef enum {
    DatSize_Word,
    DatSize_HalfWord,
    DatSize_Byte
} DatSize deriving (Eq, Bits);

typedef struct { // Control Lines
    Bool alu_pc_in;
    Bool alu_imm_in;
    AluOps alu_op;
    Bool alu_br;
    BraT alu_br_type;
    Bool alu_pc_out;
    Bool data_read;
    Bool data_write;
    Bool data_unsigned;
    DatSize data_size;
    Bool rf_update;
    Bool branch_eq;
    Bool isunsigned; // TODO rename e.g. to: ALU unsigned
    Bool arith_shift;
    Bool alu_inc_out; // for JAL/JALR
    Bool atomic;
} CL_T deriving (Bits, Eq);


endpackage