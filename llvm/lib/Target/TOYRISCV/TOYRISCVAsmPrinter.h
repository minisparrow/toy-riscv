#if !defined TOYRISCVASMPRINTER_H_INCLUDED
#define TOYRISCVASMPRINTER_H_INCLUDED

#include "TOYRISCVSubtarget.h"
#include "TOYRISCVTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {

class TOYRISCVAsmPrinter : public AsmPrinter {
public:
  TOYRISCVAsmPrinter(TargetMachine &TM, std::unique_ptr<MCStreamer> Streamer);

  virtual StringRef getPassName() const override;
  void emitInstruction(const MachineInstr *MI) override;
  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);
  // Wrapper needed for tblgenned pseudo lowering.
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp) const {
    return LowerTOYRISCVMachineOperandToMCOperand(MO, MCOp, *this);
  }
};

} // namespace llvm

#endif // TOYRISCVASMPRINTER_H_INCLUDED

// vim: set ts=2 sw=2 sts=2:
