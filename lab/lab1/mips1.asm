.data
	str1:  .ascii "hello,rainny day" #str1 (lable)
	str2:  .asciiz "welcome back"
.text
	li $v0,4  # load immediate 4
	la $a0,str1 # load addresss 0x10010000 -¡·$a0
	syscall  # check $v0 ? v0:4->print string, check $a0?
	
	li $v0,5
	syscall   #  get input  -> $v0
	move $a0,$v0
	or $a0,$v0,$0
	
	li $v0,1
	syscall
	
	li $v0,10
	syscall 