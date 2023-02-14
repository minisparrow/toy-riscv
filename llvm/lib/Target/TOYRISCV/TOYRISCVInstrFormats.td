// Spec 2.2 Base Instruction Formats
//
//  31      30 29 28 27 26 25 24 23 22 21   20   19 18 17 16 15 14 13 12 11 10 9 8     7   6 5 4 3 2 1 0
// ┌─────────────────────────┬──────────────────┬──────────────┬────────┬─────────────────┬─────────────┐
// │         funct7          │       rs2        │     rs1      │ funct3 │       rd        │   opcode    │ R-type
// ├─────────────────────────┴──────────────────┼──────────────┼────────┼─────────────────┼─────────────┤
// │                imm[11:0]                   │     rs1      │ funct3 │       rd        │   opcode    │ I-type
// ├─────────────────────────┬──────────────────┼──────────────┼────────┼─────────────────┼─────────────┤
// │        imm[11:5]        │       rs2        │     rs1      │ funct3 │   imm[4:0]      │   opcode    │ S-type
// ├───────┬─────────────────┼──────────────────┼──────────────┼────────┼─────────┬───────┼─────────────┤
// │imm[12]│    imm[10:5]    │       rs2        │     rs1      │ funct3 │imm[4:1] │imm[11]│   opcode    │ B-type
// ├───────┴─────────────────┴──────────────────┴──────────────┴────────┼─────────┴───────┼─────────────┤
// │                             imm[31:12]                             │       rd        │   opcode    │ U-type
// ├───────┬────────────────────────────┬───────┬───────────────────────┼─────────────────┼─────────────┤
// │imm[20]│         imm[10:1]          │imm[11]│      imm[19:12]       │       rd        │   opcode    │ J-type
// └───────┴────────────────────────────┴───────┴───────────────────────┴─────────────────┴─────────────┘

class RISCVOpcode<string name, bits<7> val> {
  string Name = name;
  bits<7> Value = val;
}

def OPC_LOAD      : RISCVOpcode<"LOAD",      0b0000011>;
def OPC_LOAD_FP   : RISCVOpcode<"LOAD_FP",   0b0000111>;
def OPC_MISC_MEM  : RISCVOpcode<"MISC_MEM",  0b0001111>;
def OPC_OP_IMM    : RISCVOpcode<"OP_IMM",    0b0010011>;
def OPC_AUIPC     : RISCVOpcode<"AUIPC",     0b0010111>;
def OPC_OP_IMM_32 : RISCVOpcode<"OP_IMM_32", 0b0011011>;
def OPC_STORE     : RISCVOpcode<"STORE",     0b0100011>;
def OPC_STORE_FP  : RISCVOpcode<"STORE_FP",  0b0100111>;
def OPC_AMO       : RISCVOpcode<"AMO",       0b0101111>;
def OPC_OP        : RISCVOpcode<"OP",        0b0110011>;
def OPC_LUI       : RISCVOpcode<"LUI",       0b0110111>;
def OPC_OP_32     : RISCVOpcode<"OP_32",     0b0111011>;
def OPC_MADD      : RISCVOpcode<"MADD",      0b1000011>;
def OPC_MSUB      : RISCVOpcode<"MSUB",      0b1000111>;
def OPC_NMSUB     : RISCVOpcode<"NMSUB",     0b1001011>;
def OPC_NMADD     : RISCVOpcode<"NMADD",     0b1001111>;
def OPC_OP_FP     : RISCVOpcode<"OP_FP",     0b1010011>;
def OPC_OP_V      : RISCVOpcode<"OP_V",      0b1010111>;
def OPC_BRANCH    : RISCVOpcode<"BRANCH",    0b1100011>;
def OPC_JALR      : RISCVOpcode<"JALR",      0b1100111>;
def OPC_JAL       : RISCVOpcode<"JAL",       0b1101111>;
def OPC_SYSTEM    : RISCVOpcode<"SYSTEM",    0b1110011>;


class Format<bits<3> val> {
  bits<3> Value = val;
}

def FormatPseudo : Format<0>;
def FormatR      : Format<1>;
def FormatI      : Format<2>;
def FormatS      : Format<3>;
def FormatU      : Format<4>;
def FormatB      : Format<5>;
def FormatJ      : Format<6>;

class TOYRVInst<dag outs, dag ins, string opcodestr, string argstr,
                list<dag> pattern, Format format>
    : Instruction {
  field bits<32> Inst;
  field bits<32> SoftFail = 0;
  let Size = 4;
  bits<7> Opcode = 0;
  let Namespace = "TOYRISCV";
  let Inst{6-0} = Opcode;
  dag OutOperandList = outs;
  dag InOperandList = ins;
  let AsmString = opcodestr # "\t" # argstr;
  let Pattern = pattern;
  let TSFlags{2-0} = format.Value;
  let DecoderNamespace = "TOYRISCV";
}

class TOYRVInstR<bits<7> funct7, bits<3> funct3, RISCVOpcode opcode, dag outs, dag ins, 
                 string opcodestr, string argstr> 
    : TOYRVInst<outs, ins, opcodestr, argstr, [], FormatR> {
  bits<5> rd;
  bits<5> rs1;
  bits<5> rs2;

  let Inst{31-25} = funct7;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Inst{6-0} = opcode.Value;
  let Opcode = opcode.Value;
}

class TOYRVInstI<bits<3> funct3, RISCVOpcode opcode, dag outs, dag ins, 
                 string opcodestr, string argstr>
    : TOYRVInst<outs, ins, opcodestr, argstr, [], FormatI> {
  bits<5> rd;
  bits<5> rs1;
  bits<12> imm12;

  let Inst{31-20} = imm12;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = rd;
  let Inst{6-0} = opcode.Value;
  let Opcode = opcode.Value;
}

class TOYRVInstS<bits<3> funct3, RISCVOpcode opcode, dag outs, dag ins, 
                 string opcodestr, string argstr>
    : TOYRVInst<outs, ins, opcodestr, argstr, [], FormatS> {
  bits<5> rs1;
  bits<5> rs2;
  bits<12> imm12;

  let Inst{31-25} = imm12{11-5};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-7} = imm12{4-0};
  let Inst{6-0} = opcode.Value;
  let Opcode = opcode.Value;
}

class TOYRVInstB<bits<3> funct3, RISCVOpcode opcode, dag outs, dag ins, 
                 string opcodestr,  string argstr>
    : TOYRVInst<outs, ins, opcodestr, argstr, [], FormatB> {
  bits<5> rs1;
  bits<5> rs2;
  bits<12> imm12;

  let Inst{31} = imm12{11};
  let Inst{30-25} = imm12{9-4};
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = funct3;
  let Inst{11-8} = imm12{3-0};
  let Inst{7} = imm12{10};
  let Inst{6-0} = opcode.Value;
  let Opcode = opcode.Value;
}

class TOYRVInstU<RISCVOpcode opcode, dag outs, dag ins, 
                 string opcodestr, string argstr> 
    : TOYRVInst<outs, ins, opcodestr, argstr, [], FormatU> {
  bits<5> rd;
  bits<20> imm20;

  let Inst{31-12} = imm20;
  let Inst{11-7} = rd;
  let Inst{6-0} = opcode.Value;
  let Opcode = opcode.Value;
}

class TOYRVInstJ<RISCVOpcode opcode, dag outs, dag ins, 
                 string opcodestr, string argstr> 
    : TOYRVInst<outs, ins, opcodestr, argstr, [], FormatJ> {
  bits<5> rd;
  bits<20> imm20;

  let Inst{31} = imm20{19};
  let Inst{30-21} = imm20{9-0};
  let Inst{20} = imm20{10};
  let Inst{19-12} = imm20{18-11};
  let Inst{11-7} = rd;
  let Inst{6-0} = opcode.Value;
  let Opcode = opcode.Value;
}

class Pseudo<dag outs, dag ins, string opcodestr = "", string argstr> 
    : TOYRVInst<outs, ins, opcodestr, argstr, [], FormatPseudo> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}
