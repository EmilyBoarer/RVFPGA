package Fetch;

import GetPut::*;
import Types::*;

import BlockRAMv::*;

export FetchIfc (..);
export mkFetch;

interface FetchIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;

    interface Get#(Bool) get_instr;
endinterface

// This stage is responsible for fetching the correct instruction from program memory according to the PC (and valid?)

module mkFetch#(BlockRam#(Bit#(12), Bit#(32)) instrMem)(FetchIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

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
            Bit#(12) addr;
            addr[7:0] = truncate(unpack(pc)[31:2]);
            addr[11:8] = unpack(valid);
            instrMem.read(addr);
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


    interface Get get_instr;
        method ActionValue#(Bool) get ();
            if (valid != 0) begin
                // return 32'b00000000000100001000000010010011; // ADDI r7 r7 1 (r7 = r7 + 1)  7=00101 // sample test instruction
                return True;
            end else begin
                // return 0;
                return False;
            end
        endmethod
    endinterface

endmodule

endpackage