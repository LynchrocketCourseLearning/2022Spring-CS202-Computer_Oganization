.macro divSCheck(%f1,%f2,%f3)
.data
	z: .float 0.0
.text
	addi $sp, $sp, -8
	swc1 %f2, 0($sp)
	swc1 %f3, 4($sp)
	lwc1 $f4, z
	c.eq.s %f3, $f4 # if not 0, escape from trap
	bc1f tL
	addi $k0, $k0, 11 # change $k0
	cvt.w.s $f5, %f3 # let float in $f3 be integer, to trigger the trap
	mfc1 $t0, $f5
	teqi $t0, 0
tL:
	lwc1 %f2, 0($sp)
	lwc1 %f3, 4($sp)
	addi $sp, $sp, 8
	
	div.s %f1, %f2, %f3
.end_macro 

.text
	li $v0,6
	syscall
	mov.s $f20,$f0
	li $v0,6
	syscall
	mov.s $f21,$f0 
	divSCheck($f12,$f20,$f21)
	li $v0,2
	syscall
	li $v0,10
	syscall