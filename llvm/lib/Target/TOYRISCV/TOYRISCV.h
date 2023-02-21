#if !defined TOYRISCV_H_INCLUDED
#define TOYRISCV_H_INCLUDED

#include "MCTargetDesc/TOYRISCVMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"
#include "MCTargetDesc/TOYRISCVBaseInfo.h"

namespace llvm {

class TOYRISCVTargetMachine;
class MCInst; 
class MCOperand;
class MachineInstr; 
class MachineOperand; 
class AsmPrinter;

void LowerTOYRISCVMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI, AsmPrinter &AP);
bool LowerTOYRISCVMachineOperandToMCOperand(const MachineOperand &MO,
                                         MCOperand &MCOp, const AsmPrinter &AP);


} // namespace llvm

#endif // TOYRISCV_H_INCLUDED
