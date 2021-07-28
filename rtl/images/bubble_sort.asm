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

#########################
#	bubble sort
#########################

# arr = {5,1,4,2,8}

li $s7, 0		# s7 <= basedir of arr[]
add $t0, $s7, $zero	# t0 index to load values to arr[]
li $t1, 5
sw $t1, 0($t0)
li $t1, 1
addi $t0, $t0, 4
sw $t1, 0($t0)
li $t1, 4
addi $t0, $t0, 4
sw $t1, 0($t0)
li $t1, 2
addi $t0, $t0, 4
sw $t1, 0($t0)
li $t1, 8
addi $t0, $t0, 4
sw $t1, 0($t0)
li $t0, 0	# reset index
li $t2, 4	# t2 <= n, size of arr[]
li $t3, 0 	# i
li $t4, 0	# j
addi $t5, $t2, -1	# n-1
init_for:
slt $t7, $t3, $t5	# t7 <= (i < n-1)
beq $t7, $zero, exit	# !(i < n-1) => exit
#addi $t3, $t3, 1	# i++
sub $s0, $t2, $t3	# s0 <= n-i (delay slot)
addi $s0, $s0, -1	# s0 <= (n-i)-1
second_for:
slt $s1, $t4, $s0	# s1 <= j < n-i-1
beq $s1, $zero, next
#addi $t4, $t4, 1	# j++
sll $t0, $t4, 2		# t0 <= j * 4
add $t0, $s7, $t0	# t0 <= base + j*4
addi $t1, $t0, 4	# t1 <= base + j*4 + 1
lw $s2, 0($t0)		# s2 <= arr[j]
lw $s3, 0($t1)		# s3 <= arr[j+1]
slt $s6, $s3, $s2	# s6 <= arr[j+1] < arr[j]
beq $s6, $zero, endif	# if !(arr[j+1]1 < arr[j]): endif
add $s4, $s2, $zero	# s4 <= temp <= arr[j]
sw $s3, 0($t0)		# arr[j] <= arr[j+1]
sw $s4, 0($t1)		# arr[j+4] <= temp
endif:
j second_for
addi $t4, $t4, 1	# j++	(take advantage of delay slot)
next:
li $t4, 0	# j = 0 when second for goes out of scope
j init_for
addi $t3, $t3, 1	# i++  (take advantage of delay slot)
exit: