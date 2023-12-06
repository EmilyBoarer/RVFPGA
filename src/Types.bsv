package Types;

export PC_T;
export Word_T;
export Valid_T;
export RSD_T;


// define types used throughout the implementation
typedef Bit#(32)  PC_T;
typedef Bit#(32)  Word_T;  // Used in most places in the computer
typedef UInt#(4)  Valid_T;
typedef UInt#(5)  RSD_T;   // rs1/rs2/rd


endpackage