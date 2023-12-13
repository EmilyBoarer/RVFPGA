package Control;

import GetPut::*;
import Types::*;
import Util::*; // for mkVReg only

export ControlIfc (..);
export mkControl;

interface ControlIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;
endinterface

module mkControl(ControlIfc);
    // logic for enabling harts (disable / end not done yet)
    Reg#(Valid_T) num_enabled <- mkReg(1);
    // Reg#(PC_T)    initial_pc  <- mkReg(123); // TODO ignore this, just initialise each pc to 0? may work for the tiny scale that we're working with here - each hart has different instruction memory
    // When num_enabled > 0, set that number to be the 'valid' of that hart, set the PC to the starting address, then decrement num_enabled by 1.
    // when num_enabled = 0, just pass the values through untouched.

    // logic for just passing values through
    Reg#(Valid_T) valid <- mkVReg;
    Reg#(PC_T) pc <- mkVReg;
    Reg#(RF_T) rf <- mkVReg;

    interface Put put_valid;
        method Action put (Valid_T newvalid);
            if (num_enabled > 0) begin
                valid <= num_enabled;
                num_enabled <= num_enabled - 1;
            end else begin
                valid <= newvalid;
            end
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

endmodule

endpackage