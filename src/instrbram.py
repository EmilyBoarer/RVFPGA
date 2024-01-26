from bitstring import Bits

## this is code based on the euarch-1 python simulator



# OPCODES
OP     = 0b0110011
OPI    = 0b0010011
LOAD   = 0b0000011
STORE  = 0b0100011
BRANCH = 0b1100011 # branch x0 == x0 as jump

# FUNC3s
ADD        = 0x0
ADDI       = 0x0
SLTI       = 0x2
LOAD_WORD  = 0x2
STORE_WORD = 0x2
BRANCH_EQ  = 0x0 # TODO decide which branch to implement



## define programs
## ===============

def twos(integer, bits):
    x = Bits(int=integer, length=64)
    y = x.bin[-bits:]
    return int(y, 2)

def instr_gen(opcode = 0, rs1 = 0, rs2 = 0, rd = 0, funct3 = 0, I_imm = 0, S_imm = 0, B_imm = 0):# TODO see how it handles negative numbers
    I_imm = twos(I_imm, 13)
    S_imm = twos(S_imm, 13)
    B_imm = twos(B_imm, 13)
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
           ((B_imm & 0b1000000000000) << 19)

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
    instr_gen(opcode=OPI,   funct3=ADDI, rd=5, rs1=0, I_imm=80),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=2, rs1=0, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=0, I_imm=1),

    instr_gen(opcode=OP,    funct3=ADD,  rd=4, rs1=2, rs2=3  ),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=1, rs2=4, S_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=1, rs1=1, I_imm=1),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=2, rs1=3, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=4, I_imm=0),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=1, rs2=5, B_imm=4),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=0, rs2=0, B_imm=-6*4),

    instr_gen(opcode=OPI,   funct3=SLTI),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=0), # -8 in two's compliment
]



## 25th Jan: test program to check data memory writes
## = infinite loop of adding then storing
bram_writes_test_instrs = [
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=0, I_imm=100),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=3, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=3, rs2=3, S_imm=0),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=-4*2),
]

## 26th Jan: test program to check data memory reads (assuming writes)
## = infinite loop of loading, adding then storing
loc = 0 ## place in memory that is used, 1 word here
bram_read_test_instrs = [
    instr_gen(opcode=LOAD,  funct3=LOAD_WORD, rs1=0, rd=3, I_imm=loc),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=3, I_imm=1),
    instr_gen(opcode=STORE, funct3=STORE_WORD, rs1=0, rs2=3, S_imm=loc),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=-4*3),
]


## Write the program to instruction bram load file

## todo account for a hart offset for each instruction

#hart0 # must be all 0s (inefficient I know)
instrs = []
while len(instrs) < 256:
    instrs.append(0)
#hart1
instrs += bram_read_test_instrs
while len(instrs) < 256*2:
    instrs.append(0)
#hart2
instrs += bram_writes_test_instrs
while len(instrs) < 2**(8+4):
    instrs.append(0)


def hexx(i):
    s = hex(i)[2:]
    while len(s) < 8:
        s = "0"+s
    return s

with open("instrbram.txt", "w") as f:
    f.writelines("\n".join([hexx(i) for i in instrs]))

## TODO write to data memory bram file too (once more complicated programs with starting data) ?
