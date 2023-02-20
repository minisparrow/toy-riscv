#if !defined TOYRISCV_H_INCLUDED
#define TOYRISCV_H_INCLUDED

#include "MCTargetDesc/TOYRISCVMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"
#include "MCTargetDesc/TOYRISCVBaseInfo.h"

namespace llvm {

class TOYRISCVTargetMachine;
class MCInst; 
class MachineInstr; 

void LowerTOYRISCVMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI);

} // namespace llvm

#endif // TOYRISCV_H_INCLUDED
