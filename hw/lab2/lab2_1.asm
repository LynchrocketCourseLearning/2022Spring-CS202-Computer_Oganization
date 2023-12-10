.data
	n_double: .double 1.0
	t_double: .double 0.0
.text
	li $v0, 7
	syscall # $f0 is the threshold
	mov.d $f6, $f0 # move thres to $f6
	ldc1 $f12, t_double # res
	ldc1 $f2, n_double # tmp
	ldc1 $f4, n_double # double 1.0
	li $a0, 1 # n
loop:
	add.d $f12, $f12, $f2 # res = res + tmp
	jal fact # compute the factorial
	mtc1 $v0, $f1 # $v0 = fact(n)
	cvt.d.w $f2, $f1 # tmp = (double)fact(n)
	div.d $f2,$f4,$f2 # tmp = 1.0/tmp
	addi $a0, $a0, 1 # n = n+1
	c.le.d $f6, $f2 # thres <= tmp, break
	bc1f end
	j loop
fact:	
	li $t1,1
	bgt $a0,$t1,recur
	li $v0,1
	jr $ra
recur:	
	addi $sp,$sp,-8
	sw $a0,0($sp)
	sw $ra,4($sp)
	addi $a0,$a0,-1
	jal fact
	lw $a0,0($sp)
	lw $ra,4($sp)
	addi $sp,$sp,8
	mul $v0,$v0,$a0
	jr $ra
end:
	li $v0, 3
	syscall # print double
	li $v0, 10
	syscall # exit