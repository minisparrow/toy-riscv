include "TOYRISCVInstrFormats.td"

def simm12 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<12>(Imm);}]> {
  let DecoderMethod = "decodeImmOperand<12>";
}
def simm20u : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<32>(Imm) && !(Imm & 0x0fff);}]> {
  let DecoderMethod = "decodeImmOperand<20>";
}
def simm32: Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<32>(Imm);}]>;

def SDT_CallSeqStart : SDCallSeqStart<[SDTCisVT<0, XLenVT>, SDTCisVT<1, XLenVT>]>;
def SDT_CallSeqEnd   : SDCallSeqEnd  <[SDTCisVT<0, XLenVT>, SDTCisVT<1, XLenVT>]>;
def CallSeqStart : SDNode<"ISD::CALLSEQ_START", SDT_CallSeqStart, [SDNPHasChain, SDNPOutGlue]>;
def CallSeqEnd   : SDNode<"ISD::CALLSEQ_END",   SDT_CallSeqEnd,   [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

// Target-independent nodes, but with target-specific formats.
def callseq_start : SDNode<"ISD::CALLSEQ_START", SDT_CallSeqStart,
                           [SDNPHasChain, SDNPOutGlue]>;
def callseq_end   : SDNode<"ISD::CALLSEQ_END", SDT_CallSeqEnd,
                           [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;

def toyriscv_ret_flag  : SDNode<"TOYRISCVISD::RET_FLAG", SDTNone,
                             [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

let Defs = [SP], Uses = [SP], hasSideEffects = 1 in {
  def ADJCALLSTACKDOWN : Pseudo<(outs), (ins simm12:$amt1, simm12:$amt2), [(callseq_start timm:$amt1, timm:$amt2)]>;
  def ADJCALLSTACKUP   : Pseudo<(outs), (ins simm12:$amt1, simm12:$amt2), [(callseq_end timm:$amt1, timm:$amt2)]>;
}

//===----------- R-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_rr<bits<7> funct7, bits<3> funct3, string opcodestr>
    : TOYRVInstR<funct7, funct3, OPC_OP, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                 opcodestr, "\t$rd, $rs1, $rs2">; 
def ADD  : ALU_rr<0b0000000, 0b000, "add">;
def SUB  : ALU_rr<0b0100000, 0b000, "sub">;
def SLL  : ALU_rr<0b0000000, 0b001, "sll">;
def SLT  : ALU_rr<0b0000000, 0b010, "slt">;
def SLTU : ALU_rr<0b0000000, 0b011, "sltu">;
def XOR  : ALU_rr<0b0000000, 0b100, "xor">;
def SRL  : ALU_rr<0b0000000, 0b101, "srl">;
def SRA  : ALU_rr<0b0100000, 0b101, "sra">;
def OR   : ALU_rr<0b0000000, 0b110, "or">;
def AND  : ALU_rr<0b0000000, 0b111, "and">;

//===----------- I-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class ALU_ri<bits<3> funct3, string opcodestr>
    : TOYRVInstI<funct3, OPC_OP_IMM, (outs GPR:$rd), (ins GPR:$rs1, simm12:$imm12), 
                opcodestr, "$rd, $rs1, $imm12">; 

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
class Load_ri<bits<3> funct3, string opcodestr>
    : TOYRVInstI<funct3, OPC_LOAD, (outs GPR:$rd), (ins GPR:$rs1, simm12:$imm12),
              opcodestr, "$rd, ${imm12}(${rs1})">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
let isCall = 1 in
def JALR : TOYRVInstI<0b000, OPC_JALR, (outs GPR:$rd),
                   (ins GPR:$rs1, simm12:$imm12),
                   "jalr", "$rd, ${imm12}(${rs1})">;
}

let isReMaterializable = 1, isAsCheapAsAMove = 1 in
def ADDI  : ALU_ri<0b000, "addi">;

def SLTI  : ALU_ri<0b010, "slti">;
def SLTIU : ALU_ri<0b011, "sltiu">;

let isReMaterializable = 1, isAsCheapAsAMove = 1 in {
def XORI  : ALU_ri<0b100, "xori">;
def ORI   : ALU_ri<0b110, "ori">;
}
def ANDI  : ALU_ri<0b111, "andi">;

def LB  : Load_ri<0b000, "lb">;
def LH  : Load_ri<0b001, "lh">;
def LW  : Load_ri<0b010, "lw">;
def LBU : Load_ri<0b100, "lbu">;
def LHU : Load_ri<0b101, "lhu">;

//===----------- S-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
class Store_rri<bits<3> funct3, string opcodestr>
    : TOYRVInstS<funct3, OPC_STORE, (outs),
              (ins GPR:$rs2, GPR:$rs1, simm12:$imm12),
              opcodestr, "$rs2, ${imm12}(${rs1})">;

def SB : Store_rri<0b000, "sb">; 
def SH : Store_rri<0b001, "sh">; 
def SW : Store_rri<0b010, "sw">; 

//===----------- B-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class BranchCC_rri<bits<3> funct3, string opcodestr>
    : TOYRVInstB<funct3, OPC_BRANCH, (outs),
              (ins GPR:$rs1, GPR:$rs2, simm12:$imm12),
              opcodestr, "$rs1, $rs2, $imm12"> {
  let isBranch = 1;
  let isTerminator = 1;
}
def BEQ  : BranchCC_rri<0b000, "beq">;
def BNE  : BranchCC_rri<0b001, "bne">;
def BLT  : BranchCC_rri<0b100, "blt">;
def BGE  : BranchCC_rri<0b101, "bge">;
def BLTU : BranchCC_rri<0b110, "bltu">;
def BGEU : BranchCC_rri<0b111, "bgeu">;

//===----------- U-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
let isReMaterializable = 1, isAsCheapAsAMove = 1 in
def LUI : TOYRVInstU<OPC_LUI, (outs GPR:$rd), (ins simm20u:$imm20),
                  "lui", "$rd, $imm20">;

def AUIPC : TOYRVInstU<OPC_AUIPC, (outs GPR:$rd), (ins simm20u:$imm20),
                    "auipc", "$rd, $imm20">;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 0

//===----------- J-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
let isCall = 1 in
def JAL : TOYRVInstJ<OPC_JAL, (outs GPR:$rd), (ins simm20u:$imm20),
                  "jal", "$rd, $imm20">;
}
//===---------------------------------------------------====
//              RISCV specific DAG nodes 
//===---------------------------------------------------====
def RetFlag : SDNode<"TOYRVISD::RET_FLAG", SDTNone,
                    [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;


//===---------------------------------------------------====
//              RISCV Pattern 
//===---------------------------------------------------====
// let isBarrier = 1, isBranch = 1, isTerminator = 1 in {
// def PseudoBR : Pseudo<(outs), (ins simm20u:$imm20), [(br bb:$imm20)]>, PseudoInstExpansion<(JAL ZERO, simm20u:$imm20)>;
// }

let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : Pseudo<(outs), (ins), [(toyriscv_ret_flag)]>,
                PseudoInstExpansion<(JALR ZERO, RA, 0)>;

class PatGprGpr<SDPatternOperator OpNode, TOYRVInstR Inst>
    : Pat<(OpNode GPR:$rs1, GPR:$rs2), (Inst GPR:$rs1, GPR:$rs2)>;
class PatGprSimm12<SDPatternOperator OpNode, TOYRVInstI Inst>
    : Pat<(OpNode GPR:$rs1, simm12:$imm12), (Inst GPR:$rs1, simm12:$imm12)>;

// arithmetic operations
def : PatGprGpr<add, ADD>;
def : PatGprSimm12<add, ADDI>;
def : PatGprGpr<sub, SUB>;

// logic and shift  
def : PatGprGpr<and, AND>;
def : PatGprSimm12<and, ANDI>;
def : PatGprGpr<or, OR>;
def : PatGprSimm12<or, ORI>;
def : PatGprGpr<xor, XOR>;
def : PatGprSimm12<xor, XORI>;
def : PatGprGpr<sll, SLL>;
def : PatGprGpr<srl, SRL>;

/// Setcc
def : PatGprGpr<setlt, SLT>;
def : PatGprSimm12<setlt, SLTI>;
def : PatGprGpr<setult, SLTU>;
def : PatGprSimm12<setult, SLTIU>;