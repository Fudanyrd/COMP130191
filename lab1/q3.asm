.data
pmpt: .asciiz "The result is: "

.text
.globl main
.globl print
.globl sumn

main:
    # store the arrs to $s0.
    # size in $t0.
    # sum in $s1.
    addi $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)

    # construct the array(in stack)
    # arr = {9, 7, 15, 19, 20, 30, 11, 18}
    addi $sp, $sp, -32
    add $s0, $sp, $0
    # 9
    addi $t0, $0, 9
    sw $t0, 0($s0)
    # 7
    addi $t0, $0, 7
    sw $t0, 4($sp)
    # 15
    addi $t0, $0, 15
    sw $t0, 8($sp)
    # 19
    addi $t0, $0, 19
    sw $t0, 12($sp)
    # 20
    addi $t0, $0, 20
    sw $t0, 16($sp)
    # 30
    addi $t0, $0, 30
    sw $t0, 20($sp)
    # 11
    addi $t0, $0, 11
    sw $t0, 24($sp)
    # 18
    addi $t0, $0, 18
    sw $t0, 28($sp)
    
    # N = 8
    addi $t0, $0, 8
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    add $a0, $s0, $0
    add $a1, $t0, $0
    jal sumn
    add $s1, $a0, $0 # result in $s1.
    lw $t0, 0($sp)
    addi $sp, $sp, 4

    # print the result.
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $a0, $0, 4
    la $a1, pmpt
    jal print
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $a0, $0, 1
    add $a1, $s1, $0
    jal print
    lw $t0, 0($sp)
    addi $sp, $sp, 4

    addi $sp, $sp, 32  # restore stack.
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    addi $sp, $sp, 8

    # terminate the program
    addi $v0, $0, 10
    syscall


###############
# print 'something' to output stream.
# Usage:
# $a0 = 1: print integer(at $a1).
# $a0 = 4: print given string(at $a1)
###############
print:
	add $v0, $a0, $0
	add $a0, $a1, $0
	syscall
	jr $ra

###############
# sumn
# @param $a0: the array
# @param $a1: size of the array
# @returns sums of the array($a0)
###############
sumn:
    # $s0: the array
    # $s1: the loop variable idx.
    # $s2: the sum.
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    add $s0, $a0, $0
    add $s1, $0, $0
    add $s2, $0, $0

  lp:
    add $t0, $s1, $0
    sll $t0, $t0, 2
    add $t0, $s0, $t0
    lw $t1, 0($t0)
    add $s2, $t1, $s2
    addi $s1, $s1, 1 
    bne $a1, $s1, lp

  endLp:
    # store the result in $a0.
    add $a0, $s2, $0
    
    # reset stack pointer and s register
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 12
    # return
    jr $ra
