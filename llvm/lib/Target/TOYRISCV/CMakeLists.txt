add_llvm_component_group(TOYRISCV)
set(LLVM_TARGET_DEFINITIONS TOYRISCV.td)

tablegen(LLVM TOYRISCVGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM TOYRISCVGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM TOYRISCVGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM TOYRISCVGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM TOYRISCVGenCallingConv.inc -gen-callingconv)
tablegen(LLVM TOYRISCVGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM TOYRISCVGenInstrInfo.inc -gen-instr-info)

add_public_tablegen_target(TOYRISCVCommonTableGen)

add_llvm_target(TOYRISCVCodeGen
    TOYRISCVTargetMachine.cpp
    TOYRISCVFrameLowering.cpp
    TOYRISCVISelLowering.cpp
    TOYRISCVRegisterInfo.cpp
    TOYRISCVSubtarget.cpp
    TOYRISCVInstrInfo.cpp
    TOYRISCVTargetObjectFile.cpp
    TOYRISCVMCInstLower.cpp
    TOYRISCVAsmPrinter.cpp
    TOYRISCVISelDagToDag.cpp

    LINK_COMPONENTS
    Core 
    CodeGen
    MC 
    TOYRISCVDesc
    TOYRISCVInfo 
    SelectionDAG
    Support 
    Target 

    ADD_TO_COMPONENT
    TOYRISCV
)

add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
