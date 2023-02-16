	.text
	.file	"andi.ll"
	.globl	andi                            # -- Begin function andi
	.p2align	1
	.type	andi,@function
andi:                                   # @andi
# %bb.0:
	andi	x10, x10, 6
		
$func_end0:
	.size	andi, ($func_end0)-andi
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
