	.macro	CLC
		ANDCC	#$FE
	.endm
	.macro	SEC
		ORCC	#1
	.endm

;	Title:			Singly Linked List Manager
;
;	Name:
;
;	Purpose:		This program consists of two subroutines 
;				that manage a singly linked list.
;
;				INLST inserts an element into the linked list.
;				RMLST removes an element from the linked list.
;
;	Entry:
;				INLST
;					TOP OF STACK 
;					High byte of return address
;					Low  byte of return address 
;					High byte of previous element's address 
;					Low  byte of previous element's address 
;					High byte of entry address
;
;					Low  byte of entry address
;				RMLST
;					Base address of preceding element in register X
;
;	Exit:
;				INLST
;				RMLST
;				INLST	Element added to list
;				RMLST	If following element exists,
;						its base address is in register X
;						Carry = 0
;					else
;						register X = 0
;						Carry = 1
;
;	Registers Used:
;				INLST	All
;				RMLST	CC,D,U,X
;
;	Time:
;				INLST	29 cycles 
;				RMLST	35 cycles
;
;	Size:
;				Program 25 bytes
;
;	INSERT AN ELEMENT INTO A SINGLY LINKED LIST
;
INLST:
	;
	; UPDATE LINKS TO INCLUDE NEW ELEMENT
	; LINK PREVIOUS ELEMENT TO NEW ELEMENT
	; LINK NEW ELEMENT TO ELEMENT FORMERLY LINKED TO
	; PREVIOUS ELEMENT
	;
	PULS	X,Y,U		; GET ELEMENTS, RETURN ADDRESS 
	LDD	,Y		; GET LINK FROM PREVIOUS ELEMENT 
	STD	,U		; STORE LINK IN NEW ELEMENT
	STU	,Y		; STORE NEW ELEMENT AS LINK IN
				; PREVIOUS ELEMENT
;
; NOTE:
;	IF LINKS ARE NOT IN FIRST TWO BYTES OF ELEMENTS,
;	PUT LINK OFFSET IN LAST 3 INSTRUCTIONS
	;
	; EXIT
	;
	JMP	,X		; EXIT TO RETURN ADDRESS
;
; REMOVE AN ELEMENT FROM A SINGLY LINKED LIST
;
RMLST:
	;
	; EXIT INDICATING FAILURE (CARRY SET) IF NO FOLLOWING ELEMENT
	;
	LDU	,X		; GET LINK TO FOLLOWING ELEMENT
	SEC			; INDICATE NO ELEMENT FOUND
	BEQ	RMEXIT		; BRANCH IF NO ELEMENT FOUND
	;
	; UNLINK REMOVED ELEMENT BY TRANSFERRING ITS LINK TO
	; PREVIOUS ELEMENT
	; NOTE:			IF LINKS NOT IN FIRST TWO BYTES OF ELEMENTS, 
	;			PUT LINK OFFSET IN STATEMENTS
	;
	LDD	,U		; GET LINK FROM REMOVED ELEMENT
	STD	,X		; MOVE IT TO PREVIOUS ELEMENT
	CLC			; INDICATE ELEMENT FOUND
;
; EXIT
;
RMEXIT:
	TFR	U,X		; EXIT WITH BASE ADDRESS OF REMOVED
				; ELEMENT OR D IN X
	RTS			; CARRY = 0 IF ELEMENT FOUND,
				;	 1 IF NOT
;
;	SAMPLE EXECUTION
;
SC7C:
	;
	;	INITIALIZE EMPTY LINKED LIST
	;
	LDD	#0		; CLEAR LINKED LIST HEADER
	STD	LLHDR		; 0 INDICATES NO NEXT ELEMENT
	;
	; INSERT AN ELEMENT INTO LINKED LIST
	;
	LDY	#ELEM1		; GET BASE ADDRESS OF ELEMENT 1
	LDX	#LLHDR		; GET PREVIOUS ELEMENT (HEADER)
	PSHS	X,Y		; SAVE PARAMETERS IN STACK
	JSR	INLST		; INSERT ELEMENT INTO LIST
	;
	; INSERT ANOTHER ELEMENT INTO LINKED LIST
	;
	LDY	#ELEM2		; GET BASE ADDRESS 0F ELEMENT 2
	LDX	#ELEM1		; GET PREVIOUS ELEMENT
	PSHS	X,Y		; SAVE PARAMETERS IN STACK
	JSR	INLST		; INSERT ELEMENT INTO YLIST
	;
	; REMOVE FIRST ELEMENT FROM LINKED LIST
	;
	LDX	#LLHDR		; GET PREVIOUS ELEMENT
	JSR	RMLST		; REMOVE ELEMENT FROM LIST
				; END UP WITH HEADER LINKED T0
				; SECOND ELEMENT
				; X CONTAINS BASE ADDRESS OF
				; FIRST ELEMENT
	BRA	SC7C		; REPEAT TEST
;
;	DATA
;
LLHDR	RMB	2		; LINKED LIST HEADER
ELEM1	RMB	2		; ELEMENT 1 HEADER (LINK) ONLY
ELEM2	RMB	2		; ELEMENT 2 HEADER (LINK) ONLY

	END

