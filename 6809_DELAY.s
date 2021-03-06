;	Title:			Delay Milliseconds
;	Name:			DELAY
;	Purpose:		Delay from 1 to 256 milliseconds
;	Entry:			Register A = number of milliseconds to delay.
;				A = 0 equals 256 milliseconds
;	Exit:			Returns to calling routine after the specified delay.
;	Time:			1 millisecond * Register A
;	Size:			Program 54 bytes
;	Registers Used:		CC
;
;
;
; CYCLES PER MILLISECOND - USER SUPPLIED
;
CPMS	equ	1000		; 1000 = 1 MHZ CLOCK
				; 2000 = 2 MHZ CLOCK
MFAC	equ	CPMS/20		; MULTIPLYING FACTOR FOR ALL
				; EXCEPT LAST MILLISECOND
MFACM	equ	MFAC-4		; MULTIPLYING FACTOR FOR LAST
				; MILLISECOND
;
; METHOD:
;
; THE ROUTINE IS DIVIDED INTO 2 PARTS.
; THE CALL TO THE "DLY" ROUTINE DELAYS EXACTLY 1 LESS THAN THE
; NUMBER OF REQUIRED MILLISECONDS.
; THE LAST ITERATION TAKES INTO ACCOUNT
; THE OVERHEAD TO CALL "DELAY" AND "DLY
; THIS OVERHEAD IS 78 CYCLES.
;
DELAY:
	;
	; D0 ALL BUT THE LAST MILLISECOND
	;
	PSHS	D,X	 	; SAVE REGISTERS
	LDB	#MFAC		; GET MULTIPLYING FACTOR
	DECA			; REDUCE NUMBER OF MS BY 1 
	MUL			; MULTIPLY FACTOR TIMES MS
	TFR	D,Y		; TRANSFER LOOP COUNT TO X
	JSR	DLY
	;
	; ACCOUNT FOR 80 MS OVERHEAD DELAY BY REDUCING
	; LAST MILLISECOND'S COUNT
	;
	LDX	#MFAC			; GET REDUCED COUNT
	JSR	DLY			; DELAY LAST MILLISECOND
	PULS	D,X			; RESTORE REGISTERS
	RTS
	;
	; ***************************
	; ROUTINE:		DLY
	; PURPOSE:		DELAY ROUT1NE
	; ENTRY:		REGISTER X = COUNT
	; EXIT:			REGISTER X = 0
	; REGISTERS USED:	X
	; ****************************

DLY:	BRA	DLY1
DLY1:	BRA	DLY2
DLY2:	BRA	DLY3
DLY3:	BRA	DLY4
DLY4:	LEAX	-1,X
	BNE	DLY
	RTS
;
; SAMPLE EXECUTION:
;
SC8G:
	;
	; DELAY 10 SECONDS
	; CALL DELAY 40 TIMES AT 250 MILLISECONDS EACH
	;
	LDB	#40		; 40 TIMES (28 HEX)
QTRSCD:	LDA	#250		; 250 MILLISECONDS (FA HEX)
	JSR	DELAY
	DECB
	BNE	QTRSCD		; CONTINUE UNTIL DONE
	BRA	SC8G		; REPEAT OPERATION

END	PROGRAM

