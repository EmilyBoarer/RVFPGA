package Exec;

import GetPut::*;
import Types::*;

import BlockRAMv::*;

export ExecIfc (..);
export mkExec;

interface ExecIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;

    interface Put#(Bit#(5)) put_rd;
    interface Put#(Word_T)  put_rfrs1;
    interface Put#(Word_T)  put_rfrs2;
    interface Put#(Word_T)  put_imm;
    interface Put#(CL_T)    put_ctrl;

    interface Get#(Bit#(5)) get_rd;
    interface Get#(Word_T)  get_rfrs2;
    interface Get#(Word_T)  get_alu_result;
    interface Get#(CL_T)    get_ctrl;
endinterface

module mkExec#(BlockRamTrueDualPort#(Bit#(8), Bit#(32)) rfMem)(ExecIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

    Reg#(Bit#(5)) rd <- mkReg(0);
    Reg#(CL_T) controllines <- mkReg(unpack(0));

    Reg#(Word_T) rfrs1 <- mkReg(0);
    Reg#(Word_T) rfrs2 <- mkReg(0);
    Reg#(Word_T) imm <- mkReg(0);

    // TODO function to generate ALU result, called by both get_pc and get_alu_output


    interface Put put_valid;
        method Action put (Valid_T newvalid);
            valid <= newvalid;
        endmethod
    endinterface
    interface Get get_valid;
        method ActionValue#(Valid_T) get ();
            return valid;
        endmethod
    endinterface


    interface Put put_pc;
        method Action put (PC_T newpc);
            pc <= newpc;
        endmethod
    endinterface
    interface Get get_pc;
        method ActionValue#(PC_T) get ();
            if (controllines.alu_pc_out && calc_branching(rfrs1, rfrs2, controllines)) begin
                let result = calc_alu(rfrs1, rfrs2, imm, pc, controllines);
                return result; // TODO should be imm << 1 ???
            end else if (valid != 0) begin
                return pc+4; // +4 since 4 bytes = 1 word
            end else begin
                return pc; // Do nothing if invalid
            end
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


    interface Put put_rd;
        method Action put (Bit#(5) newrd);
            rd <= newrd;
        endmethod
    endinterface
    interface Get get_rd;
        method ActionValue#(Bit#(5)) get ();
            return rd;
        endmethod
    endinterface


    interface Put put_ctrl;
        method Action put (CL_T newctrl);
            controllines <= newctrl;
        endmethod
    endinterface
    interface Get get_ctrl;
        method ActionValue#(CL_T) get ();
            return controllines;
        endmethod
    endinterface


    interface Put put_rfrs2;
        method Action put (Word_T newrfrs2);
            if (rfMem.dataOutValidB) begin
                rfrs2 <= rfMem.dataOutB;
            end
            // rfrs2 <= newrfrs2;
        endmethod
    endinterface
    interface Get get_rfrs2;
        method ActionValue#(Word_T) get ();
            return rfrs2;
        endmethod
    endinterface


    interface Put put_rfrs1;
        method Action put (Word_T newrfrs1);
            if (rfMem.dataOutValidA) begin
                rfrs1 <= rfMem.dataOutA;
            end
            // rfrs1 <= newrfrs1;
        endmethod
    endinterface
    interface Put put_imm;
        method Action put (Word_T newimm);
            imm <= newimm;
        endmethod
    endinterface


    interface Get get_alu_result;
        method ActionValue#(Word_T) get ();
            if (controllines.alu_inc_out) begin
                return pc+4;
            end else begin
                return calc_alu(rfrs1, rfrs2, imm, pc, controllines);
            end
        endmethod
    endinterface


endmodule

// Calculate the alu result, which is then used by both get_pc and get_alu_result, to avoid code duplication
// This is purely combinational logic
function Word_T calc_alu(Word_T rfrs1, Word_T rfrs2, Word_T imm, Word_T pc, CL_T controllines);
    let lhsunsigned = (controllines.alu_pc_in)  ? pc  : rfrs1;
    let rhsunsigned = (controllines.alu_imm_in) ? imm : rfrs2;
    Int#(32) lhssigned = unpack(lhsunsigned); // Cast to a signed integer type
    Int#(32) rhssigned = unpack(rhsunsigned);
    let shamt = rhsunsigned[4:0];

    if (controllines.isunsigned == False || controllines.arith_shift) begin
        // signed, or use signed anyway since want an arithmetic / wrapping shift
        let lhs = lhssigned;
        let rhs = rhssigned;
        if (controllines.alu_op == AluOps_Add) begin
            return pack(lhs + rhs);
        end else if (controllines.alu_op == AluOps_Slt) begin
            return lhs < rhs ? 1 : 0;
        end else if (controllines.alu_op == AluOps_And) begin
            return pack(lhs & rhs);
        end else if (controllines.alu_op == AluOps_Or) begin
            return pack(lhs | rhs);
        end else if (controllines.alu_op == AluOps_Xor) begin
            return pack(lhs ^ rhs);
        end else if (controllines.alu_op == AluOps_Lshift) begin
            return pack(lhs << shamt);
        end else if (controllines.alu_op == AluOps_Rshift) begin
            return pack(lhs >> shamt);
        end else if (controllines.alu_op == AluOps_Passthrough) begin
            return pack(rhs);
        end else begin // Subtract
            return pack(lhs - rhs);
        end 
    end else begin
        // unsigned
        let lhs = lhsunsigned;
        let rhs = rhsunsigned;
        if (controllines.alu_op == AluOps_Add) begin
            return lhs + rhs;
        end else if (controllines.alu_op == AluOps_Slt) begin
            return lhs < rhs ? 1 : 0;
        end else if (controllines.alu_op == AluOps_And) begin
            return lhs & rhs;
        end else if (controllines.alu_op == AluOps_Or) begin
            return lhs | rhs;
        end else if (controllines.alu_op == AluOps_Xor) begin
            return lhs ^ rhs;
        end else if (controllines.alu_op == AluOps_Lshift) begin
            return lhs << shamt;
        end else if (controllines.alu_op == AluOps_Rshift) begin
            return lhs >> shamt;
        end else if (controllines.alu_op == AluOps_Passthrough) begin
            return rhs;
        end else begin // Subtract
            return lhs - rhs;
        end 
    end

endfunction

function Bool calc_branching(Word_T rfrs1, Word_T rfrs2, CL_T controllines);
    if (controllines.alu_br) begin
        case (controllines.alu_br_type)
            BraT_Eq:  begin
                return rfrs1 == rfrs2;
            end
            BraT_Neq: begin
                return rfrs1 != rfrs2;
            end
            BraT_Lt:  begin
                return rfrs1 <  rfrs2;
            end
            BraT_Ge:  begin
                return rfrs1 >= rfrs2;
            end
        endcase
    end else begin
        return True;
    end
endfunction

endpackage