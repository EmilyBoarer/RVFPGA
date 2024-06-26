package Rfupdate;

import GetPut::*;
import Types::*;

import BlockRAMv::*;

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

module mkRfupdate#(BlockRamTrueDualPort#(Bit#(9), Bit#(32)) dataMem)(RfupdateIfc);
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
            Word_T v;
            if (controllines.data_read && dataMem.dataOutValidB) begin
                v = pack(dataMem.dataOutB);
            end else begin
                v = value;
            end
            if (controllines.rf_update) begin
                let newrf = rf;
                case (rd)
                    0: begin end // can't update r0! - always zero
                    1: newrf.r1 = v;
                    2: newrf.r2 = v;
                    3: newrf.r3 = v;
                    4: newrf.r4 = v;
                    5: newrf.r5 = v;
                    6: newrf.r6 = v;
                    7: newrf.r7 = v;
                    8: newrf.r8 = v;
                    9: newrf.r9 = v;
                    10: newrf.r10 = v;
                    11: newrf.r11 = v;
                    12: newrf.r12 = v;
                    13: newrf.r13 = v;
                    14: newrf.r14 = v;
                    15: newrf.r15 = v;
                    16: newrf.r16 = v;
                    17: newrf.r17 = v;
                    18: newrf.r18 = v;
                    19: newrf.r19 = v;
                    20: newrf.r20 = v;
                    21: newrf.r21 = v;
                    22: newrf.r22 = v;
                    23: newrf.r23 = v;
                    24: newrf.r24 = v;
                    25: newrf.r25 = v;
                    26: newrf.r26 = v;
                    27: newrf.r27 = v;
                    28: newrf.r28 = v;
                    29: newrf.r29 = v;
                    30: newrf.r30 = v;
                    31: newrf.r31 = v;
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