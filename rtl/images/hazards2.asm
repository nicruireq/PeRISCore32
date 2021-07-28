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

li $t0, 12 
li $t1, 412
li $t2, 54
add $s1, $t0, $t1
sub $s7, $t1, $s1
ori $s2, $s1, 100
sllv $s3, $t2, $s7
sll $s4, $s2, 2
sw $s4, 0
sw $s3, 4
sw $s2, 8
sw $s7, 12
sw $s1, 16
lw $t5, 0
sw $t5, 20
lw $t6, 12
add $s2, $t6, $s4
addi $s3, $t6, 400
lw $t7, 4
ori $s5, $t7, 392
sw $s2, 24
sw $s3, 28
sw $s5, 32
# no hazarded branch
beq $t1, $zero, normal
ori $t1, $t1, 789
addi $t1, $t1, 120
normal:
li $t3, 2
li $t2, 47
li $t1, 45
add $s1, $t1, $t3
beq $t2, $s1, next
add $s3, $s3, $s3
add $s3, $s3, $s3
next:
li $t9, 120
sw $t9, 36 
addi $t1, $t1, 2
beq $t1, $t2, next2
add $s3, $s3, $s3
add $s3, $s3, $s3
next2:
sub $s3, $s3, $s3
sub $s3, $s3, $s3
sw $s3, 40
# test lw-beq
lw $t1, 0
beq $t1, $zero, next3
addi $s1, $t1, 458
addi $s1, $t1, 125
sw $s1, 44
next3:
lw $t1, 4
ori $t2, $s1, 1254
beq $zero, $t1, next4
addi $s1, $t1, 458
addi $s1, $t1, 125
sw $s1, 48
next4:
lw $t1, 8
lw $t2, 12
beq $t1, $t2, next5
addi $s1, $t1, 458
addi $s1, $t1, 125
sw $s1, 52
next5:
li $t4, 4
ori $s1, $t1, 458
addi $s1, $t1, 125
lw $t4, 0
lw $t2, 4($t4)
beq $t2, $t4, next6
addi $s1, $t1, 458
addi $s1, $t1, 125
next6:
addi $s1, $t1, 458
addi $s1, $t1, 125
sw $s1, 56