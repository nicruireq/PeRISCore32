
# Copyright (c) 2021, Nicolás Ruiz Requejo
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
	
	