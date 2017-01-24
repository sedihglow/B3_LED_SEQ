@ File: project1_calcAvg.s
@ Procedure to calculate the average of an array.
@ Written by: James Ross

.text
.global _calcAvg

@ Passed inputs
@ _calcAvg: R1 - Array to average values from
@			R2 - Size of the array
_calcAvg:
	STMFD R13!, {R3-R5, R14} @ Push, start function
	
	toAvg 	 .req R1
	arrSize  .req R2
	index    .req R3	
	addTotal .req R4
	nextVal  .req R5

	MOV arrSize, #0x10
	MOV index, arrSize
	MOV addTotal, #0x00

ADD_ELEMENT_LOOP: @ WHILE (index=arrSize) > 0, add up array total
	LDRB nextVal, [toAvg], #0x01 	@ load next value
	ADD addTotal, addTotal, nextVal @ add to total
	SUBS index, #0x01
	
	BNE ADD_ELEMENT_LOOP

DIV_FOR_AVG: @ Calculate the average from addTotal and array size
	STMFD R13!, {R1-R2, R14} @ push R2 just in case called function changes R2.
	
	MOV R1, addTotal  		 @ Numerator
	MOV R2, arrSize	  		 @ Denominator
	B _divWsub 		  		 @ Divide to calculate average, in R0 to return

	LDMFD R13!, {R1-R5, PC}  @ Pop all pushed registers, End function
.end