package Rfupdate;

import GetPut::*;
import Types::*;

export RfupdateIfc (..);
export mkRfupdate;

interface RfupdateIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;

    interface Put#(Bit#(5)) put_rd;
    interface Put#(Word_T)  put_value;
    interface Put#(CL_T)    put_ctrl;
endinterface

module mkRfupdate(RfupdateIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

    Reg#(Bit#(5)) rd <- mkReg(0);
    Reg#(Word_T)  value <- mkReg(0);
    Reg#(CL_T) controllines <- mkReg(unpack(0));


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
            if (controllines.rf_update) begin
                let newrf = rf;
                case (rd)
                    0: begin end // can't update r0! - always zero
                    1: newrf.r1 = value;
                    2: newrf.r2 = value;
                    3: newrf.r3 = value;
                    4: newrf.r4 = value;
                    5: newrf.r5 = value;
                    6: newrf.r6 = value;
                    7: newrf.r7 = value;
                    8: newrf.r8 = value;
                    9: newrf.r9 = value;
                    10: newrf.r10 = value;
                    11: newrf.r11 = value;
                    12: newrf.r12 = value;
                    13: newrf.r13 = value;
                    14: newrf.r14 = value;
                    15: newrf.r15 = value;
                    16: newrf.r16 = value;
                    17: newrf.r17 = value;
                    18: newrf.r18 = value;
                    19: newrf.r19 = value;
                    20: newrf.r20 = value;
                    21: newrf.r21 = value;
                    22: newrf.r22 = value;
                    23: newrf.r23 = value;
                    24: newrf.r24 = value;
                    25: newrf.r25 = value;
                    26: newrf.r26 = value;
                    27: newrf.r27 = value;
                    28: newrf.r28 = value;
                    29: newrf.r29 = value;
                    30: newrf.r30 = value;
                    31: newrf.r31 = value;
                endcase
                return newrf;
            end else begin
                return rf;
            end
        endmethod
    endinterface


    interface Put put_rd;
        method Action put (Bit#(5) newrd);
            rd <= newrd;
        endmethod
    endinterface

    interface Put put_ctrl;
        method Action put (CL_T newctrl);
            controllines <= newctrl;
        endmethod
    endinterface

    interface Put put_value;
        method Action put (Word_T newvalue);
            value <= newvalue;
        endmethod
    endinterface

endmodule

endpackage