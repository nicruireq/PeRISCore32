.data
A: .word 12, -458, 506125, -7845

.text
	addiu $t3, $zero, 0	# offset
	addiu $t6, $zero, 0	# i
	ori $t5, $zero, 1	# test condition
loop:
	nop
	nop
	lw $s1, A($t3)
	nop
	nop
	add $s2, $s2, $s1
	nop
	nop
	addiu $t6, $t6, 1
	nop
	nop
	sltiu $t4, $t6, 4
	nop
	nop
	beq $t5, $t4, loop
	addiu $t3, $t3, 4	# increment i in delay slot
	sw $s2, 0x10($zero)
	# if $s2 > 
	lui $t6, 0x0007
	nop
	nop
	ori $t6, $t6, 0x98aa
	nop
	nop
	slt $t5, $t6, $s2
	nop
	nop
	beq $t5, $zero, next
	lui $s3, 458
	lui $s4, 231
	lui $s5, 784
next:
	addi $s3, $s2, -4589
	nop
	nop
	sw $s3, 0x14
	
	