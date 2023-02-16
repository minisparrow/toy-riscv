	.text
	.file	"addi.ll"
	.globl	addi                            # -- Begin function addi
	.p2align	1
	.type	addi,@function
addi:                                   # @addi
# %bb.0:
	addi	x10, x10, 1
	jalr	x0, 0(x1)
$func_end0:
	.size	addi, ($func_end0)-addi
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
