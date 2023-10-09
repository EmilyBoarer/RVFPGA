# Emily Boarer 2023 - Part II Project:

# Built for \tex{E\mu Arch--1}
# A simple microarchitecture - level simulator

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

# TODO check little-endian when implementing data memory things?

# Control Lines
ALU_PC_IN = 0
ALU_IMM_IN = 1
ALU_ADD = 2
ALU_BR_EQ = 3
ALU_PC_OUT = 4
DATA_READ = 5
DATA_WRITE = 6
RF_UPDATE = 7


# Define Memories
instr_mem_addr_width = 5
data_mem_addr_width = 5

instr_mem = [0 for _ in range(2**instr_mem_addr_width)]
data_mem = [0 for _ in range(2**data_mem_addr_width)]

# valid attrribute:
# 0 = invalid
# 1-4 = hartID - rename to HartID or similar for FPGA version?

## Define Pipeline Stages
## ======================
## Scribing latching with calc() and pass_on()
## all other functions should translate to combinational logic trivially

class RegisterFile:
    def __init__(self):
        # contains empty value for 0, which would be ignored 
        # on FPGA version. It's here to make the code cleaner
        self.regs = [0 for _ in range(32)]
    def set(self, r, v):
        print(f"set r{r} to {v}")
        self.regs[r] = v
    def get(self, r):
        print(f"get r{r} = {self.regs[r]}")
        return self.regs[r]

class PipelineStage1_Decode:
    def __init__(self):
        # inputs to pipeline stage
        self.pc = 0
        self.rf = RegisterFile()
        self.instr = 0
        self.valid = 0

    def calc(self):
        self.out_pc = self.pc
        self.out_rf = self.rf
        self.out_rfrs1 = self.comb_rfrs1() if self.valid != 0 else 0
        self.out_rfrs2 = self.comb_rfrs2() if self.valid != 0 else 0
        self.out_rd    = self.comb_rd() if self.valid != 0 else 0
        self.out_imm   = self.comb_imm() if self.valid != 0 else 0
        self.out_control    = self.comb_control_lines() if self.valid != 0 else []
        self.out_valid = self.valid
    def pass_on(self):
        return (
            self.out_pc,
            self.out_rf,
            self.out_rfrs1,
            self.out_rfrs2,
            self.out_rd,
            self.out_imm,
            self.out_control,
            self.out_valid)
    
    def comb_rfrs1(self):
        r = (self.instr & 0b11111000000000000000) >> 15
        return self.rf.get(r) if r != 0 else 0
    def comb_rfrs2(self):
        r = (self.instr & 0b1111100000000000000000000) >> 20
        return self.rf.get(r) if r != 0 else 0
    def comb_rd(self):
        return (self.instr & 0b111110000000) >> 7
    
    def comb_imm(self):
        opcode = self.instr & 0b1111111

        if opcode in [OP]:
            return 0
        if opcode in [OPI, LOAD]:
            # I-type instructions
            return (self.instr & 0b11111111111100000000000000000000) >> 20
        if opcode in [STORE]:
            # S-type instructions
            return ((self.instr & 0b111110000000) >> 7) | ((self.instr & 0b11111110000000000000000000000000) >> 20)
        if opcode in [BRANCH]:
            # B-type instructions
            temp = ((self.instr & 0b00000000000000000000111100000000) >> 7)  | \
                   ((self.instr & 0b01111110000000000000000000000000) >> 20) | \
                   ((self.instr & 0b00000000000000000000000010000000) << 4)  | \
                   ((self.instr & 0b10000000000000000000000000000000) >> 19)
            
            # print(f"temp: {temp} / {bin(temp)}")
            
            # # TODO REMOVE THIS BODGE:
            if temp == 0:
                temp = -4
            if temp == 24:
                temp = -24
            # negative numbers and two's compliment are not playing ball with this simply python demo
            return temp
    
    def comb_control_lines(self):
        opcode = self.instr & 0b1111111
        funct3 = (self.instr & 0b111000000000000) >> 12
        if opcode in [OP]:
            if funct3 == ADD:
                print("ADD")
                return [ALU_ADD, RF_UPDATE]
            
        if opcode in [OPI]:
            if funct3 == ADDI:
                print("ADDI")
                return [ALU_IMM_IN, ALU_ADD, RF_UPDATE]
            if funct3 == SLTI:
                print("HALT REACHED")
                self.valid = 0 # disable future execution
                return []
            
        if opcode in [LOAD]:
            if funct3 == LOAD_WORD:
                print("LW")
                return [ALU_IMM_IN, ALU_ADD, DATA_READ, RF_UPDATE]
            
        if opcode in [STORE]:
            if funct3 == STORE_WORD:
                print("SW")
                return [ALU_IMM_IN, ALU_ADD, DATA_WRITE]
        
            
        if opcode in [BRANCH]:
            if funct3 == BRANCH_EQ:
                print("BEQ")
                return [ALU_PC_IN, ALU_IMM_IN, ALU_BR_EQ, ALU_PC_OUT]
            
        return [] # not implemented, treat as no-op


class PipelineStage2_Execute:
    def __init__(self):
        # inputs to pipeline stage
        self.pc = 0
        self.rf = RegisterFile()
        self.rfrs1 = 0
        self.rfrs2 = 0
        self.rd = 0
        self.imm = 0
        self.control = []
        self.valid = 0

    def calc(self):
        self.out_alu = self.comb_alu()
        self.out_pc = self.comb_pc()
        self.out_rf = self.rf
        self.out_rfrs2 = self.rfrs2
        self.out_rd    = self.rd
        self.out_control = self.control
        self.out_valid = self.valid
    def pass_on(self):
        return (
            self.out_pc,
            self.out_rf,
            self.out_rd,
            self.out_alu,
            self.out_rfrs2,
            self.out_control,
            self.out_valid)
    def comb_alu(self):
        alu_in1 = self.pc if ALU_PC_IN in self.control else self.rfrs1
        alu_in2 = self.imm if ALU_IMM_IN in self.control else self.rfrs2

        alu_sum = alu_in1 + alu_in2

        if ALU_ADD in self.control:
            return alu_sum
        
        alu_eq = self.rfrs1 == self.rfrs2

        if ALU_BR_EQ in self.control:
            if alu_eq:
                return alu_sum # will have been set to ALU_PC_IN, ALU_IMM_IN, but not ALU_ADD
            else:
                return self.pc+4
        return 0
            
    def comb_pc(self):
        return self.out_alu if ALU_PC_OUT in self.control else self.pc+4 # advance one word, or according to ALU (pc+imm)
        
class PipelineStage3_DataMemory:
    def __init__(self):
        # inputs to pipeline stage
        self.pc = 0
        self.rf = RegisterFile()
        self.rd = 0
        self.alu_result = 0
        self.rfrs2 = 0
        self.control = []
        self.valid = 0

    def calc(self):
        self.out_pc = self.pc
        self.out_data = self.comb_data()
        self.out_rf = self.rf
        self.out_rd    = self.rd
        self.out_control = self.control
        self.out_valid = self.valid
    def pass_on(self):
        return (
            self.out_pc,
            self.out_rf,
            self.out_rd,
            self.out_data,
            self.out_control,
            self.out_valid)
    def comb_data(self):
        global data_mem
        if DATA_WRITE in self.control and self.valid != 0:
            print(f"Writing to memory: {self.alu_result}: {self.rfrs2}")
            data_mem[self.alu_result//4] = self.rfrs2
        if DATA_READ in self.control and self.valid != 0:
            print(f"Reading from memory: {self.alu_result}: {data_mem[self.alu_result//4]}")
            return data_mem[self.alu_result//4]
        else:
            return self.alu_result
    
class PipelineStage4_0_RegUpdate_InstrMemory:
    def __init__(self):
        # inputs to pipeline stage
        self.pc = 0 # TODO change for each pipeline stage? different instr mem for each hart??
        self.rf = RegisterFile()
        self.rd = 0
        self.data = 0
        self.valid = 0
        self.control = []

    def calc(self):
        self.out_pc = self.pc if self.valid != 0 else 0
        self.out_rf = self.comb_rf() # simple combinational logic
        self.out_instr = self.comb_instr_fetch()
        self.out_valid = self.valid
    def pass_on(self):
        return (
            self.out_pc,
            self.out_rf,
            self.out_instr,
            self.out_valid)
    def comb_rf(self):
        ## TODO account for x0
        if RF_UPDATE in self.control and self.valid != 0:
            self.rf.set(self.rd, self.data)
        return self.rf # TODO hopefully this doesn't need to be copied!??
    def comb_instr_fetch(self):
        if self.valid != 0:
            return instr_mem[self.valid][self.out_pc//4]
        return 0

## define programs
## ===============

def instr_gen(opcode = 0, rs1 = 0, rs2 = 0, rd = 0, funct3 = 0, I_imm = 0, S_imm = 0, B_imm = 0):# TODO see how it handles negative numbers
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
    instr_gen(opcode=OPI,   funct3=ADDI, rd=1, rs1=1, I_imm=4),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=2, rs1=3, I_imm=0),
    instr_gen(opcode=OPI,   funct3=ADDI, rd=3, rs1=4, I_imm=0),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=1, rs2=5, B_imm=4),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ,  rs1=0, rs2=0, B_imm=24), # TODO get neg imms working

    instr_gen(opcode=OPI,   funct3=SLTI),
    instr_gen(opcode=BRANCH,funct3=BRANCH_EQ, rs1=0, rs2=0, B_imm=0), # -8 in two's compliment
]


# TODO compare against online simulator?


## set up for running:
# instr_mem = add_instrs+instr_mem
# data_mem = add_datas+data_mem

instr_mem = [[],fib_instrs,add_instrs] # one set of instruction memory for each hart
data_mem = [0 for _ in range(10)] + [0,17,0,0,0,0] # fib space, one space, then add, then 4 free words


## Running Simulation
## ==================

s1 = PipelineStage1_Decode()
s2 = PipelineStage2_Execute()
s3 = PipelineStage3_DataMemory()
s4_0 = PipelineStage4_0_RegUpdate_InstrMemory()


for i in range(300):
    if i == 0:
        s4_0.valid=1
    if i == 1:
        s4_0.valid=2


    if s1.valid != 0:
        print(f"")
        print(f"S1 PC:    {s1.pc}")

    s1.calc()
    s2.calc()
    s3.calc()
    s4_0.calc()
    
    s1.pc, s1.rf, s1.instr, s1.valid = s4_0.pass_on()
    s2.pc, s2.rf, s2.rfrs1, s2.rfrs2, s2.rd, s2.imm, s2.control, s2.valid = s1.pass_on()
    s3.pc, s3.rf, s3.rd, s3.alu_result, s3.rfrs2, s3.control, s3.valid = s2.pass_on()
    s4_0.pc, s4_0.rf, s4_0.rd, s4_0.data, s4_0.control, s4_0.valid = s3.pass_on()

    if s1.valid + s2.valid + s3.valid + s4_0.valid == 0 :
        break


print("\nfinal memory:")
print("\n".join([str(i) for i in data_mem[:15]]))