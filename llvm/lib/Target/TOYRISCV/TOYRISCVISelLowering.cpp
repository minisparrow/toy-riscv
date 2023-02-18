#include "TOYRISCVISelLowering.h"
#include "TOYRISCVTargetMachine.h"
#include "TOYRISCV.h"
#include "TOYRISCVRegisterInfo.h"
#include "TOYRISCVSubtarget.h"
#include "TOYRISCVTargetMachine.h"
#include "llvm/ADT/SmallSet.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/MemoryLocation.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineJumpTableInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/IntrinsicsRISCV.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/KnownBits.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;
#include "llvm/CodeGen/CallingConvLower.h"
#include "TOYRISCVGenCallingConv.inc"

TOYRISCVTargetLowering::TOYRISCVTargetLowering(TOYRISCVTargetMachine const &TM,
                                               TOYRISCVSubtarget const &STI)
    : TargetLowering(TM), Subtarget(STI), ABI(TM.getABI()) {

  MVT XLenVT = Subtarget.getXLenVT();

  // Set up the register classes.
  addRegisterClass(XLenVT, &TOYRISCV::GPRRegClass);

  // Compute derived properties from the register classes.
  computeRegisterProperties(STI.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(TOYRISCV::SP);

  // TODO: add all necessary setOperationAction calls.
  for (auto N : {ISD::EXTLOAD, ISD::SEXTLOAD, ISD::ZEXTLOAD}) {
     setLoadExtAction(N, XLenVT, MVT::i1, Promote);
  }

  setBooleanContents(ZeroOrOneBooleanContent);

  // Function alignments (log2).
  const Align FunctionAlignment(2);
  setMinFunctionAlignment(FunctionAlignment);
  setPrefFunctionAlignment(FunctionAlignment);
}


SDValue TOYRISCVTargetLowering::LowerOperation(SDValue Op,
                                            SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    report_fatal_error("unimplemented operand");
  case ISD::BRCOND: 
    return lowerBRCOND(Op, DAG);
  }
}
// Changes the condition code and swaps operands if necessary, so the SetCC
// operation matches one of the comparisons supported directly by branches
// in the RISC-V ISA. May adjust compares to favor compare with 0 over compare
// with 1/-1.
static void translateSetCCForBranch(const SDLoc &DL, SDValue &LHS, SDValue &RHS,
                                    ISD::CondCode &CC, SelectionDAG &DAG) {
  // Convert X > -1 to X >= 0.
  if (CC == ISD::SETGT && isAllOnesConstant(RHS)) {
    RHS = DAG.getConstant(0, DL, RHS.getValueType());
    CC = ISD::SETGE;
    return;
  }
  // Convert X < 1 to 0 >= X.
  if (CC == ISD::SETLT && isOneConstant(RHS)) {
    RHS = LHS;
    LHS = DAG.getConstant(0, DL, RHS.getValueType());
    CC = ISD::SETGE;
    return;
  }

  switch (CC) {
  default:
    break;
  case ISD::SETGT:
  case ISD::SETLE:
  case ISD::SETUGT:
  case ISD::SETULE:
    CC = ISD::getSetCCSwappedOperands(CC);
    std::swap(LHS, RHS);
    break;
  }
}

SDValue TOYRISCVTargetLowering::lowerBRCOND(SDValue Op, SelectionDAG &DAG) const {
  SDValue CondV = Op.getOperand(1);
  SDLoc DL(Op);
  MVT XLenVT = Subtarget.getXLenVT();

  if (CondV.getOpcode() == ISD::SETCC &&
      CondV.getOperand(0).getValueType() == XLenVT) {
    SDValue LHS = CondV.getOperand(0);
    SDValue RHS = CondV.getOperand(1);
    ISD::CondCode CCVal = cast<CondCodeSDNode>(CondV.getOperand(2))->get();

    translateSetCCForBranch(DL, LHS, RHS, CCVal, DAG);

    SDValue TargetCC = DAG.getCondCode(CCVal);
    return DAG.getNode(TOYRISCVISD::BR_CC, DL, Op.getValueType(), Op.getOperand(0),
                       LHS, RHS, TargetCC, Op.getOperand(2));
  }

  return DAG.getNode(TOYRISCVISD::BR_CC, DL, Op.getValueType(), Op.getOperand(0),
                     CondV, DAG.getConstant(0, DL, XLenVT),
                     DAG.getCondCode(ISD::SETNE), Op.getOperand(2));
}

  
// Calling Convention Implementation.
// #include "TOYRISCVGenCallingConv.inc"

// Transform physical registers into virtual registers.
SDValue TOYRISCVTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {

  switch (CallConv) {
  default:
    report_fatal_error("Unsupported calling convention");
  case CallingConv::C:
    break;
  }

  MachineFunction &MF = DAG.getMachineFunction();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();
  MVT XLenVT = Subtarget.getXLenVT();

  if (IsVarArg)
    report_fatal_error("VarArg not supported");

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;

  CCState CCInfo(CallConv, IsVarArg, MF, ArgLocs, *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_RISCV32);

  for (auto &VA : ArgLocs) {
    if (!VA.isRegLoc())
      report_fatal_error("Defined with too many args");

    // Arguments passed in registers.
    EVT RegVT = VA.getLocVT();
    if (RegVT != XLenVT) {
      LLVM_DEBUG(dbgs() << "LowerFormalArguments Unhandled argument type: "
          << RegVT.getEVTString() << "\n");
      report_fatal_error("unhandled argument type");
    }
    const unsigned VReg =
      RegInfo.createVirtualRegister(&TOYRISCV::GPRRegClass);
    RegInfo.addLiveIn(VA.getLocReg(), VReg);
    SDValue ArgIn = DAG.getCopyFromReg(Chain, DL, VReg, RegVT);

    InVals.push_back(ArgIn);
  }
  return Chain;
}

SDValue
TOYRISCVTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                                 bool IsVarArg,
                                 const SmallVectorImpl<ISD::OutputArg> &Outs,
                                 const SmallVectorImpl<SDValue> &OutVals,
                                 const SDLoc &DL, SelectionDAG &DAG) const {
  if (IsVarArg) {
    report_fatal_error("VarArg not supported");
  }

  // Stores the assignment of the return value to a location.
  SmallVector<CCValAssign, 16> RVLocs;

  // Info about the registers and stack slot.
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeReturn(Outs, RetCC_RISCV32);

  SDValue Flag;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  // Copy the result values into the output registers.
  for (unsigned i = 0, e = RVLocs.size(); i < e; ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");

    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), OutVals[i], Flag);

    // Guarantee that all emitted copies are stuck together.
    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain; // Update chain.

  // Add the flag if we have it.
  if (Flag.getNode()) {
    RetOps.push_back(Flag);
  }

  return DAG.getNode(TOYRISCVISD::RET_FLAG, DL, MVT::Other, RetOps);
}

// const char *TOYRISCVTargetLowering::getTargetNodeName(unsigned Opcode) const {
//   switch ((RISCVISD::NodeType)Opcode) {
//   case RISCVISD::FIRST_NUMBER:
//     break;
//   case RISCVISD::RET_FLAG:
//     return "RISCVISD::RET_FLAG";
//   }
//   return nullptr;
// }
