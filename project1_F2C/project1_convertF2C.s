@ Prodecure for converting a fahrenheit value to celcius

.text
.global _convertF2C

@ Passed values,
@ _convertF2C: R1 = Fahrenheit temp to convert to celcius

_convertF2C:
.equ subConst, 0x20		     @ sub value for F2C
	Ftemp 	   .req R1		 @ fahrenheit input
	subResult  .req R3		 @ Ftemp-subConst
	
	STMFD R13!, {R1-R4, R14} 	 @ Push, start function
	
	@ calculate C = ((F-32)(5))/9
	SUB subResult, Ftemp, #subConst
	MOV R4, #0x05
	MUL R1, subResult, R4
	MOV R2, #0x09
	BL _divWsub
	LDMFD R13!, {R1-R4, PC}  @ Pop, End function
.end