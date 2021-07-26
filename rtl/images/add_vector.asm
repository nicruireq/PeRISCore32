li $t1, 2
li $t2, 4
li $t3, 6
li $t4, 8
li $t5, 10
li $t6, 12
xor $s0, $s0, $s0
add $s0, $s0, $t1
add $s0, $s0, $t2
add $s0, $s0, $t3
add $s0, $s0, $t4
add $s0, $s0, $t5
add $s0, $s0, $t6
sw $s0, 0