package Toplevel;

import GetPut::*;
import Connectable::*;

import Types::*;

import Control::*;
import Decode::*;


module mkToplevel();

    // Instantiate all the stages
    // NB: "s_" is short for "stage_"
    ControlIfc  s_control <- mkControl();
    DecodeIfc   s_decode  <- mkDecode();
    DecodeIfc   s_exec    <- mkDecode(); //mkExec;      Exec  
    // DecodeIfc   s_datmem  <- mkDecode(); //mkDatmem;    DatMem
    // DecodeIfc   s_rfu_im  <- mkDecode(); //mkRFU_IM;    RFU_IM 
    // TODO handle when instruction fetch for 1st instruction after enabling without writing random things to memory

    // Connect Validity
    mkConnection(s_control.get_valid, s_decode.put_valid );
    mkConnection(s_decode.get_valid,  s_exec.put_valid   ); // TODO creating a cycle with this line breaks something in make verilog
    mkConnection(s_exec.get_valid,    s_control.put_valid); // TODO TEMP REMOVE
    // mkConnection(s_exec.get_valid,    s_datmem.put_valid);
    // mkConnection(s_datmem.get_valid,  s_rfu_im.put_valid);
    // mkConnection(s_rfu_im.get_valid,  s_control.put_valid); // TODO swap instr fetch and control around... ???!!!
    

    // Connect PC
    mkConnection(s_control.get_pc, s_decode.put_pc );
    mkConnection(s_decode.get_pc,  s_exec.put_pc   ); // TODO creating a cycle with this line breaks something in make verilog
    mkConnection(s_exec.get_pc,    s_control.put_pc); // TODO TEMP REMOVE
    // Connect RF


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