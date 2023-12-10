.macro print_str(%str)
.data 
	pstr: .asciiz   %str
.text
	la $a0,pstr
	li $v0,4
	syscall
.end_macro

.data
	zero: .float 0.0
	a: .asciiz "a"
	b: .asciiz "b"
	c: .asciiz "c"
	d: .asciiz "d"
	e: .asciiz "e"
	f: .asciiz "f"
.text
	li $v0 5
	syscall # read in the type, stored in $v0
	li $t0, 6
	beq $v0, $t0, single # equal to 6, single
	li $t0, 7
	beq $v0, $t0, double # equal to 7, double
	# invalid
	print_str("Invalid float type")
	j end
	
single:
	li $v0, 6 
	syscall # read in the number, stored in $f0
	lwc1 $f2, zero
	c.lt.s $f0, $f2 # less than 0.0
	bc1t print_1s
	print_str("s: 0, ")
	j nexts
print_1s:
	print_str("s: 1, ")
nexts:
	mfc1 $t0, $f0 # change float to integer, stored in $t0
	sll $t0, $t0, 1 # delete the sign bit
	andi $t1, $t0, 0xff000000 # extract the exponent bits, in the highest 8-bit
	print_str("e: 0x")
	move $t3, $zero # used as counter
loop_es:
	andi $t2, $t1, 0xf0000000 # extract the highest 4-bit
	sll $t1, $t1, 4 # throw the highest 4-bit
	srl $t2, $t2, 28 # to the lowest
	addi $t3, $t3, 1
	move $a0, $t2
	jal print_num
	bne $t3, 2, loop_es
	
	andi $t1, $t0, 0x00ffffff # extract the fraction bits, in the lowest 24-bit, with lowest bit is meaningless
	sll $t1, $t1, 7 # to the highest bits, 0+23-bit
	print_str(", f: 0x")
	move $t3, $zero # used as counter
loop_fs:
	andi $t2, $t1, 0xf0000000 # extract the highest 4-bit
	sll $t1, $t1, 4 # throw the highest 4-bit
	srl $t2, $t2, 28 # to the lowest
	addi $t3, $t3, 1
	move $a0, $t2
	jal print_num
	bne $t3, 6, loop_fs
	j end
	
double:
    li $v0, 7 
	syscall # read in the number, stored in $f0
	ldc1 $f2, zero
	c.lt.d $f0, $f2 # less than 0.0
	bc1t print_1d
	print_str("s: 0, ")
	j nextd
print_1d:
	print_str("s: 1, ")
nextd:
	mfc1 $t0, $f1 # take the highest 32-bit to $t0
	mfc1 $t1, $f0 # take the lowest 32-bit to $t1
	andi $t2, $t0, 0xfff00000  #extract the highest 12-bit
	sll $t2, $t2, 1 # delete the sign bit
	srl $t2, $t2, 1
	# the exponent bits are in $t2
	print_str("e: 0x")
	move $t3, $zero # used as counter
loop_ed:
	andi $t4, $t2, 0xf0000000 # extract the highest 4-bit
	srl $t4, $t4, 28 # to the lowest
	sll $t2, $t2, 4 # throw the highest 4-bit
	addi $t3, $t3, 1 # add 1 to counter 
	move $a0, $t4
	jal print_num
	bne $t3, 3, loop_ed
	
	# the fraction bits are in the lowest 20-bit of $t0 and all bits of $t1
	andi $t2, $t0, 0x000fffff # extract the fraction bits in the lowest 20-bit of $t0
	sll $t2, $t2, 12 # to the highest bits
	print_str(", f: 0x")
	move $t3, $zero # used as counter
loop_fd_1:
	andi $t4, $t2, 0xf0000000 # extract the highest 4-bit
	srl $t4, $t4, 28 # to the lowest
	sll $t2, $t2, 4 # throw the highest 4-bit
	addi $t3, $t3, 1 # add 1 to counter 
	move $a0, $t4
	jal print_num
	bne $t3, 5, loop_fd_1
loop_fd_2: # for the  fraction bits in $t1
	andi $t4, $t1, 0xf0000000 # extract the highest 4-bit
	srl $t4, $t4, 28 # to the lowest
	sll $t1, $t1, 4 # throw the highest 4-bit
	addi $t3, $t3, 1 # add 1 to counter 
	move $a0, $t4
	jal print_num
	bne $t3, 13, loop_fd_2
	
	j end
	
print_num:
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	beq $a0, 10, print_a
	beq $a0, 11, print_b
	beq $a0, 12, print_c
	beq $a0, 13, print_d
	beq $a0, 14, print_e
	beq $a0, 15, print_f
	li $v0, 1 # if less than 9, print
	syscall
	j ed
print_a:	
	la $a0, a
	li $v0, 4
	syscall
	j ed
print_b:
	la $a0, b
	li $v0, 4
	syscall
	j ed
print_c:
	la $a0, c
	li $v0, 4
	syscall
	j ed
print_d:
	la $a0, d
	li $v0, 4
	syscall
	j ed
print_e:
	la $a0, e
	li $v0, 4
	syscall
	j ed
print_f:
	la $a0, f
	li $v0, 4
	syscall
ed:
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
end:
	li $v0 10
	syscall
