include "TOYRISCVInstrFormats.td"

class ImmAsmOperand<string prefix, int width, string suffix> : AsmOperandClass {
  let Name = prefix # "Imm" # width # suffix;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

class SImmAsmOperand<int width, string suffix = "">
    : ImmAsmOperand<"S", width, suffix> {
}

def Simm21Lsb0JALAsmOperand : SImmAsmOperand<21, "Lsb0JAL"> {
  // let ParserMethod = "parseJALOffset";
}

// A 21-bit signed immediate where the least significant bit is zero.
def simm21_lsb0_jal : Operand<OtherVT> {
  // let ParserMatchClass = Simm21Lsb0JALAsmOperand;
  // let PrintMethod = "printBranchOperand";
  let EncoderMethod = "getImmOpValueAsr1";
  let DecoderMethod = "decodeSImmOperandAndLsl1<21>";
  // let MCOperandPredicate = [{
  //   int64_t Imm;
  //   if (MCOp.evaluateAsConstantImm(Imm))
  //     return isShiftedInt<20, 1>(Imm);
  //   return MCOp.isBareSymbolRef();
  // }];
  let OperandType = "OPERAND_PCREL";
}


def simm12 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<12>(Imm);}]> {
  let DecoderMethod = "decodeImmOperand<12>";
}
def simm20u : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<32>(Imm) && !(Imm & 0x0fff);}]> {
  let DecoderMethod = "decodeImmOperand<20>";
}
def simm32: Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<32>(Imm);}]>;

def simm13_lsb0 : Operand<OtherVT> {
   let ParserMatchClass = SImmAsmOperand<13, "Lsb0">;
   let EncoderMethod = "getImmOpValueAsr1";
   let DecoderMethod = "decodeSImmOperandAndLsl1<13>";
 }

// Extract least significant 12 bits from an immediate value and sign extend
// them.
def LO12Sext : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(SignExtend64<12>(N->getZExtValue()),
                                   SDLoc(N), N->getValueType(0));
}]>;

// Extract the most significant 20 bits from an immediate value. Add 1 if bit
// 11 is 1, to compensate for the low 12 bits in the matching immediate addi
// or ld/st being negative.
def HI20 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(((N->getZExtValue()+0x800) >> 12) & 0xfffff,
                                   SDLoc(N), N->getValueType(0));
}]>;



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

def SDT_RISCVBrCC : SDTypeProfile<0, 4, []>;
def toyriscv_brcc : SDNode<"TOYRISCVISD::BR_CC", SDT_RISCVBrCC,
                               [SDNPHasChain]>;

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


/// Loads Pattern
multiclass LdPat<PatFrag LoadOp, TOYRVInst Inst> {
  def : Pat<(LoadOp GPR:$rs1), (Inst GPR:$rs1, 0)>;
  def : Pat<(LoadOp (add GPR:$rs1, simm12:$imm12)),
            (Inst GPR:$rs1, simm12:$imm12)>;
}

defm : LdPat<sextloadi8, LB>;
defm : LdPat<extloadi8, LB>;
defm : LdPat<sextloadi16, LH>;
defm : LdPat<extloadi16, LH>;
defm : LdPat<load, LW>;
defm : LdPat<zextloadi8, LBU>;
defm : LdPat<zextloadi16, LHU>;

//===----------- S-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
class Store_rri<bits<3> funct3, string opcodestr>
    : TOYRVInstS<funct3, OPC_STORE, (outs),
              (ins GPR:$rs2, GPR:$rs1, simm12:$imm12),
              opcodestr, "$rs2, ${imm12}(${rs1})">;

def SB : Store_rri<0b000, "sb">; 
def SH : Store_rri<0b001, "sh">; 
def SW : Store_rri<0b010, "sw">; 

/// Store Pattern
multiclass StPat<PatFrag StoreOp, TOYRVInst Inst> {
  def : Pat<(StoreOp GPR:$rs2, GPR:$rs1), (Inst GPR:$rs2, GPR:$rs1, 0)>;
  def : Pat<(StoreOp GPR:$rs2, (add GPR:$rs1, simm12:$imm12)),
            (Inst GPR:$rs2, GPR:$rs1, simm12:$imm12)>;
}

defm : StPat<truncstorei8, SB>;
defm : StPat<truncstorei16, SH>;
defm : StPat<store, SW>;


//===----------- B-TYPE-------------====
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
class BranchCC_rri<bits<3> funct3, string opcodestr>
    : TOYRVInstB<funct3, OPC_BRANCH, (outs),
              (ins GPR:$rs1, GPR:$rs2, simm13_lsb0:$imm12),
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

multiclass PatBrcc<CondCode CondOp, TOYRVInstB Inst> {
   def _rri: Pat<(toyriscv_brcc GPR:$rs1, GPR:$rs2, CondOp, bb:$imm12), (Inst GPR:$rs1, GPR:$rs2, simm13_lsb0 :$imm12)>;
}

defm : PatBrcc<SETEQ, BEQ>;
defm : PatBrcc<SETNE, BNE>;
defm : PatBrcc<SETLT, BLT>;
defm : PatBrcc<SETGE, BGE>;
defm : PatBrcc<SETULT, BLTU>;
defm : PatBrcc<SETUGE, BGEU>;

class PatBrcond<PatFrag CondOp, TOYRVInstB Inst>
    : Pat<(brcond (i32 (CondOp GPR:$rs1, GPR:$rs2)), bb:$imm12),
          (Inst GPR:$rs1, GPR:$rs2, simm13_lsb0:$imm12)>;

def : PatBrcond<seteq, BEQ>;
def : PatBrcond<setne, BNE>;
def : PatBrcond<setlt, BLT>;
def : PatBrcond<setge, BGE>;
def : PatBrcond<setult, BLTU>;
def : PatBrcond<setuge, BGEU>;

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
def JAL : TOYRVInstJ<OPC_JAL, (outs GPR:$rd), (ins simm21_lsb0_jal:$imm20),
                  "jal", "$rd, $imm20">;
}
//===---------------------------------------------------====
//              RISCV specific DAG nodes 
//===---------------------------------------------------====
def SDT_RISCVSelectCC     : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>,
                                                 SDTCisSameAs<0, 4>,
                                                 SDTCisSameAs<4, 5>]>;

def RetFlag : SDNode<"TOYRISCVISD::RET_FLAG", SDTNone,
                    [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

// def SelectCC     : SDNode<"TOYRISCVISD::SELECT_CC", SDT_RISCVSelectCC>;
// let usesCustomInserter = 1 in
// def Select_GPR_Using_CC_GPR
//     : Pseudo<(outs GPR:$dst),
//              (ins GPR:$lhs, GPR:$rhs, ixlenimm:$imm, GPR:$src, GPR:$src2),
//              [(set XLenVT:$dst, (SelectCC GPR:$lhs, GPR:$rhs,
//               (XLenVT imm:$imm), GPR:$src, GPR:$src2))]>;

// A parameterized register class alternative to i32imm/i64imm from Target.td.
def ixlenimm : Operand<XLenVT>;
def riscv_selectcc  : SDNode<"TOYRISCVISD::SELECT_CC", SDT_RISCVSelectCC>;
def IntCCtoRISCVCC : SDNodeXForm<riscv_selectcc, [{
  ISD::CondCode CC = cast<CondCodeSDNode>(N->getOperand(2))->get();
  TOYRISCVCC::CondCode BrCC = getRISCVCCForIntCC(CC);
  return CurDAG->getTargetConstant(BrCC, SDLoc(N), Subtarget->getXLenVT());
}]>;

def riscv_selectcc_frag : PatFrag<(ops node:$lhs, node:$rhs, node:$cc,
                                       node:$truev, node:$falsev),
                                  (riscv_selectcc node:$lhs, node:$rhs,
                                                  node:$cc, node:$truev,
                                                  node:$falsev), [{}],
                                  IntCCtoRISCVCC>;

let usesCustomInserter = 1 in
class SelectCC_rrirr<RegisterClass valty, RegisterClass cmpty>
    : Pseudo<(outs valty:$dst),
             (ins cmpty:$lhs, cmpty:$rhs, ixlenimm:$imm,
              valty:$truev, valty:$falsev),
             [(set valty:$dst,
               (riscv_selectcc_frag:$imm cmpty:$lhs, cmpty:$rhs, cond,
                                         valty:$truev, valty:$falsev))]>;

def Select_GPR_Using_CC_GPR : SelectCC_rrirr<GPR, GPR>;

//===---------------------------------------------------====
//              RISCV Pattern 
//===---------------------------------------------------====
let isBarrier = 1, isBranch = 1, isTerminator = 1 in {
def PseudoBR : Pseudo<(outs), (ins simm21_lsb0_jal:$imm20), [(br bb:$imm20)]>, 
               PseudoInstExpansion<(JAL ZERO, simm21_lsb0_jal:$imm20)>;
}

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
def : PatGprGpr<shl, SLL>;
def : PatGprGpr<srl, SRL>;

/// Setcc
def : PatGprGpr<setlt, SLT>;
def : PatGprSimm12<setlt, SLTI>;
def : PatGprGpr<setult, SLTU>;
def : PatGprSimm12<setult, SLTIU>;


/// Immediates
def : Pat<(simm12:$imm), (ADDI ZERO, simm12:$imm)>;
// TODO: Add a pattern for immediates with all zeroes in the lower 12 bits.
def : Pat<(simm32:$imm), (ADDI (LUI (HI20 imm:$imm)), (LO12Sext imm:$imm))>;


//===---------------------------------------------------====
//             Pseudo  
//===---------------------------------------------------====
def BareSymbol : AsmOperandClass {
  let Name = "BareSymbol";
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "InvalidBareSymbol";
  let ParserMethod = "parseBareSymbol";
}

// A bare symbol.
def bare_symbol : Operand<XLenVT> {
  let ParserMatchClass = BareSymbol;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, Size = 8, isCodeGenOnly = 0,
    isAsmParserOnly = 1 in
def PseudoLLA : Pseudo<(outs GPR:$dst), (ins bare_symbol:$src), [],
                       "lla", "$dst, $src">;

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, Size = 8, isCodeGenOnly = 0,
    isAsmParserOnly = 1 in
def PseudoLA : Pseudo<(outs GPR:$dst), (ins bare_symbol:$src), [],
                      "la", "$dst, $src">;
