@ Filename: project2_P2_intDirector.s
@
@ Contains the interuppt director for our interupts. There is no sys interrupts
@ so hooking is contained in startup_ARMCA8.S directly on the vector table.
@ This function will ensure the button was pressed for our interrupt, check
@ the state of the blinking LED's. If they are currently blinking, the 
@ interrupt will disable them, if they are not blinking it will enable them.
@
@ Written by: James Ross

.text
.global _int_director
_int_director:
.equ INTC_BASE,			  0x48200000  @ INCPS 				Base Address
.equ INTC_CONTROL,		  0x48		  @ INTC_CONTROL		register offset
.equ INTC_MIR_CLEAR3,	  0xE8		  @ INTC_MIR_CLEAR3 	register offset
.equ INTC_PENDING_IRQ3,	  0xF8		  @ INTC_PENDING_IRQ3	register offset

.equ GPIO1_BASE,		  0x4804C000  @ GPIO1 				Base Address
.equ GPIOINT1A, 		  0x00000004  @ GPIOINT1A in MIR3   Mask
.equ GPIO_IRQ_STAT_0,	  0x2C	  	  @ GPIO_IRQSTATUS_0 	register offset
.equ GPIO_31,			  0x80000000  @ GPIO_31 raised bit	Mask

gpio1_baseAddr .req R4
intc_baseAddr  .req R7
bValue		   .req R9
bFlag 		   .req R10
t1   		   .req R11	@ scratch register 1
t2 			   .req R12 @ scratch register 2


	STMFD SP!, {R1,R4, R7, R9-R12, LR}
	
	@ Make sure the interrupt occured from GPIO1_31 button press		
	LDR intc_baseAddr,=INTC_BASE
	LDR t2, [intc_baseAddr, #INTC_PENDING_IRQ3]
	TST t2, #GPIOINT1A
	BEQ END_SERVICE	    @ If GPIOINT1A_2 is a 0, exit interrupt, not button.

	@ Check if the button on GPIO_31 triggered the interrupt
	LDR	gpio1_baseAddr, =GPIO1_BASE
	LDR t2, [gpio1_baseAddr, #GPIO_IRQ_STAT_0]
	TST t2, #GPIO_31
	BNE SVC_BUTTON	 @ If GPIO_31 has a pending interrupt, service the button
	BEQ END_SERVICE  @ Else, it was not the button, no service required
	
END_SERVICE:		
	LDMFD SP!, {R1,R4, R7, R9-R12, LR}
	SUBS PC, LR, #4 @ Return to interupted program. Accounts for pipeline EX
	
SVC_BUTTON:
	@ Disable GPIO_31 interrupt requests and INTC interrupt requests
	MOV R1, #GPIO_31
	STR R1, [gpio1_baseAddr, #GPIO_IRQ_STAT_0] @ Store 1 at bit 31 of GPIO_IRQ_STAT_0
	
	@ Disable NEWIRQA bit so processor can respond to IRQ
	MOV t2, #0x1
	STR t2, [intc_baseAddr, #INTC_CONTROL]

	LDR bValue, [bFlag]	
	CMP bValue, #0x0
	MOVEQ R1, #0x1 @ If blinkFlag == 0, set flag to initate blinking(1)
	MOVNE R1, #0x0 @ Else blinkFlag == 1, set flag to stop blinking (0)
	STR R1, [bFlag]
		
	B END_SERVICE
.end