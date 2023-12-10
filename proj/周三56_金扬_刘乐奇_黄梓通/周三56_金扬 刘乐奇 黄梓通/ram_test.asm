.data 0x0000				      		
	d0: .word 0x0
    d1: .word 0x1
    d2: .word 0x2
    d3: .word 0x3
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
    lw $2, 4($0)
    sw $2, 0xC80($30)
