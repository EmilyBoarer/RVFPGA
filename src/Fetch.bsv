package Fetch;

import GetPut::*;
import Types::*;

export FetchIfc (..);
export mkFetch;

import BRAM::*;

`define perHartAddrBus 6
`define numHartsBitsUB 3
`define instrmemWidth 9
// Add#(`perHartAddrBus, `numHartsBitsUB, `instrmemWidth) // assert perHartAddrBus+numHartsBitsUB == instrmemWidth
typedef Bit#(`instrmemWidth)  InstrMemAddr_T;      // Total: size of addresses of each instruction memory word (so x4 for no. bytes)
typedef Bit#(`perHartAddrBus) InstrMemAddrHart_T;  // per hart ^
typedef Bit#(`numHartsBitsUB) InstrMemHart_T;      // width of hart section of address

function BRAMRequest#(InstrMemAddr_T, Word_T) makeInstrRequest(InstrMemHart_T hart, InstrMemAddrHart_T addr);
    InstrMemAddr_T a = 0;
    a[(`perHartAddrBus+`numHartsBitsUB-1):(`perHartAddrBus)] = hart;
    a[(`perHartAddrBus-1):0] = addr;
    return BRAMRequest{
                        write: False,
                        responseOnWrite:False, // ignored since this is a read
                        address: a, // word address
                        datain: 0 // this field is ignored for reads / just set a placeholder value
    };
endfunction

interface FetchIfc; // using the same types as the rest of the system
    interface Put#(Valid_T) put_valid;
    interface Get#(Valid_T) get_valid;

    interface Put#(PC_T) put_pc;
    interface Get#(PC_T) get_pc;

    interface Put#(RF_T) put_rf;
    interface Get#(RF_T) get_rf;

    interface Get#(Word_T) get_instr;
endinterface

// This stage is responsible for fetching the correct instruction from program memory according to the PC (and valid?)

// the following annotation exists in the BRAM example code .. TODO: does it still need to be here???
(* synthesize *)
module mkFetch(FetchIfc);
    Reg#(Valid_T) valid <- mkReg(0);
    Reg#(PC_T) pc <- mkReg(0);
    Reg#(RF_T) rf <- mkReg(unpack(0));

    BRAM_Configure cfg = defaultValue;
    cfg.memorySize = 0; // this means it determines the memory size from the width of the address type given
    cfg.latency = 1; // "address is registered"
    cfg.outFIFODepth = 3; // "latency+2" .. this means that each fetch will take a total of.. 3 clock cycles? so should initialise the read during datamem stage? which should work, but may need special handling to set fetch address when valid=0 / when first starting
    cfg.loadFormat = tagged Hex "instrbram.txt"; // TODO create instrbram.txt using python
    BRAM1Port#(InstrMemAddr_T, Word_T) instrmem <- mkBRAM1Server(cfg); // do we need a BRAM2 ?
    


        // action
        //     instrmem.portA.request.put(makeRequest(0));
        //     instrmem.portB.request.put(makeRequest(1));
        // endaction
        // action
        //     $display("dut1read[0] = %x", instrmem.portA.response.get);
        //     $display("dut1read[1] = %x", instrmem.portB.response.get);
        // endaction

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


    interface Get get_instr;
        method ActionValue#(Bit#(32)) get ();
            instrmem.portA.request.put(makeInstrRequest(0, pack(pc)[5:0])); // hart 0, pc pc // TODO plug into actual hart value (valid)
            let instr = instrmem.portA.response.get;
            if (valid != 0) begin
                return instr; //32'b00000000000100001000000010010011; // ADDI r7 r7 1 (r7 = r7 + 1)  7=00101 // sample test instruction
            end else begin
                return 0;
            end
        endmethod
    endinterface

endmodule

endpackage


// TODO if BRAM doesn't work with verilator, use macros to define a verilator simulator of BRAM of some kind, 
// so can test things without having to synthesize the while FPGA
// TODO create the BRAM source file with python

// BRAM example from BSV reference guide: -- modified for instruction fetch only

// (* synthesize *)
// module sysBRAMTest();
//     BRAM_Configure cfg = defaultValue;
//     cfg.memorySize = 0 // this means it determines the memory size from the width of the address type given
//     cfg.latency = 1 // "address is registered"
//     cfg.outFIFODepth = 3 // "latency+2" .. this means that each fetch will take a total of.. 3 clock cycles? so should initialise the read during datamem stage? which should work, but may need special handling to set fetch address when valid=0 / when first starting
//     cfg.loadFormat = tagged Hex "instrbram.txt"; // TODO create instrbram.txt using python
//     BRAM2Port#(InstrMemAddr_T, Word_T) instrmem <- mkBRAM2Server(cfg); // do we need a BRAM2 ?
//     //Define StmtFSM to run tests // TODO here onwards
//     // Stmt test =
//     // (seq
// //         delay(10);
// //         ...
//         action
//             instrmem.portA.request.put(makeRequest(0));
//             instrmem.portB.request.put(makeRequest(1));
//         endaction
//         action
//             $display("dut1read[0] = %x", instrmem.portA.response.get);
//             $display("dut1read[1] = %x", instrmem.portB.response.get);
//         endaction
// //         ...
// //         delay(100);
//     // endseq);
//     // mkAutoFSM(test);
// endmodule

// // BRAM example from BSV reference guide:
// import BRAM::*;
// import StmtFSM::*;
// import Clocks::*;
// function BRAMRequest#(Bit#(8), Bit#(8)) makeRequest(Bool write, Bit#(8) addr, Bit#(8) data);
//     return BRAMRequest{
//                         write: write,
//                         responseOnWrite:False,
//                         address: addr,
//                         datain: data
//     };
// endfunction
// (* synthesize *)
// module sysBRAMTest();
//     BRAM_Configure cfg = defaultValue;
//     cfg.allowWriteResponseBypass = False;
//     BRAM2Port#(Bit#(8), Bit#(8)) dut0 <- mkBRAM2Server(cfg);
//     cfg.loadFormat = tagged Hex "bram2.txt";
//     BRAM2Port#(Bit#(8), Bit#(8)) dut1 <- mkBRAM2Server(cfg);
//     //Define StmtFSM to run tests
//     Stmt test =
//     (seq
//         delay(10);
//         ...
//         action
//             dut1.portA.request.put(makeRequest(False, 8’h02, 0));
//             dut1.portB.request.put(makeRequest(False, 8’h03, 0));
//         endaction
//         action
//             $display("dut1read[0] = %x", dut1.portA.response.get);
//             $display("dut1read[1] = %x", dut1.portB.response.get);
//         endaction
//         ...
//         delay(100);
//     endseq);
//     mkAutoFSM(test);
// endmodule