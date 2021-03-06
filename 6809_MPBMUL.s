	.macro	CLC
		ANDCC	#$FE
	.endm
	.macro	SEC
		ORCC	#1
	.endm

; Title:		Multiple-Precision Binary Multiplication
;
; Name:			MPBMUL
;
; Purpose:		Multiply 2 arrays of binary bytes
;
;	Entry:
;
;				TOP OF STACK 
;				High byte of return address 
;				Low  byte of return address 
;				Length of the arrays in bytes
;				High byte of multiplicand address
;				Low  byte of multiplicand address
;				High byte of multiplier address
;				Low  byte of multiplier address
;
;				The arrays are unsigned binary numbers
;				with a maximum length of 255 bytes,
;				ARRAY[0] is the Least significant byte, and 
;				ARRAY[LENGTH-1] is the most significant byte.
;
;	Exit:
;
;				Multiplicand := Multiplicand * Multiplier
;
;	Registers Used:		All
;
;	Time:			Assuming all multiplicand bytes are non-zero, 
;				then the time is approximately:
;				(90 * length^2) + (90 * length) = 39 cycles
;	Size			Program		 96 bytes
;				Data		256 bytes plus 2 stack bytes
;
MPBMUL:
;
;	CHECK LENGTH OF OPERANDS
;	EXIT IF LENGTH IS ZERO
;	SAVE LENGTH FOR USE AS LOOP COUNTER
;
	LDB	2,S		; GET ARRAY LENGTH
	BEQ	EXITML		; EXIT (RETURN) IF LENGTH IS ZERO
	PSHS	B		; SAVE LENGTH AS MULTIPLICAND BYTE COUNTER
	LEAS	-1,S		; RESERVE SPACE FOR MULTIPLICAND BYTE
;
; CLEAR PARTIAL PRODUCT AREA
; (OPERAND LENGTH PLUS 1 BYTE FOR OVERFLOW)
;
	LDX	#PPROD		; POINT TO PARTIAL PRODUCT AREA
	CLRA			; GET ZERO FOR CLEARING
CLRPRD:
	STA	,X+		; CLEAR BYTE OF PARTIAL PRODUCT
	DECB
	BNE	CLRPRD		; CONTINUE UNTIL ALL BYTES CLEARED
;
; LOOP OVER ALL MULTIPLICAND BYTES
; MULTIPLYING EACH ONE BY ALL MULTIPLIER BYTES
;
PROCBT:
	LDU	5,S		; POINT TO MULTIPLICAND
	LDA	,U		; GET NEXT BYTE OF MULTIPLICAND
	STA	,S		; SAVE NEXT BYTE OF MULTIPLICAND
	BEQ	MOVBYT		; SKIP MULTIPLICATION IF BYTE IS ZERO
;
; MULTIPLY BYTE OF MULTIPLICAND TIMES EACH BYTE OF MULTIPLIER
;
MULSTP:
	LDB	4,S		; GET LENGTH OF OPERANDS IN BYTES
	CLRA			; SAVE AS LOOP COUNTER
	TFR	D,U		; IN REGISTER U
	LDY	#PPROD		; POINT TO PARTIAL PRODUCT
	LDX	7,S		; POINT TO MULTIPLIER
MULLUP:
	LDA	,X+		; GET NEXT BYTE OF MULTIPLIER
	LDB	,S		; GET CURRENT BYTE OF MULTIPLICAND
	MUL			; MULTIPLY
	ADDB	,Y		; ADD RESULT TO PREVIOUS PRODUCT
	STB	,Y+
	ADCA	,Y
	STA	,Y
	BCC	DECCTR		; BRANCH IF ADDITION DOES NOT PRODUCE CARRY 
	CLRA			; OTHERWISE, RIPPLE CARRY
OVRFL:
	INCA			; MOVE ON TO NEXT BYTE
	INC	A,Y		; INCREMENT NEXT BYTE
	BEQ	OVRFL		; BRANCH IF CARRY KEEPS RIPPLING
DECCTR:
	LEAU	-1,U		; DECREMENT BYTE COUNT
	BNE	MULLUP		; LOOP UNTIL MULTIPLICATION DONE
;
; MOVE LOW BYTE OF PARTIAL PRODUCT INTO RESULT AREA
; THIS OVERWRITES THE MULTIPLICAND BYTE USED IN THE 
; LATEST MULTIPLICATION LOOP
;
MOVBYT:
	LDX	5,S		; POINT TO MULTIPLICAND AND RESULT
	LDY	#PPROD		; POINT TO PARTIAL PRODUCT AREA
	LDB	,Y		; GET BYTE OF PARTIAL PRODUCT
	STB	,X+		; STORE IN ORIGINAL MULTIPLICAND
	STX	5,S		; SAVE UPDATED MULTIPLICAND POINTER
;
; SHIFT PARTIAL PRODUCT RIGHT ONE BYTE
;
	LDB	4,S		; GET LENGTH OF OPERANDS IN BYTES
SHFTRT:
	LDA	1,Y		; GET NEXT BYTE OF PARTIAL PRODUCT
	STA	,Y+		; MOVE BYTE RIGHT
	DECB			; DECREMENT BYTE COUNT
	BNE	SHFTRT		; CONTINUE UNTIL ALL BYTES SHIFTED
	CLR	,Y		; CLEAR OVERFLOW
;
; COUNT MULTIPLICAND DIGITS
;
	DEC	1,S		; DECREMENT DIGIT COUNTER 
	BNE	PROCBT		; CONTINUE THROUGH ALL MULTIPLICAND DIGITS
	LEAS	2,S		; REMOVE TEMPORARIES FROM STACK
;
; REMOVE PARAMETERS FROM STACK AND EXIT
;
EXITML:
	LDU	,S		; SAVE RETURN ADDRESS
	LEAS	7,S		; REMOVE PARAMETERS FROM STACK
	JMP	,U		; EXIT TO RETURN ADDRESS
;
; DATA
;
PPROD:	RMB	256		;PARTIAL PRODUCT BUFFER WITH OVERFLOW BYTE
;
;
; SAMPLE EXECUTION
;  
;	
SC3D:		
	LDX	AY1ADR		; GET MULTIPLICAND
	LDY	AY2ADR		; GET MULTIPLIER
	LDA	#SZAYS		; LENGTH OF OPERANDS IN BYTES
	PSHS	A,X,Y		; SAVE PARAMETERS IN STACK
	JSR	MPBMUL		; MULTIPLE-PRECISION BINARY MULTIPLICATION
				; RESULT OF 12345H * 1234H = 14B60404H
				; IN MEMORY
				; AY1   = 04H
				; AY1+1 = 04H
				; AY1+2 = B6H
				; AY1+3 = 14H
				; AY1+4 = 00H
				; AY1+5 = 00H
				; AY1+6 = 00H
				;
	BRA	SC3D		; CONTINUE
;
; DATA
;
SZAYS	EQU	7		; LENGTH OF OPERANDS IN BYTES
AY1ADR	FDB	AY1		; BASE ADDRESS OF ARRAY 1
AY2ADR	FDB	AY2		; BASE ADDRESS OF ARRAY 2
AY1:	FCB	$45,$23,$01,0,0,0,0
AY2:	FCB	$34,$12,0,0,0,0,0
	END

