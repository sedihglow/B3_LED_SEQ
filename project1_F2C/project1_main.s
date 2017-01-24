@ File: project1_main.s
@ This program will take an array of fahrenheight values and convert them to
@ celcius, then find the average temperature for both F and C utilizing division
@ by subtraction.
@ Written by: James Ross

.text
.global _start
_start:
.equ arrSize, 0x10
	stack     .req R13
	fahTemps  .req R5
	celcTemps .req R6
	Cavg 	  .req R7
	Favg 	  .req R8
	index	  .req R9
	
	LDR stack,=STACK	    	@ stack pointer
	ADD stack, stack, #0x100	@ Point to top of stack, 256 = 0x100
	LDR fahTemps, =FAH_TEMPS	@ Fahrenheight array, 16 bytes
	LDR celcTemps, =CELC_TEMPS  @ Celcius array, 16 bytes
	LDR Cavg, =C_AVG			@ Celcius average pntr
	LDR Favg, =F_AVG			@ Fahrenheigh pntr

	MOV index, #0
F2C_LOOP: 						 @ Convert each F temp to C
	CMP index, #arrSize 		 @ WHILE index < arrSize
	BEQ FIND_AVG 	   			 @ IF index == arrSize, break
	LDRB R1, [fahTemps], #0x01   @ ELSE, Load value
	BL _convertF2C				 @ convert to C
	ADD index, index, #0x01
	STRB R0, [celcTemps], #0x01  @ store result
	B F2C_LOOP

FIND_AVG:
	@ Find and store Fahrenheit average
	LDR R1, =FAH_TEMPS
	MOV R2, #arrSize
	BL _calcAvg
	STRH R0, [Favg]
	MOV R1, R0
	@ Convert Fahrenheit average for Celcius average and store
	BL _convertF2C
	STRH R0, [Cavg]
	NOP
.data
	STACK:
		.rept 256
			.byte 0x00
		.endr
	FAH_TEMPS: 
			.byte 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 100, 105, 106, 107, 125
	CELC_TEMPS:
			.rept 16
				.byte 0x00
			.endr
	C_AVG: .hword 0x00
	F_AVG: .hword 0x00	
	
.end
