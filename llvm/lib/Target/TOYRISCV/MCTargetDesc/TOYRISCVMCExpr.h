#ifndef LLVM_LIB_TARGET_TOYRISCV_MCTARGETDESC_RISCVMCEXPR_H
#define LLVM_LIB_TARGET_TOYRISCV_MCTARGETDESC_RISCVMCEXPR_H

#include "llvm/MC/MCExpr.h"

namespace llvm {

class StringRef;

class TOYRISCVMCExpr : public MCTargetExpr {
public:
  enum VariantKind {
    VK_RISCV_None,
    VK_RISCV_LO,
    VK_RISCV_HI,
    VK_RISCV_PCREL_LO,
    VK_RISCV_PCREL_HI,
    VK_RISCV_GOT_HI,
    VK_RISCV_TPREL_LO,
    VK_RISCV_TPREL_HI,
    VK_RISCV_TPREL_ADD,
    VK_RISCV_TLS_GOT_HI,
    VK_RISCV_TLS_GD_HI,
    VK_RISCV_CALL,
    VK_RISCV_CALL_PLT,
    VK_RISCV_32_PCREL,
    VK_RISCV_Invalid // Must be the last item
  };

private:
  const MCExpr *Expr;
  const VariantKind Kind;

  int64_t evaluateAsInt64(int64_t Value) const;

  explicit TOYRISCVMCExpr(const MCExpr *Expr, VariantKind Kind)
      : Expr(Expr), Kind(Kind) {}

public:
  static const TOYRISCVMCExpr *create(const MCExpr *Expr, VariantKind Kind,
                                   MCContext &Ctx);

  VariantKind getKind() const { return Kind; }

  const MCExpr *getSubExpr() const { return Expr; }

  /// Get the corresponding PC-relative HI fixup that a VK_RISCV_PCREL_LO
  /// points to, and optionally the fragment containing it.
  ///
  /// \returns nullptr if this isn't a VK_RISCV_PCREL_LO pointing to a
  /// known PC-relative HI fixup.
  const MCFixup *getPCRelHiFixup(const MCFragment **DFOut) const;

  void printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const override;
  bool evaluateAsRelocatableImpl(MCValue &Res, const MCAsmLayout *Layout,
                                 const MCFixup *Fixup) const override;
  void visitUsedExpr(MCStreamer &Streamer) const override;
  MCFragment *findAssociatedFragment() const override {
    return getSubExpr()->findAssociatedFragment();
  }

  void fixELFSymbolsInTLSFixups(MCAssembler &Asm) const override;

  bool evaluateAsConstant(int64_t &Res) const;

  static bool classof(const MCExpr *E) {
    return E->getKind() == MCExpr::Target;
  }

  static bool classof(const TOYRISCVMCExpr *) { return true; }

  static VariantKind getVariantKindForName(StringRef name);
  static StringRef getVariantKindName(VariantKind Kind);
};

} // end namespace llvm.

#endif
