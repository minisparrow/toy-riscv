
#ifndef LLVM_LIB_TARGET_TOYRISCV_MCTARGETDESC_RISCVBASEINFO_H
#define LLVM_LIB_TARGET_TOYRISCV_MCTARGETDESC_RISCVBASEINFO_H

#include "MCTargetDesc/TOYRISCVMCTargetDesc.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/MC/MCInstrDesc.h"
#include "llvm/MC/SubtargetFeature.h"

namespace llvm {

// RISCVII - This namespace holds all of the target specific flags that
// instruction info tracks. All definitions must match RISCVInstrFormats.td.
namespace TOYRISCVII {
enum {
  InstFormatPseudo = 0,
  InstFormatR = 1,
  InstFormatI = 3,
  InstFormatS = 4,
  InstFormatB = 5,
  InstFormatU = 6,
  InstFormatJ = 7,
  InstFormatOther = 17,
};

// RISC-V Specific Machine Operand Flags
enum {
  MO_None = 0,
  MO_CALL = 1,
  MO_PLT = 2,
  MO_LO = 3,
  MO_HI = 4,
  MO_PCREL_LO = 5,
  MO_PCREL_HI = 6,
};

} // namespace TOYRISCVII
} // namespace llvm

#endif