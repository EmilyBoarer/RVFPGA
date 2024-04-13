package Exec;

import GetPut::*;
import Types::*;

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

module mkExec(ExecIfc);
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
            if (controllines.alu_pc_out && (
                (controllines.alu_br_eq) ? (rfrs1 == rfrs2) : True
                )) begin
                let result = calc_alu(rfrs1, rfrs2, imm, pc, controllines);
                return result;
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
            rfrs2 <= newrfrs2;
        endmethod
    endinterface
    interface Get get_rfrs2;
        method ActionValue#(Word_T) get ();
            return rfrs2;
        endmethod
    endinterface


    interface Put put_rfrs1;
        method Action put (Word_T newrfrs1);
            rfrs1 <= newrfrs1;
        endmethod
    endinterface
    interface Put put_imm;
        method Action put (Word_T newimm);
            imm <= newimm;
        endmethod
    endinterface


    interface Get get_alu_result;
        method ActionValue#(Word_T) get ();
            let result = calc_alu(rfrs1, rfrs2, imm, pc, controllines);
            return result;
        endmethod
    endinterface


endmodule

// Calculate the alu result, which is then used by both get_pc and get_alu_result, to avoid code duplication
// This is purely combinational logic
function Word_T calc_alu(Word_T rfrs1, Word_T rfrs2, Word_T imm, Word_T pc, CL_T controllines);
    let lhs = (controllines.alu_pc_in)  ? pc  : rfrs1;
    let rhs = (controllines.alu_imm_in) ? imm : rfrs2;
    if (controllines.alu_add) begin
        return lhs + rhs;
    end else begin
        // unused code // when adding sub instructions, ensure these are the correct way around!
        return lhs - rhs;
    end
endfunction

endpackage