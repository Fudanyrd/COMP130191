.data
# string literals
pmpt1: .asciiz "Please enter 1st number: "
pmpt2: .asciiz "Please enter end number: "
pmpt31: .asciiz "The result of "
pmpt32: .asciiz " & "
pmpt33: .asciiz " is: "
pmpt4: .asciiz "Do you want to try another(0-continue/1-exit): "
empty: .asciiz ""
dashn: .asciiz "\n"

.text
.globl main
# helper functions
.globl print
.globl println
.globl readint
.globl sumpr
.globl run

main:
	# call function 'run'
	jal run 
	# terminate
	addi $v0, $0, 10
	syscall

###############
# print 'something' to output stream terminate current line.
# Usage:
# $a0 = 1: print integer(at $a1).
# $a0 = 4: print given string(at $a1)
###############
println:
	add $v0, $a0, $0
	add $a0, $a1, $0
	syscall
    # print '\n'.
    addi $v0, $0, 4
    la $a0, dashn    # load address
	syscall
	jr $ra

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
# read a integer and set to $a0.
###############
readint:
	addi $v0, $0, 5
	syscall
	add $a0, $v0, $0
	jr $ra

###############
# run sumpr many times
###############
run:
	# use $s0 as counter.
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)

  loop:	
	jal sumpr
	addi $a0, $0, 4
	la $a1, pmpt4
	jal print
	jal readint
	add $s0, $a0, $0
	bne $s0, $0, endloop
	j loop
  endloop:
	# restore $s0, $ra.
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	# return.
	jr $ra

###############
# read two integers and print the sum.
###############
sumpr:
	# store original value
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)

	# get the left operand
	addi $a0, $0, 4
	la $a1, pmpt1
	jal print
	jal readint
	add $s0, $a0, $0

	# get the second operand
	addi $a0, $0, 4
	la $a1, pmpt2
	jal print
	jal readint
	add $s1, $a0, $0

	addi $a0, $0, 4
	la $a1, pmpt31
	jal print
	addi $a0, $0, 1
	add $a1, $s0, $0
	jal print
	addi $a0, $0, 4
	la $a1, pmpt32
	jal print
	addi $a0, $0, 1
	add $a1, $s1, $0
	jal print
	addi $a0, $0, 4
	la $a1, pmpt33
	jal print

	add $a1, $s0, $s1
	addi $a0, $0, 1
	jal println

	# reset $s0, $s1.
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12

	# return
	jr $ra