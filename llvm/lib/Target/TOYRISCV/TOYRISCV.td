include "llvm/Target/Target.td"

// Note: + and - represents to add/remove a feature
def RV64 : HwMode<"+64bit">;
def RV32 : HwMode<"-64bit">;

def TOYRISCVInstrInfo : InstrInfo {
  let guessInstructionProperties = 0;
}

def TOYRISCV : Target {
  let InstructionSet = TOYRISCVInstrInfo;
}

include "TOYRISCVRegisterInfo.td"
include "TOYRISCVSchedule.td"
include "TOYRISCVInstrInfo.td"
include "TOYRISCVCallingConv.td"


def FeatureRV64 : SubtargetFeature<"64bit", "HasRV64", "true", "RV64 support">;

def : ProcessorModel<"cpu-rv32", NoSchedModel, []>;
def : ProcessorModel<"cpu-rv64", NoSchedModel, [FeatureRV64]>;
