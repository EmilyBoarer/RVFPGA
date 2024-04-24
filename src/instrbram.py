from bitstring import Bits

## this is code based on the euarch-1 python simulator



# OPCODES
OP     = 0b0110011
OPI    = 0b0010011
LOAD   = 0b0000011
STORE  = 0b0100011
BRANCH = 0b1100011 # branch x0 == x0 as jump
LUI    = 0b0110111
AUIPC  = 0b0010111
JAL    = 0b1101111
JALR   = 0b1100111

# FUNC3s
ADD        = 0x0
ADDI       = 0x0
SLTI       = 0x2

ADDSUB  = 0b000
SLT     = 0b010
SLTU    = 0b011
AND     = 0b111
OR      = 0b110
XOR     = 0b100
SL      = 0b001
SR      = 0b101

BRANCH_EQ  = 0x0
BNE     = 0b001
BLT     = 0b100
BLTU    = 0b110
BGE     = 0b101
BGEU    = 0b111

LOAD_WORD  = 0x2
LH      = 0b001
LHU     = 0b101
LB      = 0b000
LBU     = 0b100

STORE_WORD = 0x2
SH      = 0b001
SB      = 0b000



## define programs
## ===============

def twos(integer, bits):
    x = Bits(int=integer, length=64)
    y = x.bin[-bits:]
    return int(y, 2)

def instr_gen(opcode = 0, rs1 = 0, rs2 = 0, rd = 0, funct3 = 0, I_imm = 0, S_imm = 0, B_imm = 0, shift_imm = 0, funct7=0, imm20=0):# TODO see how it handles negative numbers
    I_imm = twos(I_imm, 13)
    S_imm = twos(S_imm, 13)
    B_imm = twos(B_imm, 13)
    ## TODO support LUI/AUIPC/JAL/JALR instructions' immediates
    return opcode | \
           rs1 << 15 |\
           rs2 << 20 |\
           rd  << 7 |\
           funct3 << 12 |\
           I_imm << 20 |\
           ((S_imm & 0b11111) << 7) |\
           ((S_imm & 0b111111100000) << 20) |\
           ((B_imm & 0b11110) << 7) |\
           ((B_imm & 0b11111100000) << 20) |\
           ((B_imm & 0b100000000000) >> 4) |\
           ((B_imm & 0b1000000000000) << 19) |\
           ((shift_imm & 0b11111) << 20) |\
           (funct7 << 30) |\
           (imm20 << 12)

## EXAMPLE / TEST PROGRAMS:
# Add: Approx ASM
# lw    x1, x0, 0
# addi  x2, x1, 5
# sw    x0, x2, 0
# slti  x0, x0, 0  # used to hint to the uarch that this hart is done executing
# beq   x0, x0, -4 # used to loop forever until all harts are done executing
loc = 4*11
add_instrs = [
    instr_gen(opcode=LOAD,  funct3=LOAD_WORD, rs1=0, rd=1, I_imm=loc),
    instr_gen(opcode=OPI,   funct3=ADDI, rs1=1, rd=2, I_imm=5),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc),
    instr_gen(opcode=OPI,   funct3=SLTI),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=0b11111111111111111111111111111000), # -8 in two's compliment
]
add_datas = [
    10
]

# Fibonacci: ASM
# addi  x1, x0, 0  # load immediate, address to save result to (counter).
# addi  x5, x0, 20  # load immediate, number of iterations to perform (max*4).
# addi  x2, x0, 0  # load immediate, a
# addi  x3, x0, 1  # load immediate, b
# add   x4, x2, x3 # c = a+b
# sw    x1, x4, 0  # emit c to memory
# addi  x1, x1, 4  # inc. counter 1 word
# addi  x2, x3, 0  # move, a=b
# addi  x3, x4, 0  # move, b=c
# beq   x1, x5, 4  # loop (max) times
# beq   x0, x0, -28  # jump back to c=a+b line
# slti  x0, x0, 0  # used to hint to the uarch that this hart is done executing
# beq   x0, x0, -4 # used to loop forever until all harts are done executing
fib_instrs = [
    instr_gen(opcode=OPI,   funct3=ADDI, rd=1, rs1=0, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=5, rs1=0, I_imm=20),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=2, rs1=0, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=0, I_imm=1),

    instr_gen(opcode=OP,    funct3=ADD,  rd=4, rs1=2, rs2=3  ),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=1, rs2=4, S_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=1, rs1=1, I_imm=4),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=2, rs1=3, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=4, I_imm=0),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=1, rs2=5, B_imm=2*4),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=0, rs2=0, B_imm=-6*4),

    # instr_gen(opcode=OPI,   funct3=SLTI),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=0), # -8 in two's compliment
]

fib2_instrs = [ ## exactly the same but with a different output address and length
    instr_gen(opcode=OPI,   funct3=ADDI, rd=1, rs1=0, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=5, rs1=0, I_imm=28),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=2, rs1=0, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=0, I_imm=1),

    instr_gen(opcode=OP,    funct3=ADD,  rd=4, rs1=2, rs2=3  ),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=4, rs1=4, I_imm=1), ## bonus instruction to differentiate from normal fib
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=1, rs2=4, S_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=1, rs1=1, I_imm=4),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=2, rs1=3, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=4, I_imm=0),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=1, rs2=5, B_imm=2*4),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=0, rs2=0, B_imm=-7*4),

    # instr_gen(opcode=OPI,   funct3=SLTI),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=0), # -8 in two's compliment
]



## 25th Jan: test program to check data memory writes
## = infinite loop of adding then storing
loc = 100 ## place in memory immediately before where things are stored.
bram_writes_test_instrs = [
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=0, I_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=3, I_imm=4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=3, rs2=3, S_imm=0),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=-4*2),
]

## 26th Jan: test program to check data memory reads (assuming writes)
## = infinite loop of loading, adding then storing
loc = 100 ## place in memory that is used, 1 word here
bram_read_test_instrs = [
    instr_gen(opcode=LOAD,  funct3=LOAD_WORD, rs1=0, rd=3, I_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=3, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=-4*3),
]

## additional adders
loc = 10 ## place in memory that is used, 1 word here
bram_read_test_instrs2 = [
    instr_gen(opcode=LOAD,  funct3=LOAD_WORD, rs1=0, rd=3, I_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=3, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=-4*3),
]
loc = 11 ## place in memory that is used, 1 word here
bram_read_test_instrs3 = [
    instr_gen(opcode=LOAD,  funct3=LOAD_WORD, rs1=0, rd=3, I_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=3, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=-4*3),
]


## TestIOP: ASM

# addi (load 11110000)                  add r0, 240 -> t1
# xori       10101010   -> 01011010     xori t1, 170 -> t1 
# sw                                    sw t1  {=90}
# ori        11110000   -> 11111010     ori t1, 240 -> t1
# sw                                    sw t1  {=250}
# andi       00001111   -> 01011010     andi t1, 15 -> t1
# sw                                    sw t1  {=10}
# slti      100, t1   -> t2
# sw                                    sw t2  {=1}
# slti      0, t1    -> t2
# sw                                    sw t2  {=0}    
# sltiu     100, t1   -> t2
# sw                                    sw t2  {=1}
# sltiu     0, t1    -> t2
# sw                                    sw t2  {=0}        
## TODO add a unsigned test case
# slli      t1, 3 -> t2 
# sw                                    sw t2  {=80}        
# srli      t2, 3 -> t2
# sw                                    sw t2  {=10}   
# addi      t2 2147483648 -> t2 (set most sig bit)
# srai      t2, 3 -> t2 
# sw                                    sw t2  {=?}

loc = 0 ## place in memory that is used, 1 word here
testIOP_instrs = [
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1, rs1=0, I_imm=240),
    instr_gen(opcode=OPI,   funct3=XOR,        rd=1, rs1=1, I_imm=170),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=OR,         rd=1, rs1=1, I_imm=240),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=AND,        rd=1, rs1=1, I_imm=15),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=loc*4),

    instr_gen(opcode=OPI,   funct3=SLT,        rd=2, rs1=1, I_imm=100),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=SLT,        rd=2, rs1=1, I_imm=0),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=SLTI,       rd=2, rs1=1, I_imm=100),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=SLTI,       rd=2, rs1=1, I_imm=0),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc*4),

    instr_gen(opcode=OPI,   funct3=SL,         rd=2, rs1=1, shift_imm=3),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=SR,         rd=2, rs1=2, shift_imm=3),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc*4),
    instr_gen(opcode=OPI,   funct3=SR,         rd=2, rs1=2, shift_imm=3, funct7=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=2, S_imm=loc*4),
]
#expected outputs:
# 90,250,10,1,0,1,0,80,10,?? deciman


## TestOP: ASM

# addi 12 -> r1
# addi 15 -> r2
# add  r1+r2 -> r3
# sw   r3           (27)
# sub  r2-r1 -> r3
# sw   r3           (3)
# sub  r1-r2 -> r3
# sw   r3           (-3)
# slt  r1, r2 -> r3
# sw   r3           (1)
# slt  r2, r1 -> r3
# sw   r3           (0)
# sltu r1, r2 -> r3
# sw   r3           (1)
# sltu r2, r1 -> r3
# sw   r3           (0) // TODO add test case where signedness makes a difference
# and  r1, r2 -> r3
# sw   r3           (12)
# or   r1, r2 -> r3
# sw   r3           (15)
# xor  r1, r2 -> r3
# sw   r3           (3)
# sll  r2<< r1 -> r3
# sw   r3           (61440)
# srl  r3 >> r1 -> r3
# sw   r3           (15)
# sra  r3 >> r1 -> r3
# sw   r3           (0)
# lui  r3 = 0xfffff000
# addi r1 = 3
# srl  r3 >> r1 -> r4
# sw   r4           (0x1FFFFE00)
# sra  r3 >> r1 -> r4
# sw   r4           (0xFFFFFE00)

loc = 1 ## place in memory that is used, 1 word here
testOP_instrs = [
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1,  rs1=0, I_imm=12),
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=2,  rs1=0, I_imm=15),
    instr_gen(opcode=OP,    funct3=ADDSUB,     rd=3,  rs1=1, rs2=2),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=ADDSUB,     rd=3,  rs1=2, rs2=1, funct7=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=ADDSUB,     rd=3,  rs1=1, rs2=2, funct7=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SLT,        rd=3,  rs1=1, rs2=2),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SLT,        rd=3,  rs1=2, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SLTU,       rd=3,  rs1=1, rs2=2),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SLTU,       rd=3,  rs1=2, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=AND,        rd=3,  rs1=2, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=OR,         rd=3,  rs1=2, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=XOR,        rd=3,  rs1=2, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SL,         rd=3,  rs1=2, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SR,         rd=3,  rs1=3, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SR,         rd=3,  rs1=3, rs2=1, funct7=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc*4),

    instr_gen(opcode=LUI,                      rd=3,         imm20=0xfffff),
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1,  rs1=0, I_imm=3),
    instr_gen(opcode=OP,    funct3=SR,         rd=4,  rs1=3, rs2=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=4, S_imm=loc*4),
    instr_gen(opcode=OP,    funct3=SR,         rd=4,  rs1=3, rs2=1, funct7=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=4, S_imm=loc*4),

]

## TestBRA: ASM


# addi r0, 0 -> r1
# beq  r1, r0 -> fail
# bne  r1, r1 -> fail
# blt  r1 < r0 -> fail
# bltu r1 < r0 -> fail
# bge  r1 > r0 -> fail
# bgeu r1 > r0 -> fail
# sw r1
# fail: sw r0

loc = 2 ## place in memory that is used, 1 word here
testBRANCH_instrs = [
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1,  rs1=0, I_imm=12),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=1, rs2=0, B_imm=10*4),
    instr_gen(opcode=BRANCH,funct3=BNE,        rs1=1, rs2=1, B_imm=10*4),
    instr_gen(opcode=BRANCH,funct3=BLT,        rs1=1, rs2=0, B_imm=10*4),
    instr_gen(opcode=BRANCH,funct3=BLTU,       rs1=1, rs2=0, B_imm=10*4),
    instr_gen(opcode=BRANCH,funct3=BGE,        rs1=0, rs2=1, B_imm=10*4),
    instr_gen(opcode=BRANCH,funct3=BGEU,       rs1=0, rs2=1, B_imm=10*4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=loc*4),
]

## TestSL: ASM

# addi 0xffffffff -> r1
# sw   r1 -> mem0
# sh   r1 -> mem1
# sb   r1 -> mem2
# lw   mem0 -> r1
# lh   mem0 -> r1
# lhu  mem0 -> r1
# lb   mem0 -> r1
# lbu  mem0 -> r1

loc = 3 ## place in memory that is used
testMEM_instrs = [
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1,  rs1=0, I_imm=0xfff),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc)*4),
    instr_gen(opcode=STORE, funct3=SH,         rs1=0, rs2=1, S_imm=(loc+1)*4),
    instr_gen(opcode=STORE, funct3=SB,         rs1=0, rs2=1, S_imm=(loc+2)*4),
    instr_gen(opcode=LOAD,  funct3=LOAD_WORD,  rs1=0, rd=1,  I_imm=(loc)*4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+3)*4),
    instr_gen(opcode=LOAD,  funct3=LH,         rs1=0, rd=1,  I_imm=(loc)*4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+3)*4),
    instr_gen(opcode=LOAD,  funct3=LHU,        rs1=0, rd=1,  I_imm=(loc)*4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+3)*4),
    instr_gen(opcode=LOAD,  funct3=LB,         rs1=0, rd=1,  I_imm=(loc)*4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+3)*4),
    instr_gen(opcode=LOAD,  funct3=LBU,        rs1=0, rd=1,  I_imm=(loc)*4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+3)*4),

]


## TestCTRL: ASM

# lui
# auipc

# jal
# jalr

loc = 4 ## place in memory that is used
testMISC_instrs = [
    instr_gen(opcode=LUI,                      rd=1,         imm20=0xfffff),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=loc*4),
    instr_gen(opcode=AUIPC,                    rd=1,         imm20=0xfffff),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=loc*4),
    ## JAL skipping an instruction
    instr_gen(opcode=JAL,                      rd=1,         imm20=0b100000000000),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+1)*4),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+1)*4),
    ## JALR skipping two instructions
    instr_gen(opcode=AUIPC,                    rd=2,         imm20=0),
    instr_gen(opcode=JALR,                     rd=1,  rs1=2, I_imm=12),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+2)*4),
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1,  rs1=1, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+2)*4),
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1,  rs1=1, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+2)*4),
    instr_gen(opcode=OPI,   funct3=ADDSUB,     rd=1,  rs1=1, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=1, S_imm=(loc+2)*4),

]

## Write the program to instruction bram load file

#hart0 # must be all 0s (inefficient I know)
instrs = []
hart = 0
def add_next_hart(new_instrs):
    global instrs
    global hart

    instrs += new_instrs
    hart += 1
    while len(instrs) < 256*(hart):
        instrs.append(0)

add_next_hart([]) ## add 0th hart (never used)
# add_next_hart(testIOP_instrs)
add_next_hart(testOP_instrs)
# add_next_hart(testBRANCH_instrs)
# add_next_hart(testMEM_instrs)
# add_next_hart(testMISC_instrs)
add_next_hart([])
add_next_hart([])
add_next_hart([])
add_next_hart([])
add_next_hart([])

# add_next_hart(fib_instrs)
# add_next_hart(bram_read_test_instrs)
# add_next_hart(bram_writes_test_instrs)
# add_next_hart(fib2_instrs)
# add_next_hart(bram_read_test_instrs2)
# add_next_hart(bram_read_test_instrs3)



def hexx(i):
    s = hex(i)[2:]
    while len(s) < 8:
        s = "0"+s
    return s

with open("instrbram.txt", "w") as f:
    f.writelines("\n".join([hexx(i) for i in instrs]))

## TODO write to data memory bram file too (once more complicated programs with starting data) ?
