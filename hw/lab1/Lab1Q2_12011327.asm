.macro print_string(%str)
.data 
	pstr: .asciiz   %str
.text
	la $a0,pstr
	li $v0,4
	syscall
.end_macro

.text
	li $v0 5
	syscall
	
	move $t0, $v0
	
	move $t1, $t0
	addi $t2, $zero, 0 # 0, used to store the result
loop_2:
	sll $t2, $t2, 1
	and $t3, $t1, 1
	or $t2, $t2, $t3
	srl $t1, $t1, 1
	bne $t1, 0, loop_2
	
	print_string("x2: ")
	li $v0 35
	add $a0, $zero, $t0
	syscall
	print_string("\nx2r: ")
	li $v0 35
	add $a0, $zero, $t2
	syscall

	move $t1, $t0
	addi $t2, $zero, 0
loop_16:
	sll $t2, $t2, 4
	and $t3, $t1, 0xf
	or $t2, $t2, $t3
	srl $t1, $t1, 4
	bne $t1, 0, loop_16
		
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
