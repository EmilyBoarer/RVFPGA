package Datmem;

import GetPut::*;
import Types::*;

export DatmemIfc (..);
export mkDatmem;

interface DatmemIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;

    interface Put#(Bit#(5)) put_rd;
    interface Put#(Word_T)  put_rfrs2;
    interface Put#(Word_T)  put_alu_result;
    interface Put#(CL_T)    put_ctrl;

    interface Get#(Bit#(5)) get_rd;
    interface Get#(Word_T)  get_value;
    interface Get#(CL_T)    get_ctrl;
endinterface

module mkDatmem(DatmemIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

    Reg#(Bit#(5)) rd <- mkReg(0);
    Reg#(CL_T) controllines <- mkReg(unpack(0));

    Reg#(Word_T) rfrs2 <- mkReg(0);
    Reg#(Word_T) alu_result <- mkReg(0);


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
    interface Put put_alu_result;
        method Action put (Word_T newalu_result);
            alu_result <= newalu_result;
        endmethod
    endinterface


    interface Get get_value;
        method ActionValue#(Word_T) get ();
            if (controllines.data_write) begin
                // TODO write to data memory
            end
            if (controllines.data_read) begin
                // TODO read from data memory
                return 0;
            end else begin
                return alu_result;
            end
        endmethod
    endinterface

endmodule

endpackage