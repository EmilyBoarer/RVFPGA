package Datmem;

import GetPut::*;
import Types::*;

import BlockRAMv::*;

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

    interface Get#(Bit#(1))    get_success;

    method Bit#(1) getmmapvalue();
endinterface

module mkDatmem#(BlockRamTrueDualPort#(Bit#(9), Bit#(32)) dataMem)(DatmemIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

    Reg#(Bit#(5)) rd <- mkReg(0);
    Reg#(CL_T) controllines <- mkReg(unpack(0));

    Reg#(Word_T) rfrs2 <- mkReg(0);
    Reg#(Word_T) alu_result <- mkReg(0);

    Reg#(Bit#(1)) mmapvalue <- mkReg(0);

    Reg#(Valid_T) reserved <- mkReg(0);
    Reg#(Bit#(1))    success  <- mkReg(0);

    method Bit#(1) getmmapvalue();
        return mmapvalue;
    endmethod


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

            // ATOMICS:  NB: The whole of memory is treated as one rage as far as atomic read and writes are concerned.. so ANY write will invalidate all reservations
            if (controllines.atomic && controllines.data_write) begin
                // SC instruction
                if (reserved == valid) begin
                    success <= 0;
                end else begin
                    success <= 1; // non-zero value means error
                end
            end
            
            // start read from data memory (to be muxed at start of rfupdate stage)
            if (controllines.data_read) begin
                dataMem.putB(False, True, truncate(unpack(alu_result)[31:2]), 0); // ignore 2 least sig bits since LoadWord
                if (controllines.atomic) begin
                    // LR instruction
                    reserved <= valid;
                end
            end else if (controllines.data_write) begin
                // if writing, no matter what we need to invalidate the reserved.
                // we do this now because we have just read it, and we need to set it
                // valid at the same time as we set it invalid
                reserved <= 0;
            end
            
        endmethod
    endinterface


    interface Get get_value;
        method ActionValue#(Word_T) get ();
            if (controllines.data_write) begin
                // ATOMICS checks:
                if (success == 0 || !controllines.atomic) begin
                    // write data, return success=0
                    Bit#(32) target = 0;
                    case (controllines.data_size)
                        DatSize_Word: begin
                            target = rfrs2;
                        end
                        DatSize_HalfWord: begin
                            target[15:0] = rfrs2[15:0];
                        end
                        DatSize_Byte: begin
                            target[7:0] = rfrs2[7:0];
                        end
                    endcase
                    Bit#(9) addr = truncate(unpack(alu_result)[31:2]);
                    if (addr == 511) mmapvalue <= rfrs2[0]; // save to memory mapped value
                    else dataMem.putA(True, False, addr, target); // ignore 2 least sig bits since StoreWord // save to memory
            
                end // else don't write, return error (performed elsewhere)
            end
            return alu_result; // this is mux-ed with read value in rfupdate stage now (NOT as per euarch-2)
        endmethod
    endinterface

    interface Get get_success;
        method ActionValue#(Bit#(1)) get ();
            return success;
        endmethod
    endinterface

endmodule

endpackage