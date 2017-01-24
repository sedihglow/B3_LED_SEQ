@ File: project1_divWsub.s
@ Prodecure to divide by subtraction with a rounded result.
@ Written by: James Ross

.text
.global _divWsub

@ Passed inputs
@ _divWsub, R1 - numerator
@			R2 - denominator
@ 			R0 - Result of division to returned
_divWsub:
.equ ERROR, 0xFFFFFFFF
	MOVEQ R0, #0xFFFFFFFF	 @ Set error flag for return
	STMFD R13!, {R4-R8, R14} @ Push, start function
	subCnt .req R0			 @ Count of subtractions stored in R3 for return
	numer  .req R1			 @ Numerator to be subtracted from
	denom  .req R2			 @ Denominator to subtract by
	t2rem  .req R4			 @ Holds the remainder*2 for compare
	toComp .req R5			 @ Holds the negetive input to two's compliment
	negResFlag .req R6 		 @ Flag to flip resulting subCnt,
							 @ no negate == 0, negate == 0
	
	MOV subCnt, #0x00        @ Initialize locals
	MOV negResFlag, #0x00
	MOV t2rem, #0x00

NUMER_CHECK:
	CMP numer, #0x00     		@ IF numerator >= 0
	BGE DENOM_CHECK				@ Jump to subtraction loop
	MOV toComp, numer  			@ Send to register to compliment
	BL TWO_COMP					@ Twos compliment the value
	MOV numer, toComp  			@ Save value in numerator
	MOV negResFlag, #0x01		@ Set negetive flag

DENOM_CHECK:	
	CMP denom, #0x00
	MOVEQ R0, #ERROR 			@ Set error flag for return
	BEQ END						@ IF denom == 0, return error
	BGT DWS_LOOP			   	@ Jump to subtraction loop
	MOV toComp, denom			@ ELSE send to register to compliment
	BL TWO_COMP				    @ Twos compliment the value
	MOV denom, toComp			@ Set denom to result
	
	CMP negResFlag, #0x01		@ IF numerator < 0 && denominator < 0
	MOVEQ negResFlag, #0x00		@ Do not return a negetive result
	MOVNE negResFlag, #0x01		@ ELSE return negetive result
	
DWS_LOOP:			 			@ while(num >= denom), divide with sub
	CMP	numer, denom 		    @ IF numer is >= denom
	ADDGE subCnt, subCnt, #1	@ Increase subtraction count
	SUBGE numer, numer, denom   @ Subtract denom from numerator
	BGE DWS_LOOP
	
REMAINDER_CHECK:
	MOV t2rem, numer, LSL #1 	@ multiply remainder in numer by 2
	CMP denom, t2rem			@ IF denom is LE t2rem
	ADDLE subCnt, subCnt, #1	@ Round result up by 1 
	
	CMP negResFlag, #0x01		@ IF negResFlag == 0x01
	MOVEQ toComp, subCnt		@ Change result to negetive before return 
	BLEQ TWO_COMP
	MOVEQ subCnt, toComp
END:
	LDMFD R13!, {R4-R8, PC}  	@ Pop, End function
	
TWO_COMP: @ Twos compliment toComp, register 6
	.equ MASK, 0xFFFFFFFF	    @ Bit mask for 32-bit register
	MOV R11, #MASK
	EOR	toComp, toComp, R11     
	ADD toComp, toComp, #0x01   
	MOV PC, R14					@ Return to procedure
.end