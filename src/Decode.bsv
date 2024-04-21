package Decode;

import GetPut::*;
import Types::*;

import BlockRAMv::*;

export DecodeIfc (..);
export mkDecode;

interface DecodeIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;

    interface Put#(Bool) put_instr;

    interface Get#(Bit#(5)) get_rd;
    interface Get#(Word_T)  get_rfrs1;
    interface Get#(Word_T)  get_rfrs2;
    interface Get#(Word_T)  get_imm;
    interface Get#(CL_T)    get_ctrl;
endinterface

module mkDecode#(BlockRam#(Bit#(12), Bit#(32)) instrMem)(DecodeIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

    Reg#(CL_T) controllines <- mkReg(unpack(0));

    Reg#(Bit#(32)) instr <- mkReg(0); 

    interface Put put_valid;
        method Action put (Valid_T newvalid);
            valid <= newvalid;
        endmethod
    endinterface


    interface Put put_pc;
        method Action put (PC_T newpc);
            pc <= newpc;
        endmethod
    endinterface
    interface Get get_pc;
        method ActionValue#(PC_T) get ();
            return pc;
        endmethod
    endinterface


    interface Put put_rf;
        method Action put (RF_T newrf);
            rf <= newrf;
        endmethod
    endinterface
    interface Get get_rf;
        method ActionValue#(RF_T) get ();
            return rf;
        endmethod
    endinterface


    interface Put put_instr;
        method Action put (Bool doFetch);
            if (instrMem.dataOutValid && doFetch) begin
                instr <= instrMem.dataOut; // TODO check this works properly
            end else begin
                instr <= 255; // TODO replace with a NOP?? or stall-like thing??
            end
        endmethod
    endinterface


    // TODO each of these fucntions are the ones that need the comb logic (+get_valid which is above)
    interface Get get_valid;
        method ActionValue#(Valid_T) get ();
            let decoded = decode_instruction(instr, rf);
            if (decoded.need_to_invalidate) begin
                return 0;
            end else begin
                return valid;
            end
        endmethod
    endinterface
    interface Get get_rd;
        method ActionValue#(Bit#(5)) get ();
            let decoded = decode_instruction(instr, rf);
            return decoded.rd;
        endmethod
    endinterface
    interface Get get_rfrs1;
        method ActionValue#(Word_T) get ();
            let decoded = decode_instruction(instr, rf);
            return decoded.rfrs1;
        endmethod
    endinterface
    interface Get get_rfrs2;
        method ActionValue#(Word_T) get ();
            let decoded = decode_instruction(instr, rf);
            return decoded.rfrs2;
        endmethod
    endinterface
    interface Get get_imm;
        method ActionValue#(Word_T) get ();
            let decoded = decode_instruction(instr, rf);
            return decoded.imm;
        endmethod
    endinterface
    interface Get get_ctrl;
        method ActionValue#(CL_T) get ();
            let decoded = decode_instruction(instr, rf);
            return decoded.cl;
        endmethod
    endinterface

endmodule

typedef struct { // DECODE workings TODO MOVE TO TYPES.BSV
    Bit#(2)  opext;
    Bit#(5)  opcode;
    Bit#(5)  rd;
    Bit#(3)  funct3;
    Bit#(5)  rs1;
    Bit#(5)  rs2;
    Bit#(7)  funct7;
    Bit#(12) funct12;
    Bool     need_to_invalidate; // used to invalidate hart if invalid instruction given = a hacky work-around for this CPU, not RISC-V compliant
    CL_T     cl;
    Word_T   imm;
    Word_T   rfrs1;
    Word_T   rfrs2;
} Decode_T deriving (Bits, Eq);

function Decode_T decode_instruction(Bit#(32) instr, RF_T rf);
    // TODO CREDIT: DECODE LOGIC FROM CLARVI - just transcribed into BSV
    // but actually now ended up following python sim's logic instead, then transcribed again from bluespec to bluespec
    // since implemented as put (was a bad idea). plus used the actual RISC-V spec to inform it too, so actually
    // just really used it for the binary conversions

    Decode_T decoded = ?;
    decoded.opext   = instr[1 :0 ];
    decoded.opcode  = instr[6 :2 ];
    decoded.rd      = instr[11:7 ];
    decoded.funct3  = instr[14:12];
    decoded.rs1     = instr[19:15];
    decoded.rs2     = instr[24:20];
    decoded.funct7  = instr[31:25];
    decoded.funct12 = instr[31:20];
    decoded.need_to_invalidate = False;
    decoded.imm     = 0;
    decoded.rfrs1   = 0;
    decoded.rfrs2   = 0;

    CL_T controllines = ?;
    controllines.alu_pc_in  = False;
    controllines.alu_imm_in = False;
    controllines.alu_op     = AluOps_Unset;
    controllines.alu_br     = False;
    controllines.alu_br_type= BraT_Unset;
    controllines.alu_pc_out = False;
    controllines.data_read  = False;
    controllines.data_write = False;
    controllines.rf_update  = False;
    controllines.isunsigned = False;
    controllines.wrap_shift = False;

    decoded.cl              = controllines;
    

    // invalidate hart if not a valid instruction
    if (decoded.opext != 2'b11) decoded.need_to_invalidate = True; // I expect this assignment to valid to break things if Fetch is implemented properly


    // define binary translations to make it easier to read the decoding code
    `define opcode_branch 5'b11000
    `define opcode_load   5'b00000
    `define opcode_store  5'b01000
    `define opcode_opimm  5'b00100
    `define opcode_op     5'b01100

    `define func3_addsub  3'b000 // TODO check funct7 for if subtract or not
    `define func3_slt     3'b010
    `define func3_sltu    3'b011
    `define func3_and     3'b111
    `define func3_or      3'b110
    `define func3_xor     3'b100
    `define func3_sl      3'b001
    `define func3_sr      3'b101

    `define func3_beq     3'b000
    `define func3_bne     3'b001
    `define func3_blt     3'b100
    `define func3_bltu    3'b110
    `define func3_bge     3'b101
    `define func3_bgeu    3'b111

    `define func3_lw      3'b010

    `define func3_sw      3'b010

    
    case (decoded.opcode)
        // BRANCH ===========
        `opcode_branch: begin
            decoded.imm[4:1]  = instr[11:8];
            decoded.imm[10:5] = instr[30:25];
            decoded.imm[11]   = instr[7];
            decoded.imm[12]   = instr[31];
            if (instr[31] == 1) begin 
                decoded.imm[31:13] = 19'b1111111111111111111; // sign extend the immediate
            end
            // set all these properties (they're the same for all branch instructions)
            decoded.cl.alu_br     = True;
            decoded.cl.alu_pc_in  = True;
            decoded.cl.alu_imm_in = True;
            decoded.cl.alu_op     = AluOps_Add;
            decoded.cl.alu_pc_out = True;
            case (decoded.funct3) 
                `func3_beq: begin // Branch if Equal
                    decoded.cl.alu_br_type= BraT_Eq;
                end
                `func3_bne: begin // Branch if Not Equal
                    decoded.cl.alu_br_type= BraT_Neq;
                end
                `func3_blt: begin // Branch if Equal
                    decoded.cl.alu_br_type= BraT_Lt;
                end
                `func3_bltu: begin // Branch if Equal
                    decoded.cl.alu_br_type= BraT_Lt;
                    decoded.cl.isunsigned = True;
                end
                `func3_bge: begin // Branch if Equal
                    decoded.cl.alu_br_type= BraT_Ge;
                end
                `func3_bgeu: begin // Branch if Equal
                    decoded.cl.alu_br_type= BraT_Ge;
                    decoded.cl.isunsigned = True;
                end
                default: begin  // TODO add other instructions
                    // not supported, so stop hart
                    decoded.need_to_invalidate = True;
                end
            endcase                    
        end

        // LOAD ===========
        `opcode_load: begin
            decoded.imm[11:0] = decoded.funct12;
            if (decoded.imm[11] == 1) begin 
                decoded.imm[31:12] = 20'b11111111111111111111; // sign extend the immediate
            end
            case (decoded.funct3) 
                `func3_lw: begin // Load Word
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Add;
                    decoded.cl.data_read  = True;
                    decoded.cl.rf_update  = True;
                end
                default: begin  // TODO add other instructions
                    // not supported, so stop hart
                    decoded.need_to_invalidate = True;
                end
            endcase
        end

        // STORE ===========
        `opcode_store: begin
            decoded.imm[4:0]  = decoded.rd;
            decoded.imm[11:5] = decoded.funct7;
            if (decoded.imm[11] == 1) begin 
                decoded.imm[31:12] = 20'b11111111111111111111; // sign extend the immediate
            end
            case (decoded.funct3) 
                `func3_sw: begin // Store Word
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Add;
                    decoded.cl.data_write = True;
                end
                default: begin  // TODO add other instructions
                    // not supported, so stop hart
                    decoded.need_to_invalidate = True;
                end
            endcase
        end

        // OP_IMM ==========
        `opcode_opimm: begin
            decoded.imm[11:0] = decoded.funct12;
            if (decoded.imm[11] == 1) begin 
                decoded.imm[31:12] = 20'b11111111111111111111; // sign extend the immediate
            end
            case (decoded.funct3) 
                `func3_addsub: begin // ADDI
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Add;
                    decoded.cl.rf_update  = True;
                end
                `func3_slt: begin // SLTI
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Slt;
                    decoded.cl.rf_update  = True;
                end
                `func3_sltu: begin // SLTIU
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Slt;
                    decoded.cl.isunsigned = True;
                    decoded.cl.rf_update  = True;
                end
                `func3_and: begin // ANDI
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_And;
                    decoded.cl.rf_update  = True;
                end
                `func3_or: begin // ORI
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Or;
                    decoded.cl.rf_update  = True;
                end
                `func3_xor: begin // XORI
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Xor;
                    decoded.cl.rf_update  = True;
                end
                `func3_sl: begin // SLLI
                    decoded.cl.alu_imm_in = True;
                    decoded.cl.alu_op     = AluOps_Lshift;
                    decoded.cl.rf_update  = True;
                end
                `func3_sr: begin // SRLI / SRAI
                    if (decoded.funct7 == 0) begin // logical
                        decoded.cl.alu_imm_in = True;
                        decoded.cl.alu_op     = AluOps_Rshift;
                        decoded.cl.rf_update  = True;
                        decoded.cl.isunsigned = True;
                    end else begin
                        decoded.cl.alu_imm_in = True;
                        decoded.cl.alu_op     = AluOps_Rshift;
                        decoded.cl.wrap_shift = True;
                        decoded.cl.rf_update  = True;
                    end
                end
                default: begin
                    // not supported, so stop hart
                    decoded.need_to_invalidate = True;
                end
            endcase
        end

        // OP ===========
        `opcode_op: begin
            case (decoded.funct3) 
                `func3_addsub: begin // ADD/SUB
                    if (decoded.funct7 == 0) begin // Add
                        decoded.cl.alu_op     = AluOps_Add;
                        decoded.cl.rf_update  = True;
                    end else begin
                        decoded.cl.alu_op     = AluOps_Sub;
                        decoded.cl.rf_update  = True;
                    end
                end
                `func3_slt: begin // SLT
                    decoded.cl.alu_op     = AluOps_Slt;
                    decoded.cl.rf_update  = True;
                end
                `func3_sltu: begin // SLTU
                    decoded.cl.alu_op     = AluOps_Slt;
                    decoded.cl.isunsigned = True;
                    decoded.cl.rf_update  = True;
                end
                `func3_and: begin // AND
                    decoded.cl.alu_op     = AluOps_And;
                    decoded.cl.rf_update  = True;
                end
                `func3_or: begin // OR
                    decoded.cl.alu_op     = AluOps_Or;
                    decoded.cl.rf_update  = True;
                end
                `func3_xor: begin // XOR
                    decoded.cl.alu_op     = AluOps_Xor;
                    decoded.cl.rf_update  = True;
                end
                `func3_sl: begin // SLL
                    decoded.cl.alu_op     = AluOps_Lshift;
                    decoded.cl.rf_update  = True;
                end
                `func3_sr: begin // SRL / SRA
                    if (decoded.funct7 == 0) begin // logical
                        decoded.cl.alu_op     = AluOps_Rshift;
                        decoded.cl.rf_update  = True;
                        decoded.cl.isunsigned = True;
                    end else begin
                        decoded.cl.alu_op     = AluOps_Rshift;
                        decoded.cl.wrap_shift = True;
                        decoded.cl.rf_update  = True;
                    end
                end
                default: begin  // TODO add other instructions
                    // not supported, so stop hart
                    decoded.need_to_invalidate = True;
                end
            endcase
        end

        // OTHER OPCODE ==========
        default: begin // TODO add other instructions
            // Not supported, so stop hart
            decoded.need_to_invalidate = True;
        end  
        
    endcase

    // TODO CREDIT END: DECODE LOGIC FROM CLARVI


    decoded.rfrs1 = case (decoded.rs1)
        0: 0;
        1: rf.r1 ;
        2: rf.r2 ;
        3: rf.r3 ;
        4: rf.r4 ;
        5: rf.r5 ;
        6: rf.r6 ;
        7: rf.r7 ;
        8: rf.r8 ;
        9: rf.r9 ;
        10: rf.r10 ;
        11: rf.r11 ;
        12: rf.r12 ;
        13: rf.r13 ;
        14: rf.r14 ;
        15: rf.r15 ;
        16: rf.r16 ;
        17: rf.r17 ;
        18: rf.r18 ;
        19: rf.r19 ;
        20: rf.r20 ;
        21: rf.r21 ;
        22: rf.r22 ;
        23: rf.r23 ;
        24: rf.r24 ;
        25: rf.r25 ;
        26: rf.r26 ;
        27: rf.r27 ;
        28: rf.r28 ;
        29: rf.r29 ;
        30: rf.r30 ;
        31: rf.r31 ;
    endcase ;

    decoded.rfrs2 = case (decoded.rs2)
        0: 0;
        1: rf.r1 ;
        2: rf.r2 ;
        3: rf.r3 ;
        4: rf.r4 ;
        5: rf.r5 ;
        6: rf.r6 ;
        7: rf.r7 ;
        8: rf.r8 ;
        9: rf.r9 ;
        10: rf.r10 ;
        11: rf.r11 ;
        12: rf.r12 ;
        13: rf.r13 ;
        14: rf.r14 ;
        15: rf.r15 ;
        16: rf.r16 ;
        17: rf.r17 ;
        18: rf.r18 ;
        19: rf.r19 ;
        20: rf.r20 ;
        21: rf.r21 ;
        22: rf.r22 ;
        23: rf.r23 ;
        24: rf.r24 ;
        25: rf.r25 ;
        26: rf.r26 ;
        27: rf.r27 ;
        28: rf.r28 ;
        29: rf.r29 ;
        30: rf.r30 ;
        31: rf.r31 ;
    endcase ;

    return decoded;
endfunction


endpackage