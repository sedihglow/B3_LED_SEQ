@ Filename: project2_P3_main.s
@ This program will utilize the USER LED's to blink in a specified pattern
@
@ GPIO banks and pins used:
@ GPIO1 base address = 0x4804C000 | end address = 0x4804CFFF
@ GPIO1_21 = LED 0  | proc pin = V15
@ GPIO1_22 = LED 1  | proc pin = U15
@ GPIO1_23 = LED 2  | proc pin = T15
@ GPIO1_24 = LED 3  | proc pin = V16
@ GOIO1_31 = BUTTON | 
@ 
@ Cycle through the LED's, blinking each one for 1second a piece, rotating
@ through LED[0-3] when a button is pressed.
@
@ Interupt address information:
@
@ Board: Beagle Bone Black
@ Written by: James Ross

.text
.global _start
_start:
@ CLK definitions
.equ GPIO1_CLK_ENABLE,     0x00000002 @ Enable GPIO1 clk at CM_PER_GPIO_CLKCTRL
.equ GPIO1_CLK_CTRL,       0x44E000AC @ CM_PER_GPIO1_CLKCTRL  register address
.equ TIMER3_CLK_CTRL,	   0x44E00084 @ CM_PER_TIMER3_CLKCTRL register address
.equ TIMER3_CLKSEL,		   0x44E0050C @ CLKSEL_TIMER3_CLK 	  register address

@ GPIO definitions
.equ GPIO1_BASE,		  0x4804C000  @ GPIO1 				Base Address
.equ GPIO_OE, 			  0x134 	  @ GPIO_OE 		    register offset
.equ GPIO_CLEAR_DATA_OUT, 0x190 	  @ GPIO_CLEARDATAOUT 	register offset
.equ GPIO_SET_DATA_OUT,   0x194 	  @ GPIO_SETDATAOUT 	register offset
.equ GPIO_FALLING_DETECT, 0x14C	  	  @ GPIO_FALLINGDETECT 	register offset
.equ GPIO_IRQ_STAT_0,	  0x2C	  	  @ GPIO_IRQSTATUS_0 	register offset
.equ GPIO_IRQ_STAT_SET_0, 0x34 	      @ GPIO_IRQSTAT_SET_0  register offset

@ Interupt definitions
.equ INTC_BASE,			  0x48200000  @ INCPS 				Base Address
.equ INTC_CONTROL,		  0x48		  @ INTC_CONTROL		register offset
.equ INTC_CONFIG,		  0x10		  @ INTC_SYSCONFIG		register offset
.equ INTC_MIR_CLEAR2,	  0xC8		  @ INTC_MIR_CLEAR2     register offset
.equ INTC_MIR_CLEAR3,	  0xE8		  @ INTC_MIR_CLEAR3 	register offset
.equ INTC_MIR_SET3,		  0xEC		  @ INTC_MIR_SET3 		register offset
.equ INTC_PENDING_IRQ3,	  0xF8		  @ INTC_PENDING_IRQ3	register offset
.equ GPIOINT1A, 		  0x4		  @ GPIOINT1A in MIR3   Mask
.equ TINT3, 		   	  0x20		  @ TINT3 in MIR2       Mask

@ Timer defintions
.equ TIMER3_BASE,		  0x48042000  @ DMTIMER3			Base Address
.equ TIOCP_CFG,			  0x10		  @ TIOCP_CFG			register offset
.equ IRQ_ENABLE_SET,	  0x2C		  @ IRQENABLE_SET		register offset
.equ TCLR,				  0x38		  @ TCLR				register offset
.equ TCRR,				  0x3C		  @ TCRR				register offset
.equ TLDR,				  0x40		  @ TLDR				register offset
.equ TIMER_COUNTER_VAL,   0xFFFF80FF  @ Loaded into TLDR and TCRR, 1.00793s

@ LED definitions
.equ SET_ALL_LED_OUTPUT,   0xFE1FFFFF @ Mask to set LED[0-3] as outputs
.equ SET_ALL_LED, 		   0x01E00000 @ Mask to set all LED's output

@ Register assignments
gpio1_baseAddr  .req R3
intc_baseAddr   .req R5
timer3_baseAddr .req R6
ledToSet		.req R8   @ ADDR
bValue 		    .req R9	  @ blinkFlag value
bFlag  			.req R10  @ blinkFlag address
temp1  			.req R11  @ scratch register 1
temp2  			.req R12  @ screach register 2
stack  			.req R13

INIT_STACKS:
	LDR stack,=SVC_STACK	   
	ADD stack, stack, #0x1000 @ Point to top of stack
	CPS #0x12				  @ Switch to IRQ mode
	
	LDR stack,=IRQ_STACK		
	ADD stack, stack, #0x1000 @ Point to top of stack
	CPS #0x13				  @ Switch to SVC mode
	
INIT_GPIO:
	@ Set clock to GPIO1 as enabled
	MOV temp1, #GPIO1_CLK_ENABLE
	LDR temp2, =GPIO1_CLK_CTRL
	STR temp1, [temp2]

	@ Set GPIO1_[21-24] as outputs, desired initial output is 0
	LDR gpio1_baseAddr, =GPIO1_BASE
	
	MOV temp2, #SET_ALL_LED
	STR temp2, [gpio1_baseAddr, #GPIO_CLEAR_DATA_OUT]

	@ Enable GPIO1_[21-24]
	ADD temp1, gpio1_baseAddr, #GPIO_OE
	MOV temp2, #SET_ALL_LED_OUTPUT
	LDR R4, [temp1]     @ Load
	AND R4, R4, temp2	@ Modify to enable LED[0-3] as outputs
	STR R4, [temp1]		@ Store

INIT_INT:
	@ Set interupt to trigger when falling from high to low
	ADD temp1, gpio1_baseAddr, #GPIO_FALLING_DETECT
	MOV temp2, #0x80000000 	@ Set bit/pin 31 mask
	LDR R4, [temp1]
	ORR R4, R4, temp2
	STR R4, [temp1]			@ Store GPIO1_31 as falling detect

	@ Enable interrupt field for GPIO1_31
	STR temp2, [gpio1_baseAddr, #GPIO_IRQ_STAT_SET_0]
	
	@ Initialize INTC
	LDR intc_baseAddr,=INTC_BASE
	
	@ INTC for timer
	MOV temp1, #0x2  @ Value to reset INTC
	STR temp2, [intc_baseAddr, #INTC_CONFIG] @ Softreset INTC table
	MOV temp1, #TINT3
	STR temp1, [intc_baseAddr, #INTC_MIR_CLEAR2]
	
	@ INTC for button press
	MOV temp2, #GPIOINT1A			@ 0x4 in MIR3 holds GPIOINT1A POINTRPEND1
	STR temp2, [intc_baseAddr, #INTC_MIR_CLEAR3]
	
INIT_TIMER:
	@ Turn on timer3 clock
    MOV temp1, #0x2 @ Value to enable timer3 clk and 32khz mux select
	LDR temp2, =TIMER3_CLK_CTRL
	STR temp1, [temp2]
	
	
	@ Set PCRMCLKSEL_TIMER3 so the mux pulls from the 32khz clock
	LDR temp2, =TIMER3_CLKSEL
	STR temp1, [temp2]

	LDR timer3_baseAddr, =TIMER3_BASE
	
	@ Turn off timer in-case state of beagle bone has it enabled
	MOV R1, #0x38 	  @ reset TCLR
	STR R1, [timer3_baseAddr, #TCLR] @ Set the TCLR
	
	@ Initialize timer3 registers. set count and overflow INT generation	
	MOV temp1, #0x1 @ value for software reset in TIOCP_CFG
	STR temp1, [timer3_baseAddr, #TIOCP_CFG]

    @ Enable overflow interrupt
	MOV temp1, #0x2
	STR temp1, [timer3_baseAddr, #IRQ_ENABLE_SET]
	
	@ Set count value in TLDR and TCRR
	LDR temp1, =TIMER_COUNTER_VAL
	STR temp1, [timer3_baseAddr, #TLDR]
	STR temp1, [timer3_baseAddr, #TCRR]

	LDR bFlag, =blinkFlag  @ Load pointer for flag
	LDR ledToSet, =ledFlag @ load pointer for which LED is to be adjusted
	MOV temp1, #0x0
	STR temp1, [bFlag]
	STR temp1, [ledToSet]
	
	@ Enable IRQ in CPSR
	MRS temp1, CPSR
	BIC temp1, #0x80
	MSR CPSR_c, temp1

WAIT_LOOP: @ Wait for interupt by button press and execute proper code
	LDR bValue, [bFlag]
	CMP bValue, #0x0
	BLEQ _stop_blink
	BLNE _blink_sequence
	B WAIT_LOOP	

.data
.align 2
	blinkFlag: .word 0x0
	ledFlag:   .word 0x0

.align 2
	SVC_STACK:
		.rept 1024
			.word 0x0000
		.endr
	IRQ_STACK:
		.rept 1024
			.word 0x0000
		.endr
.end