.data
str: .asciiz "Fn = "
dashn: .asciiz "\n"
.text

.globl MatMul
.globl MatSquare
.globl main
.globl fib
###################
# @brief calculate Ax, A is a (2,2) matrix, x is a 2-dim vector.
# @param $a0: matrix A.
# @param $a1: x[out].
# This is in-place, no return value.
###################
MatMul:
    addi $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    add $s0, $0, $0
    add $s1, $0, $0

    # do $s0.
    lw $t0, 0($a1)  # x[0]
    lw $t1, 4($a1)  # x[1]
    lw $t2, 0($a0)  # A[0][0]
    lw $t3, 4($a0)  # A[0][1]
    mul $t2, $t2, $t0  # A[0][0] * x[0]
    add $s0, $s0, $t2   
    mul $t3, $t3, $t1  # A[0][1] * x[1]
    add $s0, $s0, $t3

    # do $s1.
    lw $t2, 8($a0)   # A[1][0]
    lw $t3, 12($a0)  # A[1][1]
    mul $t2, $t2, $t0  # A[1][0] * x[0]
    add $s1, $s1, $t2   
    mul $t3, $t3, $t1  # A[1][1] * x[1]
    add $s1, $s1, $t3

    # in-place malipulate x.
    sw $s0, 0($a1)
    sw $s1, 4($a1)

    # reset s and sp.
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    addi $sp, $sp, 8 

    jr $ra

###################
# @brief calculate A^2 in place.
# @param $a0: the (2, 2) matrix A.
# @returns none
###################
MatSquare:
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)

    # initialize $s0-$s3.
    add $s0, $0, $0
    add $s1, $0, $0
    add $s2, $0, $0
    add $s3, $0, $0
    # load the matrix.
    lw $t0, 0($a0)
    lw $t1, 4($a0)
    lw $t2, 8($a0)
    lw $t3, 12($a0)  # don't touch these values later.

    # calculate new A[0][0]
    mul $t4, $t0, $t0
    mul $t5, $t1, $t2
    add $t4, $t4, $t5
    sw $t4, 0($a0)  # done

    # calculate new A[0][1]
    mul $t4, $t0, $t1
    mul $t5, $t1, $t3
    add $t4, $t4, $t5
    sw $t4, 4($a0)  # done

    # calculate new A[1][0]
    mul $t4, $t2, $t0
    mul $t5, $t3, $t2
    add $t4, $t4, $t5
    sw $t4, 8($a0)  # done

    # calculate new A[1][1]
    mul $t4, $t2, $t1
    mul $t5, $t3, $t3
    add $t4, $t4, $t5
    sw $t4, 12($a0)  # done

    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 16
    # return
    jr $ra

###################
# @brief calculate Fn(the nth element in Fibonacchi.
# @param $a0: n.
###################
fib:
    # $s0: store A.
    # $s1: store x.
    # $s2: the result
    # $s3: the n.
    # ra
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    addi $s3, $a0, -2  # $s3 = n - 2
    ble $s3, $0, end

    addi $t0, $0, 1  # one
    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t0, 4($sp)
    sw $t0, 8($sp)
    sw $0, 12($sp)
    add $s0, $sp, $0
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t0, 4($sp)
    add $s1, $sp, $0
  loop:
    addi $t0, $0, 1
    and $t0, $s3, $t0
    srl $s3, $s3, 1
    beq $t0, $0, next
    add $a0, $s0, $0
    add $a1, $s1, $0
    jal MatMul
  next:
    add $a0, $s0, $0
    jal MatSquare
    bne $s3, $0, loop 

  endloop:
    lw $a0, 0($s1)
    addi $sp, $sp, 24
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $ra, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    # return
    jr $ra

  end:
    # if n <= 2, return 1 immediately.
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $ra, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    addi $a0, $0, 1
    jr $ra

main:
  while:
    jal readint
    beq $0, $a0, terminate
    jal fib
    # store the result of fib in $s0.
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    add $s0, $a0, $0
    addi $v0, $0, 4
    la $a0, str
    syscall
    addi $v0, $0, 1
    add $a0, $s0, $0
    syscall
    addi $v0, $0, 4
    la $a0, dashn 
    syscall
    # reset $s0.
    lw $s0, 0($sp)
    addi $sp, $sp, 4

    j while

  terminate:
    addi $v0, $0, 10
    syscall

###############
# read a integer and set to $a0.
###############
readint:
	addi $v0, $0, 5
	syscall
	add $a0, $v0, $0
	jr $ra