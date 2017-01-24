@ Filename: project2_P3_blinkLoop.s
@
@ Toggles the LED's to blink in sequence, Should be cut off when interuppt 
@ occures if the LED's are mid blink.
@ 
@ Writtne by: James Ross



.text
.global _blink_sequence
.global _stop_blink


@.macro checkFlag fVal:req, fLoc:req
@.text
@ LDR \fVal, [\fLoc]
@	  CMP \fVal, #0x0
@	  BEQ _stop_blink
	@LDMFDEQ SP!, {R1-R7, PC}
@.endm



_blink_sequence:
.equ GPIO1_BASE,		  0x4804C000  @ GPIO1 				Base Address
.equ GPIO_CLEAR_DATA_OUT, 0x190 	  @ GPIO_CLEARDATAOUT 	register offset

.equ SET_ALL_LED_OUTPUT,   0xFE1FFFFF @ Mask to set LED[0-3] as outputs
.equ SET_ALL_LED, 0x01E00000		  @ Mask to set all LED's output
.equ SET_LED0,    0x00200000 		  @ Mask to set LED0
.equ SET_LED1,	  0x00400000		  @ Mask to set LED1
.equ SET_LED2,	  0x00800000		  @ Mask to set LED2
.equ SET_LED3,	  0x01000000	      @ Mask to set LED3

.equ HIGH, 		  0x1
.equ LOW,		  0x0

@ void GPIO_toggleLED(word setMask, bool output, word gpioBaseAddr)
setMask 	 .req R1
output  	 .req R2
gpioBaseAddr .req R3
setLedVal    .req R7
ledSetAddr   .req R8  @ passed from main
fValue	     .req R9
fAddr		 .req R10 @ passed from main

	STMFD SP!, {R1-R3, R7-R10, LR}	
	LDR gpioBaseAddr, =GPIO1_BASE

	@ Find which LED turns on next	
	LDR R7, [R8]	
	TST R7, #0x1 @ check LED0
	BNE LED0
	
	TST R7, #0x2 @ check LED1
	BNE LED1
	
	TST R7, #0x4 @ check LED2
	BNE LED2
	
	TST R7, #0x8 @ check LED3
	BNE LED3

LED0:	
	MOV R1, #SET_LED3
	MOV R2, #LOW
	BL _GPIO1_toggleLED 	@ toggle LED3 low
	
	MOV R1, #SET_LED0
	MOV R2, #HIGH
	BL _GPIO1_toggleLED 	@ toggle LED0 high
	
	@ Check interrupt flag
	LDR fValue, [fAddr]
	CMP fValue, #0x0
	BLEQ _stop_blink
	B BLINK_RETURN

LED1:	
	MOV R1, #SET_LED0
	MOV R2, #LOW
	BL _GPIO1_toggleLED	    @ toggle LED0 low
	
	MOV R1, #SET_LED1
	MOV R2, #HIGH			
	BL _GPIO1_toggleLED 	@ toggle LED1 high
	
	@ Check interrupt flag	
	LDR fValue, [fAddr]
	CMP fValue, #0x0
	BLEQ _stop_blink
	B BLINK_RETURN

LED2:
	MOV R1, #SET_LED1
	MOV R2, #LOW
	BL _GPIO1_toggleLED 	@ toggle LED1 low 
	
	MOV R1, #SET_LED2
	MOV R2, #HIGH
	BL _GPIO1_toggleLED 	@ toggle LED2 high
	
	@ Check interrupt flag	
	LDR fValue, [fAddr]
	CMP fValue, #0x0
	BLEQ _stop_blink
	B BLINK_RETURN
	
LED3:	
	MOV R1, #SET_LED2
	MOV R2, #LOW
	BL _GPIO1_toggleLED 	@ toggle LED2 low
	
	MOV R1, #SET_LED3
	MOV R2, #HIGH
	BL _GPIO1_toggleLED 	@ toggle LED3 high
	
	@ Check interrupt flag	
	LDR fValue, [fAddr]
	CMP fValue, #0x0
	BLEQ _stop_blink
	B BLINK_RETURN

BLINK_RETURN:	
	LDMFD SP!, {R1-R3, R7-R10, PC}
	
_stop_blink:
	STMFD SP!, {R1-R2, LR}
	LDR gpioBaseAddr, =GPIO1_BASE
	MOV R2, #SET_ALL_LED
	STR R2, [gpioBaseAddr, #GPIO_CLEAR_DATA_OUT]
	
	LDMFD SP!, {R1-R2, PC}
	
.end @@@ EOF @@@@