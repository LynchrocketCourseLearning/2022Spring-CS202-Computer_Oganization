.data 0x0000				      		
	
.text 0x0000
start:	lui   $1,0xFFFF			
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
        
        lui $25,0x1
        srl $25,$25,16    #$25 is 1
         
inputcase:
  	lw $2,0xC72($30)  #$2 decide which case
        
        srl $2, $2, 5
        
        sub $27, $27, $27
    	beq $2, $27, case0
    	
    	sub $27, $27, $27
	ori $27, $27, 0x1
    	beq $2, $27, case1
    	
    	sub $27, $27, $27
	ori $27, $27, 0x2
    	beq $2, $27, case2
    	
    	sub $27, $27, $27
	ori $27, $27, 0x3
    	beq $2, $27, case3

	sub $27, $27, $27
    	ori $27, $27, 0x4
    	beq $2, $27, case4
    	
    	sub $27, $27, $27
    	ori $27, $27, 0x5
    	beq $2, $27, case5
    	
    	sub $27, $27, $27
    	ori $27, $27, 0x6
    	beq $2, $27, case6
    	
    	sub $27, $27, $27
    	ori $27, $27, 0x7
    	beq $2, $27, case7


        j inputcase
        
case0:	
	lw $4,0xC72($30) #$4:whether to input $3
	andi $4,$4,0x10
	srl $4,$4,4
	beq $4,$0,state1
	lw $3,0xC70($30)
	andi $3,$3,0xF
	sll $4,$3,2
	lui $20,0x1001 #A[0]  dataset0
	sub $21,$20,$4 #A[1]  dataset1
	sub $22,$21,$4 #A[2]  dataset2
	sub $23,$22,$4 #A[3]  dataset3
	j inputcase
state1: 
	lw $5,0xC70($30)
	andi $5,$5,0xF00
	srl $5,$5,8       # which number to input
	
	lw $6,0xC70($30)
	andi $6,$6,0xFF
	
	sll $5,$5,2
	add $5,$5,$20
	sw $6,0($5)
	sw $6,0xC60($30)
	j inputcase
	
case1:
	sub $14,$14,$14
copy:
	beq $14,$3,endcopy    #copy dataset0 to dataset1
	sll $4,$14,2
	add $6,$4,$20
	lw $5,0($6)
	add $7,$4,$21
	sw $5,0($7)
	add $14,$14,$25
	j copy
endcopy:
	sub $14,$14,$14
sort1:  			#sort dataset1
	sub $7,$3,$25
	beq $14,$7,endsort
	sub $15,$15,$15
sort2:  sub $8,$3,$14
	sub $8,$8,$25
	beq $15,$8,endsort2
	add $9,$15,$25
	sll $9,$9,2  #$9=4*($15+1)
	sll $10,$15,2 #$10=4*$15
	
	add $11,$21,$9
	add $12,$21,$10
	lw $6,0($11)
	lw $5,0($12)
	slt $4,$6,$5
	bne $4,$25,endif
	sw $5,0($11)
	sw $6,0($12)
endif:
	add $15,$15,$25
	j sort2
endsort2:
	add $14,$14,$25
	j sort1
endsort:
	j inputcase
	
case2:
	
	sub $14,$14,$14
copy2:	beq $14,$3,endCopy2       #get number from dataset0
	sll $4,$14,2
	add $7,$20,$4
	lw $5,0($7)
	andi $6,$5,0x80
	 
	beq $6,$0,endif1
	andi $5,$5,0x7F
	sub $8,$8,$8		#transform it to complement
	addi $8,$8,0xFFFFFFFF
	sub $5,$8,$5
	add $5,$5,$25
endif1:
	add $7,$4,$22
	sw $5,0($7)
	
	add $14,$14,$25
	j copy2
endCopy2:
	j inputcase	

case3:	 

	sub $14,$14,$14
copy_3:
	beq $14,$3,endcopy_3  #copy dataset2 to dataset3
	sll $4,$14,2
	add $6,$4,$22
	lw $5,0($6)
	add $7,$4,$23
	sw $5,0($7)
	add $14,$14,$25
	j copy_3
endcopy_3:
	sub $14,$14,$14
	
sort1_3:		
	sub $7,$3,$25		#sort dataset3
	beq $14,$7,endsort_3
	sub $15,$15,$15
sort2_3:  sub $8,$3,$14
	sub $8,$8,$25
	beq $15,$8,endsort2_3
	add $9,$15,$25
	sll $9,$9,2  #$9=4*($15+1)
	sll $10,$15,2 #$10=4*$15
	
	add $11,$23,$9
	add $12,$23,$10
	lw $6,0($11)
	lw $5,0($12)
	slt $4,$6,$5
	bne $4,$25,endif_3
	sw $5,0($11)
	sw $6,0($12)
endif_3:
	add $15,$15,$25
	j sort2_3
endsort2_3:
	add $14,$14,$25
	j sort1_3
endsort_3:
	j inputcase
	
case4:
	sub $6,$3,$25
	sll $6,$6,2
	add $7,$6,$21
	lw $4,0($7)
	lw $5,0($21)
	sub $4,$4,$5
	sw $4, 0xC60($30)
	sw $4, 0xC80($30)
	
    	
    	j inputcase
    	
case5:
	sub $6,$3,$25
	sll $6,$6,2
	add $7,$6,$23
	lw $4,0($7)
	lw $5,0($23)
	sub $4,$4,$5
	sw $4, 0xC60($30)
	sw $4, 0xC80($30)
	
    	j inputcase
    	
case6:	
	lw $4,0xC72($30)
	lw $5,0xC70($30)	
	andi $4,$4,0x3    #which set
	andi $5,$5,0xF000	#set index
	srl $5,$5,12
	
	beq $4,$25,set1
	
	addi $9,$0,2
	beq $4,$9,set2
	
	addi $9,$0,3                                                                                                                                                                                                                                                                                                                                                                                                                                          
	beq $4,$9,set3
	
	j inputcase
set1:	
	sll $5,$5,2
	add $7,$5,$21
	lw $8,0($7)
	andi $8,$8,0xFF
	sw $8,0xC60($30)
	sw $8,0xC80($30)
	j inputcase
	
set2:	
	sll $5,$5,2
	add $7,$5,$22
	lw $8,0($7)
	andi $8,$8,0xFF
	sw $8,0xC60($30)
	sw $8,0xC80($30)
	j inputcase
	
set3:	
	sll $5,$5,2
	add $7,$5,$23
	lw $8,0($7)
	andi $8,$8,0xFF
	sw $8,0xC60($30)
	sw $8,0xC80($30)
	j inputcase
	
case7:
	lw $5,0xC70($30)
	andi $5,$5,0xF000	#set index
	srl $5,$5,12
	
	sll $5,$5,2
	
	add $6,$5,$20
	lw $7,0($6)
	andi $7,$7,0xFF
	sw $0,0xC80($30)
	sw $7,0xC60($30)
	and $14,$14,$0
sleep1:
	lui $8,0xFF
	ori $8,$8,0xFFFF
	beq $14,$8,endsleep1
	nop
	addi $14,$14,0x1
	j sleep1
	
endsleep1:
	add $6,$5,$22
	lw $7,0($6)
	andi $7,$7,0xFF
	addi $11,$0,0x2
	sw $11,0xC80($30)
	sw $7,0xC60($30)
	and $14,$14,$0
sleep2:
	lui $8,0xFF
	ori $8,$8,0xFFFF
	beq $14,$8,endsleep2
	nop
	addi $14,$14,0x1
	j sleep2

endsleep2:
	j inputcase
	
	
	
