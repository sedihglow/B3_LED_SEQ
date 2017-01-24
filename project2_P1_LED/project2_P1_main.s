@ Filename: project2_P1_main.s
@ This program will utilize the USER LED's to blink in a specified pattern
@
@ GPIO banks and pins used:
@ GPIO1 base address = 0x4804 | end address = 0x4804CFFF
@ GPIO1_21 = LED 0 | proc pin = V15
@ GPIO1_22 = LED 1 | proc pin = U15
@ GPIO1_23 = LED 2 | proc pin = T15
@ GPIO1_24 = LED 3 | proc pin = V16
@ 
@ Cycle through the LED's, blinking each one for 1second a piece, rotating
@ through LED[0-3].
@ Board: Beagle Bone Black
@ Written by: James Ross


.text
.global _start
_start:
.equ GPIO1_CLK_CTRL,       0x44E000AC @ CM_PER_GPIO1_CLKCTRL register address
.equ GPIO1_CLK_ENABLE,     0x00000002 @ Enable GPIO1 clk at CM_PER_GPIO_CLKCTRL
.equ GPIO1_OE, 			   0x134 	  @ GPIO_OE register offset
.equ GPIO1_CLEAR_DATA_OUT, 0x190 	  @ GPIO_CLEARDATAOUT register offset
.equ GPIO1_SET_DATA_OUT,   0x194 	  @ GPIO_SETDATAOUT register offset
.equ GPIO1_BASE,		   0x4804C000 @ GPIO1 base address

.equ SET_ALL_LED_OUTPUT,   0xFE1FFFFF @ Mask to set LED[0-3] as outputs


.equ SET_ALL_LED, 0x01E00000		  @ Mask to set all LED's output
.equ SET_LED0,    0x00200000 		  @ Mask to set LED0
.equ SET_LED1,	  0x00400000		  @ Mask to set LED1
.equ SET_LED2,	  0x00800000		  @ Mask to set LED2
.equ SET_LED3,	  0x01000000	      @ Mask to set LED3

.equ HIGH, 		  0x1
.equ LOW,		  0x0

gpio1_baseAddr .req R3
temp1 .req R11 @ scratch register 1
temp2 .req R12 @ screach register 2
stack .req R13


	LDR stack,=STACK	    	@ stack pointer
	ADD stack, stack, #0x100	@ Point to top of stack, 256 = 0x100
	
INIT_GPIO:
	@ Set clock to GPIO1 as enabled
	MOV temp1, #GPIO1_CLK_ENABLE
	LDR temp2, =GPIO1_CLK_CTRL
	STR temp1, [temp2]

	@ Set GPIO1_[21-24] as outputs, desired initial output is 0
	LDR gpio1_baseAddr, =GPIO1_BASE
	
	ADD temp1, gpio1_baseAddr, #GPIO1_CLEAR_DATA_OUT
	MOV temp2, #SET_ALL_LED
	STR temp2, [temp1]

	@ Enable GPIO1_[21-24]
	ADD temp1, gpio1_baseAddr, #GPIO1_OE
	MOV temp2, #SET_ALL_LED_OUTPUT
	LDR R4, [temp1]     @ Load
	AND R4, R4, temp2	@ Modify to enable LED[0-3] as outputs
	STR R4, [temp1]		@ Store

BLINK_LOOP:
	
	MOV R1, #SET_LED0
	MOV R2, #HIGH
	BL _GPIO1_toggleLED 	@ toggle LED0 high
	
	BL _delaySecond

	MOV R2, #LOW
	BL _GPIO1_toggleLED	    @ toggle LED0 low

	
	MOV R1, #SET_LED1
	MOV R2, #HIGH			
	BL _GPIO1_toggleLED 	@ toggle LED1 high
	
	BL _delaySecond
	
	MOV R1, #SET_LED1
	MOV R2, #LOW
	BL _GPIO1_toggleLED 	@ toggle LED1 low 
	
	MOV R1, #SET_LED2
	MOV R2, #HIGH
	BL _GPIO1_toggleLED 	@ toggle LED2 high
	
	BL _delaySecond
	
	MOV R1, #SET_LED2
	MOV R2, #LOW
	BL _GPIO1_toggleLED 	@ toggle LED2 low
	
	
	MOV R1, #SET_LED3
	MOV R2, #HIGH
	BL _GPIO1_toggleLED 	@ toggle LED3 high
	
	BL _delaySecond
	
	MOV R1, #SET_LED3
	MOV R2, #LOW
	BL _GPIO1_toggleLED 	@ toggle LED3 low
	
	B BLINK_LOOP
.data
	STACK:
		.rept 256
			.byte 0x00
		.endr
.end