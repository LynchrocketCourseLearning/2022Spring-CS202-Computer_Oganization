.macro print_string(%str)
.data 
	pstr: .asciiz   %str
.text
	la $a0,pstr
	li $v0,4
	syscall
.end_macro

.text
	# read in the integer
	li $v0 5
	syscall
	
	# move the integer to a register
	move $t0, $v0
	
	# test for binary
	move $t1, $t0
	addi $t2, $zero, 0
loop_2:
	sll $t2, $t2, 1
	and $t3, $t1, 1
	or $t2, $t2, $t3
	srl $t1, $t1, 1
	bne $t1, 0, loop_2
	# save the result
	add $t4, $zero, $t2
	# the result is in t4 register
	
	# print the origin number
	add $a0, $zero, $t0
	li $v0, 1
	syscall
	
	# compare if they are equal
	beq $t0, $t4, palin_2
	print_string(" is NOT binary palindrome, ")
	j pa_16
palin_2:
	print_string(" is binary palindrome, ")	

	# test for hexadecimal
pa_16:
	move $t1, $t0
	addi $t2, $zero, 0
loop_16:
	sll $t2, $t2, 4
	and $t3, $t1, 0xf
	or $t2, $t2, $t3
	srl $t1, $t1, 4
	bne $t1, 0, loop_16
	# the result is in t2 register
	
	# print the origin number
	add $a0, $zero, $t0
	li $v0, 1
	syscall
	
	# compare if they are equal
	beq $t0, $t2, palin_16
	print_string(" is NOT hexadecimal palindrome")
	j pri
palin_16:
	print_string(" is hexadecimal palindrome")
		
pri:
	print_string("\nx2: ")
	li $v0 35
	add $a0, $zero, $t0
	syscall
	print_string("\nx2r: ")
	li $v0 35
	add $a0, $zero, $t4
	syscall

	print_string("\nx16: ")
	li $v0 34
	add $a0, $zero, $t0
	syscall
	print_string("\nx16r: ")
	li $v0 34
	add $a0, $zero, $t2
	syscall
	
	# end the program
	li $v0, 10
	syscall
