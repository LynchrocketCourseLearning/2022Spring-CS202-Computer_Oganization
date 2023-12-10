.data 0x0000				      		
	
.text 0x0000	
# $31 is $ra
# $30 store the base address for IO device
# 0xFFFF FC6x for LED	(write only)	
# 0xFFFF FC7x for switch     (read only)
# 0xFFFF FC8x for seg display	(write only)				
start:  lui   $1,0xFFFF			
        ori   $30,$1,0xF000	
        # reset all the registers to 0, except $30
        sub $0, $0, $0
        sub $1, $1, $1
        sub $2, $2, $2
        sub $3, $3, $3
        sub $4, $4, $4
        sub $5, $5, $5
        sub $6, $6, $6
        sub $7, $7, $7
        sub $8, $8, $8
        sub $9, $9, $9
        sub $10, $10, $10
        sub $11, $11, $11
        sub $12, $12, $12
        sub $13, $13, $13
        sub $14, $14, $14
        sub $15, $15, $15
        sub $16, $16, $16
        sub $17, $17, $17
        sub $18, $18, $18
        sub $19, $19, $19
        sub $20, $20, $20
        sub $21, $21, $21
        sub $22, $22, $22
        sub $23, $23, $23
        sub $24, $24, $24
        sub $25, $25, $25
        sub $26, $26, $26
        sub $27, $27, $27
        sub $28, $28, $28
        sub $29, $29, $29
        sub $31, $31, $31

Loop : 
    #$2 is the left 8 bits of switch
    lw $2,0xC72($30)	
    #$3 is the 17th switch, 1 indicating inputting A and 0 inputting B
    andi $3, $2, 0x1
    srl $2, $2, 5
    #the input is B
    beq $3, $0, Binput
    #$4 stores value of A
    lw $4, 0xC70($30)
    j assignmentFinished
Binput:
    #$5 stores the value of B
    lw $5, 0xC70($30)
assignmentFinished:
    # jump to the corresponding case according to the value of $2
    sub $29, $29, $29
    beq $2, $29, case0

    sub $29, $29, $29
	ori $29, $29, 0x1
    beq $2, $29, case1

    sub $29, $29, $29
	ori $29, $29, 0x2
    beq $2, $29, case2

    sub $29, $29, $29
    ori $29, $29, 0x3
    beq $2, $29, case3

    sub $29, $29, $29
    ori $29, $29, 0x4
    beq $2, $29, case4

    sub $29, $29, $29
    ori $29, $29, 0x5
    beq $2, $29, case5

    sub $29, $29, $29
    ori $29, $29, 0x6
    beq $2, $29, case6

    sub $29, $29, $29
    ori $29, $29, 0x7
    beq $2, $29, case7
	j Loop

case0:
    sw $4, 0xC60($30)
    # copy the value of $4 to $10, compute $11 as the inverse of $4
    or $10, $10, $4
    sub $11, $11, $11
case0_Loop:
    beq $10, $0, case0_output
    # $12 = $10[0]
    sll $1, $10, 31
    srl $12, $1, 31
    sll $11, $11, 1
    or $11, $11, $12
    srl $10, $10, 1
    j case0_Loop 
    # if $11 == $4, $4 is binary parlindrome
case0_output:
    add $13, $13, $11
    sw $13, 0xC80($30)
    srl $13, $13, 16
    sw $13, 0xC82($30)
    sub $28, $28, $28
    beq $11, $4, case0_true
    # $28[0] stores the value of #17 LED
    sw $28, 0xC62($30)
    j Loop
case0_true:
    ori $28, $28, 0x1
    sw $28, 0xC62($30)
    j Loop

case1:
    sub $28, $28, $28
    sw $28, 0xC62($30)
    beq $3, $0, case1_outputA
    sw $5, 0xC60($30)
    sw $5, 0xC80($30)
    sw $28, 0xC62($30)
    j Loop
case1_outputA:
    sw $4, 0xC60($30)
    sw $4, 0xC80($30)
    j Loop

case2:
    sub $28, $28, $28
    sw $28, 0xC62($30)
    and $6, $4, $5
    sw $6, 0xC60($30)
    sw $6, 0xC80($30)
    j Loop

case3:
    sub $28, $28, $28
    sw $28, 0xC62($30)
    or $6, $4, $5
    sw $6, 0xC60($30)
    sw $6, 0xC80($30)
    j Loop

case4:
    sub $28, $28, $28
    sw $28, 0xC62($30)
    xor $6, $4, $5
    sw $6, 0xC60($30)
    sw $6, 0xC80($30)
    j Loop

case5:
    sub $28, $28, $28
    sw $28, 0xC62($30)
    sllv $6, $4, $5
    sw $6, 0xC60($30)
    sw $6, 0xC80($30)
    j Loop

case6:
    sub $28, $28, $28
    sw $28, 0xC62($30)
    sll $4, $4, 16
    srl $4, $4, 16
    srlv $6, $4, $5
    sw $6, 0xC60($30)
    sw $6, 0xC80($30)
    j Loop

case7:
    sub $28, $28, $28
    sw $28, 0xC62($30)
    sll $4, $4, 16
    sra $4, $4, 16
    srav $6, $4, $5
    sw $6, 0xC60($30)
    sw $6, 0xC80($30)
    j Loop
