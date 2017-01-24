@ Filename: Project1_P2_delay.s
@ Holds the function _delaySecond
@ A NOP loop that will stall the system for 1 second.
@ Written by: James Ross

.text
.global _delaySecond
_delaySecond:
.equ NOP_COUNT, 0x00300000
	counter .req R3
	
	STMFD R13!, {R3, LR} 	@ Push, start function
	LDR counter, =NOP_COUNT
DELAY_LOOP:
	SUBS counter, counter, #0x1
	BNE DELAY_LOOP
	LDMFD R13!, {R3, PC}  	@ Pop, End function
.end