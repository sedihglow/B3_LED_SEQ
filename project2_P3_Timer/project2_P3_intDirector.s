@ Filename: project2_P3_intDirector.s
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
.equ INTC_PENDING_IRQ2,   0xD8		  @ INTC_PENDING_IRQ3   register offset
.equ GPIOINT1A, 		  0x00000004  @ GPIOINT1A in MIR3   Mask
.equ TINT3, 		   	  0x20		  @ TINT3, DMTIMER3     Mask

.equ GPIO1_BASE,		  0x4804C000  @ GPIO1 				Base Address
.equ GPIO_IRQ_STAT_0,	  0x2C	  	  @ GPIO_IRQSTATUS_0 	register offset
.equ GPIO_31,			  0x80000000  @ GPIO_31 raised bit	Mask


.equ TIMER3_BASE,		  0x48042000  @ DMTIMER3 			Base Address
.equ TIMER3_IRQ_STAT,	  0x28		  @ IRQENABLE			register offset
.equ TCLR,				  0x38		  @ TCLR				register offset
.equ TCRR,				  0x3C		  @ TCRR				register offset
.equ TIMER_COUNTER_VAL,   0xFFFF80FF  @ Loaded into TLDR and TCRR, 1.00793s

gpio1_baseAddr .req R4
intc_baseAddr  .req R5

ledSetVal      .req R7
ledToSet	   .req R8  @ Set outside of interrupt Address of ledFlag 
bValue		   .req R9
bFlag 		   .req R10 @ Set outside of interrupt Address of blinkFlag
t1   		   .req R11	@ scratch register 1
t2 			   .req R12 @ scratch register 2

	STMFD SP!, {R0-R12, LR}

	LDR intc_baseAddr,=INTC_BASE
BTN_IRQ_TST:
	@ Check sure the interrupt occured from GPIO1_31 button press
	LDR t2, [intc_baseAddr, #INTC_PENDING_IRQ3]
	TST t2, #GPIOINT1A
	BEQ TIMER_IRQ_TST	 @ If GPIOINT1A_2 is a 0, check timer, not button

	@ Check if the button on GPIO_31 triggered the interrupt
	LDR	gpio1_baseAddr, =GPIO1_BASE
	LDR t2, [gpio1_baseAddr, #GPIO_IRQ_STAT_0]
	TST t2, #GPIO_31
	BNE SVC_BUTTON	 @ If GPIO_31 has a pending interrupt, service the button
	
TIMER_IRQ_TST:
	@ Check if the timer3 IRQ interrupt occured
	LDR t1, [intc_baseAddr, #INTC_PENDING_IRQ2]
	TST t1, #TINT3
	BNE SVC_TIMER3   @ If timer triggered the interrupt, service timer3
	BEQ END_SERVICE  @ Else it was not the button or timer, no service required
	
SVC_BUTTON:
	@ Disable GPIO_31 interrupt requests and INTC interrupt requests
	MOV R1, #GPIO_31
	STR R1, [gpio1_baseAddr, #GPIO_IRQ_STAT_0] @ 1 at bit 31 of GPIO_IRQ_STAT_0
	
	@ Ensure counter is reset to initial value in TCRR
	LDR R2, =TIMER3_BASE
	LDR R1, =TIMER_COUNTER_VAL
	STR R1, [R2, #TCRR]

	@ Set Auto-reload timer and the start timer bit for TIMER3
	MOV R1, #0x3 		@ bit 0 = start bit, bit 1 = auto reload bit
	STR R1, [R2, #TCLR] @ Set the TCLR

	@ Evaluate blinkFlag and set for active blinking or non-active blinking	
	LDR bValue, [bFlag]	
	CMP bValue, #0x0
	MOVEQ R1, #0x1 @ If blinkFlag == 0, set flag to initate blinking(1)
	MOVNE R1, #0x0 @ Else blinkFlag == 1, set flag to stop blinking (0)
	STR R1, [bFlag]
	STR R1, [ledToSet]
		
	B END_SERVICE
	
SVC_TIMER3:

	@ Turn off timer 3 interrupt and enable INTC for  next IRQ
	LDR R1, =TIMER3_BASE
	LDR R0, [R1, #TIMER3_IRQ_STAT]
	TST R0, #0x2 		@ Value to reset timer3 overflow IRQ request
	BEQ END_SERVICE     @ Timer did not overflow
	
	MOV R2, #0x2
	STR R2, [R1, #TIMER3_IRQ_STAT]
	
	@ If timer overflowed, set values for LED
	LDR bValue, [bFlag]	
	LDR ledSetVal, [ledToSet]
	
	CMP bValue, #0x1
	MOVNE ledSetVal, #0x0 @ Reset lefFlag to 0 since no blinking should be active

	@ If bFlag is a 1, LED's should be blinking	
	CMP ledSetVal, #0x0   @ If no LED is on, set LED0 in flag
	MOVEQ ledSetVal, #0x1
	BEQ SAVE_LED_INFO
	
	CMP ledSetVal, #0x01 @ If LED0 is on, set LED1 in flag
	MOVEQ ledSetVal, #0x2
	BEQ SAVE_LED_INFO
	
	CMP ledSetVal, #0x2  @ If LED1 is on, set LED2 in flag
	MOVEQ ledSetVal, #0x4
	BEQ SAVE_LED_INFO
	
	CMP ledSetVal, #0x4  @ If LED2 is on, set LED3 in flag
	MOVEQ ledSetVal, #0x8
	BEQ SAVE_LED_INFO
	
	CMP ledSetVal, #0x8  @ If LED3 is on, set LED0 in flag
	MOVEQ ledSetVal, #0x1
SAVE_LED_INFO:
	STR ledSetVal, [ledToSet]

END_SERVICE:		
	@ Disable NEWIRQA bit so processor can respond to IRQ
	MOV t2, #0x1
	STR t2, [intc_baseAddr, #INTC_CONTROL]
	
	LDMFD SP!, {R0-R12, LR}
	SUBS PC, LR, #4 @ Return to interupted program. Accounts for pipeline EX
.end