.data
	
opA: .word 5000, -9872564, -1230000 #, 2147483647
opB: .word 589654, 1000000000, -2000000000 #, 1

.text

.macro storen	# to store next result in memory
sw $s0, ($s7)
add $s7, $s7, 4
.end_macro

la $s7, 32		# base address to load in mem
li $s6, 3 		# array size
and $s5, $s5, $zero	# index var

# Apply all operations to each pair of operands 
# in arrays opA and opB and save in memory
for:
lw $t1, opA($s5)
lw $t2, opB($s5)
add $s0, $t1, $t2	# t1 + t2
storen
addu $s0, $t1, $t2	# t1 + t2 not ovf
storen
sub $s0, $t1, $t2	# t1 - t2
storen
sub $s0, $t2, $t1	# t2 - t1
storen
subu $s0, $t1, $t2	# t1 - t2 not ovf
storen
subu $s0, $t2, $t1	# t2 - t1 not ovf
storen
slt $s0, $t1, $t2	# t1 < t2
storen
slt $s0, $t2, $t1	# t2 < t1
storen
sltu $s0, $t1, $t2	# t1 < t2
storen
sltu $s0, $t2, $t1	# t2 < t1
storen
sll $s0, $t1, 10	
storen
srl $s0, $t1, 20
storen
sra $s0, $t1, 5
storen


subi $s6, $s6, 1	# decrement numer of elements processed
addi $s5, $s5, 4	# increment pointer to arrays opA and opB to next word
bne $s6, $zero, for