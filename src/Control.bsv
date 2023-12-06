package Control;

import GetPut::*;
import Types::*;

export ControlIfc (..);
export mkControl;

interface ControlIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    // TODO only need to add RF
endinterface

module mkControl(ControlIfc);
    // logic for enabling harts (disable / end not done yet)
    Reg#(Valid_T) num_enabled <- mkReg(1);
    Reg#(PC_T)    initial_pc  <- mkReg(123); // TODO handle differently if want different starting addresses for each hart
    // When num_enabled > 0, set that number to be the 'valid' of that hart, set the PC to the starting address, then decrement num_enabled by 1.
    // when num_enabled = 0, just pass the values through untouched.

    // logic for just passing values through
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);

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
            if (num_enabled > 0) begin
                pc <= initial_pc;
                // num_enabled <= num_enabled - 1; // done in put_valid
            end else begin
                pc <= newpc;
            end
        endmethod
    endinterface
    interface Get get_pc;
        method ActionValue#(PC_T) get ();
            return pc;
        endmethod
    endinterface

endmodule

endpackage