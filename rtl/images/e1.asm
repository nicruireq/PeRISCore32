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
	# arith
	ori $t0, $zero, 0
	ori $t1, $zero, 4
	ori $t2, $zero, 8
	ori $t3, $zero, 12
	lw $s0, ($t0)
	lw $s1, ($t1)
	lw $s2, ($t2)
	lw $s3, ($t3)
	add $s4, $s0, $s1
	nop
	addu $s5, $s2, $s3
	nop
	nop
	sub $s6, $s4, $s5
	nop
	nop
	sw $s6, 32($zero) # in data[32] = 0xfff863da
	subu $s7, $s0, $s1
	nop
	nop
	sw $s7, 36($zero) # data[36] = 0x000001d6
	nop
	addi $s6, $s1, 123
	addiu $s7, $s1, 123
	nop
	nop
	sw $s6, 40($zero) # data[40] = 0xfffffeb1
	sw $s7, 44($zero) # data[44] = 0xfffffeb1
	# logical
	and $s4, $s0, $s0
	or $s5, $s1, $s0
	xor $s6, $s2, $s2
	nor $s7, $s3, $s3
	sw $s4, 48($zero) # data[48] = 0x0000000c
	sw $s5, 52($zero) # data[52] = 0xfffffe3e
	sw $s6, 56($zero) # data[56] = 0x00000000
	sw $s7, 60($zero) # data[60] = 0x00001ea4
	andi $s4, $s0, 100
	ori $s5, $s1, 100
	xori $s6, $s2, 100
	sw $s4, 64($zero) # data[64] = 0x00000004
	sw $s5, 68($zero) # data[68] = 0xfffffe76
	sw $s6, 72($zero) # data[72] = 0x0007b969
	# compare
	slt $s4, $s0, $s1
	sltu $s5, $s0, $s1
	slti $s6, $s0, -124
	sltiu $s7, $s0, -124
	sw $s4, 76($zero) # data[76] = 0x00000000
	sw $s5, 80($zero) # data[80] = 0x00000001
	sw $s6, 84($zero) # data[84] = 0x00000000
	sw $s7, 88($zero) # data[88] = 0x00000001
	# shifts
	nop
	j here
	nop
	nop
here:
	sll $s4, $s1, 10
	srl $s5, $s1, 10
	sra $s6, $s1, 10
	sw $s4, 92($zero) # data[92] = 0xfff8d800
	sw $s5, 96($zero) # data[96] = 0x003fffff
	sw $s6, 100($zero) # data[100] = 0xffffffff
	ori $t5, $zero, 5
	nop
	nop
	sllv $s4, $s1, $t5
	srlv $s5, $s1, $t5
	srav $s6, $s1, $t5
	sw $s4, 104($zero) # data[104] = 0xffffc6c0
	sw $s5, 108($zero) # data[108] = 0x07fffff1
	sw $s6, 112($zero) # data[112] = 0xfffffff1
	# branches and lui
	lui $t6, 0x0379
	nop
	nop
	ori $t6, $t6, 0xc78d
	nop
	nop
	sltiu $t7, $t6, 100
	beq $t7, $zero, here
	addi $zero, $zero, 100 # to see $zero can't change
