package Decode;

import GetPut::*;
import Types::*;

export DecodeIfc (..);
export mkDecode;

interface DecodeIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;

    interface Put#(Bit#(32)) put_instr;

    interface Get#(Bit#(5))  get_rd;
    interface Get#(Word_T) get_rfrs1;
    interface Get#(Word_T) get_rfrs2;
    interface Get#(Word_T) get_imm;
    interface Get#(CL_T)   get_ctrl;

    // TODO get control lines
endinterface

module mkDecode(DecodeIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

    Reg#(Bool) need_to_invalidate <- mkReg(False);

    Reg#(Bit#(5)) rd <- mkReg(0);
    Reg#(Word_T) rfrs1 <- mkReg(0);
    Reg#(Word_T) rfrs2 <- mkReg(0);
    Reg#(Word_T) imm <- mkReg(0);
    Reg#(CL_T) controllines <- mkReg(unpack(0));


    interface Put put_valid;
        method Action put (Valid_T newvalid);
            valid <= newvalid;
        endmethod
    endinterface
    interface Get get_valid;
        method ActionValue#(Valid_T) get ();
            if (need_to_invalidate) begin
                return 0;
            end else begin
                return valid;
            end
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
        method Action put (Bit#(32) instr);
        
            // DECODE OPCODE: // TODO CREDIT: DECODE LOGIC FROM CLARVI - just transcribed into BSV
            Bit#(2)  opext   = instr[1 :0 ];
            Bit#(5)  opcode  = instr[6 :2 ];
            rd              <= instr[11:7 ];
            Bit#(3)  funct3  = instr[14:12];
            Bit#(5)  rs1     = instr[19:15];
            Bit#(5)  rs2     = instr[24:20];
            Bit#(7)  funct7  = instr[31:25];
            Bit#(12) funct12 = instr[31:20];

            // This is used to get around BSV scheduling issues when assigning directly to 'valid'
            need_to_invalidate <= False;

            // invalidate hart if not a valid instruction
            if (opext != 2'b11) need_to_invalidate <= True; // I expect this assignment to valid to break things if Fetch is implemented properly

            // since BSC doesn't allow modification of a struct's field when in a register, create a new
            // instance of the struct and then update that in the code, finally assigning this new instance
            // to the register
            let cl = controllines;
            cl.alu_pc_in  = False;
            cl.alu_imm_in = False;
            cl.alu_add    = False;
            cl.alu_br_eq  = False;
            cl.alu_pc_out = False;
            cl.data_read  = False;
            cl.data_write = False;
            cl.rf_update  = False;

            // define binary translations to make it easier to read the decoding code
            `define opcode_branch 5'b11000
            `define opcode_load   5'b00000
            `define opcode_store  5'b01000
            `define opcode_opimm  5'b00100
            `define opcode_op     5'b01100

            `define func3_addsub  3'b000

            `define func3_beq     3'b000

            `define func3_lw      3'b010

            `define func3_sw      3'b010

            
            case (opcode)
                // BRANCH ===========
                `opcode_branch: begin
                    imm[4:1]  <= instr[11:8];
                    imm[10:5] <= instr[30:25];
                    imm[11]   <= instr[7];
                    imm[12]   <= instr[31];
                    case (funct3) 
                        `func3_beq: begin // ADD/SUB // TODO account for sub option too
                            cl.alu_pc_in  = True;
                            cl.alu_imm_in = True;
                            cl.alu_br_eq  = True;
                            cl.alu_pc_out = True;
                        end
                        default: begin  // TODO add other instructions
                            // not supported, so stop hart
                            need_to_invalidate <= True;
                        end
                    endcase                    
                end

                // LOAD ===========
                `opcode_load: begin
                    imm[11:0] <= funct12;
                    case (funct3) 
                        `func3_lw: begin // ADD/SUB // TODO account for sub option too
                            cl.alu_imm_in = True;
                            cl.alu_add    = True;
                            cl.data_read  = True;
                            cl.rf_update  = True;
                        end
                        default: begin  // TODO add other instructions
                            // not supported, so stop hart
                            need_to_invalidate <= True;
                        end
                    endcase
                end

                // STORE ===========
                `opcode_store: begin
                    imm[4:0]  <= rd;
                    imm[11:5] <= funct7;
                    case (funct3) 
                        `func3_sw: begin // ADD/SUB // TODO account for sub option too
                            cl.alu_imm_in = True;
                            cl.alu_add    = True;
                            cl.data_write = True;
                        end
                        default: begin  // TODO add other instructions
                            // not supported, so stop hart
                            need_to_invalidate <= True;
                        end
                    endcase
                end

                // OP_IMM ==========
                `opcode_opimm: begin
                    imm[11:0] <= funct12;
                    case (funct3) 
                        `func3_addsub: begin // ADD/SUB // TODO account for sub option too
                            cl.alu_imm_in = True;
                            cl.alu_add    = True;
                            cl.rf_update  = True;
                        end
                        default: begin  // TODO add other instructions
                            // not supported, so stop hart
                            need_to_invalidate <= True;
                        end
                    endcase
                end

                // OP ===========
                `opcode_op: begin
                    case (funct3) 
                        `func3_addsub: begin // ADD/SUB // TODO account for sub option too
                            cl.alu_add    = True;
                            cl.rf_update  = True;
                        end
                        default: begin  // TODO add other instructions
                            // not supported, so stop hart
                            need_to_invalidate <= True;
                        end
                    endcase
                end

                // OTHER OPCODE ==========
                default: begin // TODO add other instructions
                    // Not supported, so stop hart
                    need_to_invalidate <= True;
                end  
                
            endcase

            // TODO CREDIT END: DECODE LOGIC FROM CLARVI

            controllines <= cl;

            rfrs1 <= case (rs1)
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

            rfrs2 <= case (rs2)
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

        endmethod
    endinterface

    interface Get get_rd;
        method ActionValue#(Bit#(5)) get ();
            return rd;
        endmethod
    endinterface
    interface Get get_rfrs1;
        method ActionValue#(Word_T) get ();
            return rfrs1;
        endmethod
    endinterface
    interface Get get_rfrs2;
        method ActionValue#(Word_T) get ();
            return rfrs2;
        endmethod
    endinterface
    interface Get get_imm;
        method ActionValue#(Word_T) get ();
            return imm;
        endmethod
    endinterface
    interface Get get_ctrl;
        method ActionValue#(CL_T) get ();
            return controllines;
        endmethod
    endinterface

endmodule

endpackage