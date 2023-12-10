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
	addi $t2, $zero, 2 # divider
	addi $t3, $zero, 1 # bit-width
	
	ble $t1, 1, print_2
loop_2:
	div $t1, $t2
	mflo $t1
	addi $t3, $t3, 1
	bgt $t1, 1, loop_2

print_2:
	print_string("Its binary bit-width is ")
	add $a0, $zero, $t3
	li $v0, 1
	syscall
	
	move $t1, $t0
	addi $t2, $zero, 16 # divider
	addi $t3, $zero, 1 # bit-width
	
	ble $t1, 15, print_16
loop_16:
	div $t1, $t2
	mflo $t1
	addi $t3, $t3, 1
	bgt $t1, 15, loop_16

print_16:	
	print_string(", its number of hexadecimal digits in hexadecimal is ")
	add $a0, $zero, $t3
	li $v0, 1
	syscall
	
	# end the program
	li $v0, 10
	syscall
