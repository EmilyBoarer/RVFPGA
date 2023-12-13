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


module mkToplevel();

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

    // Connect Fetch -> Decode
    mkConnection(s_fetch.get_valid,   s_decode.put_valid );
    mkConnection(s_fetch.get_pc,      s_decode.put_pc    );
    mkConnection(s_fetch.get_rf,      s_decode.put_rf    );
    
    // Connect Decode -> Execute
    mkConnection(s_decode.get_valid,  s_exec.put_valid   );
    mkConnection(s_decode.get_pc,     s_exec.put_pc      );
    mkConnection(s_decode.get_rf,     s_exec.put_rf      );
    
    // Connect Execute -> Data Memory
    mkConnection(s_exec.get_valid,    s_datmem.put_valid );
    mkConnection(s_exec.get_pc,       s_datmem.put_pc    );
    mkConnection(s_exec.get_rf,       s_datmem.put_rf    );
    
    // Connect Data Memory -> RF Update
    mkConnection(s_datmem.get_valid,  s_rfup.put_valid   );
    mkConnection(s_datmem.get_pc,     s_rfup.put_pc      );
    mkConnection(s_datmem.get_rf,     s_rfup.put_rf      );
    
    // Connect RF Update -> Control
    mkConnection(s_rfup.get_valid,    s_control.put_valid);
    mkConnection(s_rfup.get_pc,       s_control.put_pc   );
    mkConnection(s_rfup.get_rf,       s_control.put_rf   );

    // TODO: connect once implemented:
    // Connect rd
    // Connect RF[rs1]
    // Connect RF[rs2]
    // Connect IMM
    // Connect ALU_OUT
    // Connect VALUE

    // Connect _all the instruction lines_

endmodule


endpackage