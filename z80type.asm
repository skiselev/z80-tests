; Z80TYPE.ASM - DETERMINE AND PRINT Z80 CPU TYPE
; WRITTEN BY SERGEY KISELEV <SKISELEV@GMAIL.COM>
;
; RUNS ON CP/M SYSTEMS WITH ZILOG Z80
;   AND COMPATIBLE PROCESSORS
;	USES SIO INTERRUPT VECTOR REGISTER FOR TESTS
;
; BUILDING AND RUNNIG STEPS:
; A>ASM Z80TYPE
; A>LOAD Z80TYPE
; A>Z80TYPE

BDOS	EQU	5
WRSTR	EQU 9
; SIO CHANNEL B COMMAND PORT - RC2014/SC DEFAULT
SIOBC	EQU	82H

	ORG	0100H

	LXI	D,MSGSIGNIN
	MVI	C,WRSTR
	CALL BDOS

; CHECK FOR U880

	LXI H,0FFFFH
	LXI B,001FFH	; NOTE - WRITES FFH REGISTER
					; HOPEFULLY THERE IS NOTHING THERE...
	STC
	DB	0EDH,0A3H	; Z80 OUTI INSTRUCTION
	JNC Z80

; U880 DETECTED

	LXI	D,MSGU880
	MVI	C,WRSTR
	CALL BDOS
	JMP	CHKCMOS
	
Z80:
	LXI	D,MSGZ80
	MVI	C,WRSTR
	CALL BDOS

CHKCMOS:
; NMOS/CMOS CPU DETECTION ALGORITHM:
; 1. DISABLE INTERRUPTS
; 2. READ AND SAVE SIO CHANNEL B INTERRUPT VECTOR
; 3. MODIFY SIO CHANNEL B INTERRUPT VECTOR USING OUT (C),<0|0FFH>
;    (DB 0EDH, 071H) UNDOCMENTED INSTRUCTION:
;      ON AN NMOS CPU: OUT (C),0
;      ON A CMOS CPU: OUT (C),0FFH
; 4. READ AND SAVE SIO CHANNEL B INTERRUPT VECTOR
; 5. RESTORE SIO CHANNEL B INTERRUPT VECTOR
; 6. SET SIO REGISTER POINTER TO 0
; 7. ENABLE INTERRUPTS
; 8. CHECK THE VALUE READ BACK IN STEP 4
;      0 - NMOS CPU
;      0FFH - CMOS CPU
	DI
	MVI	A,02H		; SET SIO CHANNEL B REGISTER POINTER
					; TO REGISTER 2 - INTERRUPT VECTOR REGISTER
	OUT	SIOBC
	IN	SIOBC		; READ THE CURRENT INTERRUPT VECTOR
	MOV	B,A			; SAVE THE ORIGINAL VECTOR TO REGISTER B
	MVI	C,SIOBC
	DB	0EDH, 071H	; UNDOCUMENTED OUT (C),<0|0FFH> INSTRUCTION
					; WRITE 0 OR FF TO THE SIO INTERRUPT VECTOR
	MVI	A,02H		; SET SIO CHANNEL B REGISTER POINTER
					; TO REGISTER 2 - INTERRUPT VECTOR REGISTER
	OUT SIOBC
	IN	SIOBC		; READ THE NEW INTERRUPT VECTOR
	MOV	C,A			; SAVE THE NEW VECTOR TO REGISTER B
	MVI	A,02H		; SET SIO CHANNEL B REGISTER POINTER
					; TO REGISTER 2 - INTERRUPT VECTOR REGISTER
	OUT SIOBC
	MOV	A,B			; RESTORE THE ORIGINAL INTERRUPT VECTOR
	OUT	SIOBC		; WRITE IT TO THE SIO
	EI
	MOV	A,C			; VALUE WRITTEN BY OUT (C),<0|0FFH> INSTRUCTION
	CPI	00H			; IS IT ZERO
	JNZ	CMOS
	
; NMOS DETECTED

	LXI	D,MSGNMOS
	MVI	C,WRSTR
	CALL BDOS
	JMP	DONE

CMOS:
	
	LXI	D,MSGCMOS
	MVI	C,WRSTR
	CALL BDOS

DONE:
	LXI	D,MSGCRLF
	MVI	C,WRSTR
	CALL BDOS	

	RET			; RETURN TO CP/M


MSGSIGNIN:	DB	'Z80 Processor Type Detection (C) 2024 Sergey Kiselev',0DH,0AH
			DB	'Processor Type: $'
MSGU880:	DB	'U880 $'
MSGZ80:		DB	'Z80 $'
MSGNMOS:	DB	'NMOS$'
MSGCMOS:	DB	'CMOS$'
MSGCRLF:	DB	0DH,0AH,'$'

	END
