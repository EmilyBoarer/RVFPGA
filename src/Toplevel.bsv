package Toplevel;

import GetPut::*;
import Connectable::*;

import Types::*;

import Control::*;
import Fetch::*;
import Decode::*;
import Exec::*;
import Datmem::*;
import Rfupdate::*;


// Pipeline overview:
//    Control -> Fetch -> Decode -> Execute -> Data Memory R/W -> RF Update -> [repeat] 


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


module mkToplevel();

    // Init instruction memory
    BRAM_Configure cfg = defaultValue;
    cfg.memorySize = 0; // this means it determines the memory size from the width of the address type given
    cfg.latency = 1; // "address is registered"
    cfg.outFIFODepth = 3; // "latency+2" .. this means that each fetch will take a total of.. 3 clock cycles? so should initialise the read during datamem stage? which should work, but may need special handling to set fetch address when valid=0 / when first starting
    cfg.loadFormat = tagged Hex "instrbram.txt"; // TODO create instrbram.txt using python
    BRAM1Port#(InstrMemAddr_T, Word_T) instrmem <- mkBRAM1Server(cfg); // do we need a BRAM2 ?


    // instrmem.portA.request.put(makeInstrRequest(0, pack(pc)[5:0])); // hart 0, pc pc // TODO plug into actual hart value (valid)
     // TODO connect this in place og fetch_get_instr


    // Instantiate all the stages
    // NB: "s_" is short for "stage_"
    ControlIfc  s_control <- mkControl();
    FetchIfc    s_fetch   <- mkFetch();
    DecodeIfc   s_decode  <- mkDecode();
    ExecIfc     s_exec    <- mkExec();
    DatmemIfc   s_datmem  <- mkDatmem();
    RfupdateIfc s_rfup    <- mkRfupdate();
    // TODO handle when instruction fetch for 1st instruction after enabling without writing random things to memory

    // Connect Control -> Fetch
    mkConnection(s_control.get_valid, s_fetch.put_valid  );
    mkConnection(s_control.get_pc,    s_fetch.put_pc     );
    mkConnection(s_control.get_rf,    s_fetch.put_rf     );
    // TODO trigger instr fetch put here, now that PC is validated/invalidated

    // Connect Fetch -> Decode
    mkConnection(s_fetch.get_valid,   s_decode.put_valid );
    mkConnection(s_fetch.get_pc,      s_decode.put_pc    );
    mkConnection(s_fetch.get_rf,      s_decode.put_rf    );

    // TODO maybe many fetch stages, so one for each cycle it takes to fetch the instruction?? TODO trigger fetch in control stage?

    // mkConnection(s_fetch.get_instr,   s_decode.put_instr );
    mkConnection(instrmem.portA.response.get,   s_decode.put_instr ); // read from 
    
    // Connect Decode -> Execute
    mkConnection(s_decode.get_valid,  s_exec.put_valid   );
    mkConnection(s_decode.get_pc,     s_exec.put_pc      );
    mkConnection(s_decode.get_rf,     s_exec.put_rf      );

    mkConnection(s_decode.get_rd,     s_exec.put_rd      );
    mkConnection(s_decode.get_ctrl,   s_exec.put_ctrl    );
    mkConnection(s_decode.get_rfrs2,  s_exec.put_rfrs2   );

    mkConnection(s_decode.get_rfrs1,  s_exec.put_rfrs1   );
    mkConnection(s_decode.get_imm,    s_exec.put_imm     );
    
    // Connect Execute -> Data Memory
    mkConnection(s_exec.get_valid,    s_datmem.put_valid );
    mkConnection(s_exec.get_pc,       s_datmem.put_pc    );
    mkConnection(s_exec.get_rf,       s_datmem.put_rf    );

    mkConnection(s_exec.get_rd,       s_datmem.put_rd    );
    mkConnection(s_exec.get_ctrl,     s_datmem.put_ctrl  );

    mkConnection(s_exec.get_rfrs2,    s_datmem.put_rfrs2 );
    mkConnection(s_exec.get_alu_result,   s_datmem.put_alu_result);
    
    // Connect Data Memory -> RF Update
    mkConnection(s_datmem.get_valid,  s_rfup.put_valid   );
    mkConnection(s_datmem.get_pc,     s_rfup.put_pc      );
    mkConnection(s_datmem.get_rf,     s_rfup.put_rf      );

    mkConnection(s_datmem.get_rd,     s_rfup.put_rd      );
    mkConnection(s_datmem.get_value,  s_rfup.put_value   );
    mkConnection(s_datmem.get_ctrl,   s_rfup.put_ctrl    );
    
    // Connect RF Update -> Control
    mkConnection(s_rfup.get_valid,    s_control.put_valid);
    mkConnection(s_rfup.get_pc,       s_control.put_pc   );
    mkConnection(s_rfup.get_rf,       s_control.put_rf   );

endmodule


endpackage