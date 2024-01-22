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

import BlockRam::*;

// Pipeline overview:
//    Control -> Fetch -> Decode -> Execute -> Data Memory R/W -> RF Update -> [repeat] 


module mkToplevel();

    // instruction memory (modified from https://github.com/POETSII/twine/blob/master/rtl/Core.bsv)
    BlockRamOpts instrMemOpts = defaultBlockRamOpts;
    instrMemOpts.initFile = Valid("instrbram.txt"); // TODO I **ASSUME** this is a file name??
    instrMemOpts.registerDataOut = False;
    BlockRam#(Bit#(9), Bit#(32)) instrMem <- mkBlockRamOpts(instrMemOpts);

    // Instantiate all the stages
    // NB: "s_" is short for "stage_"
    ControlIfc  s_control <- mkControl();
    FetchIfc    s_fetch   <- mkFetch(instrMem);
    DecodeIfc   s_decode  <- mkDecode(instrMem);
    ExecIfc     s_exec    <- mkExec();
    DatmemIfc   s_datmem  <- mkDatmem();
    RfupdateIfc s_rfup    <- mkRfupdate();
    // TODO handle when instruction fetch for 1st instruction after enabling without writing random things to memory

    // Connect Control -> Fetch
    mkConnection(s_control.get_valid, s_fetch.put_valid  );
    mkConnection(s_control.get_pc,    s_fetch.put_pc     );
    mkConnection(s_control.get_rf,    s_fetch.put_rf     );

    // Connect Fetch -> Decode
    mkConnection(s_fetch.get_valid,   s_decode.put_valid );
    mkConnection(s_fetch.get_pc,      s_decode.put_pc    );
    mkConnection(s_fetch.get_rf,      s_decode.put_rf    );

    mkConnection(s_fetch.get_instr,   s_decode.put_instr );
    
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