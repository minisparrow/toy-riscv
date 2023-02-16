#if !defined TOYRISCVISELLOWERING_H_INCLUDED
#define TOYRISCVISELLOWERING_H_INCLUDED

#include "MCTargetDesc/TOYRISCVABIInfo.h"
#include "TOYRISCV.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/CodeGen/CallingConvLower.h"

namespace llvm {
class TOYRISCVSubtarget;
namespace TOYRISCVISD {
enum NodeType : unsigned {
  FIRST_NUMBER = ISD::BUILTIN_OP_END,
  RET_FLAG,
  URET_FLAG,
  SRET_FLAG,
  MRET_FLAG,
  BR_CC,
  CALL,
};
} // namespace TOYRISCVISD

class TOYRISCVTargetLowering : public TargetLowering {
  TOYRISCVSubtarget const &Subtarget;
  TOYRISCVABIInfo const &ABI;

public:
  
  TOYRISCVTargetLowering(TOYRISCVTargetMachine const &TM,
                         TOYRISCVSubtarget const &STI);
  
  // custom lowering for some operations
  SDValue LowerOperation(SDValue Op, SelectionDAG &DAG) const override; 

  // const char *getTargetNodeName(unsigned Opcode) const override;

  //lower incoming arguments, copy physregs into vregs
  SDValue LowerFormalArguments(SDValue Chain, 
                               CallingConv::ID CallConv,
                               bool IsVarArg,
                               SmallVectorImpl<ISD::InputArg> const &Ins,
                               SDLoc const &DL, SelectionDAG &DAG,
                               SmallVectorImpl<SDValue> &InVals) const override;

  SDValue LowerReturn(SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
                      SmallVectorImpl<ISD::OutputArg> const &Outs,
                      SmallVectorImpl<SDValue> const &OutVals, SDLoc const &DL,
                      SelectionDAG &DAG) const override;
  SDValue lowerBRCOND(SDValue Op, SelectionDAG &DAG) const;
};

} // namespace llvm

#endif // TOYRISCVISELLOWERING_H_INCLUDED

// vim: set ts=2 sw=2 sts=2:
