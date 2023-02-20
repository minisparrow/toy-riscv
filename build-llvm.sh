# cd /path/to/toy-riscv-backend
./setup.bash
cd ./llvm-project/
mkdir -p ./build && cd ./build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug \
               -DLLVM_TARGETS_TO_BUILD="TOYRISCV;RISCV" \
               -DLLVM_ENABLE_PROJECTS="clang" \
               -DCMAKE_C_COMPILER_LAUNCHER=ccache \
               -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
               -DLLVM_USE_LINKER=gold \
               ../llvm
ninja  


# after instruction selection done, add this
#             -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" \
