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
WRCHR	EQU	2
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
	CALL	BDOS
	JMP	DONE
	
	; THE FOLLOWING TEST IS NOT RELEVANT TO NMOS CPUS

CMOS:
	
	LXI	D,MSGCMOS
	MVI	C,WRSTR
	CALL	BDOS

	DI
	LXI	D,2800H		; SET A REGISTER BITS 3 and 5
	PUSH	D
	POP	PSW			; MOVE TO A and FLAGS
	STC				; SET CARRY: FLAGS = FLAGS | 1
					; DEPENDING ON THE CPU TYPE THIS ALSO CHANGES BITS 3 AND 5:
					; ZILOG AND LICENCED CLONES: FLAGS = (FLAGS | A) & 28H
					; NEC (AND TOSHIBA?): FLAGS = FLAGS & A & 28H
					; TOSHIBA T9769C: FLAGS = (FLAGS & 28H) | (A & 8)
	PUSH	PSW
	POP	D			; NEW FLAGS IN D
	EI
	MOV	A,E			; FLAGS TO A
	CPI	29H			; FLAGS ON ZILOG CPU
	JZ	ZILOG
	CPI	09H			; FLAGS ON NEC AND TOSHIBA
	JZ	JAPAN

	MOV A,D
	CALL PRTHEX
	MOV A,E
	CALL PRTHEX

	LXI D,MSGUNKNOWN
	MVI	C,WRSTR
	CALL BDOS
	JMP DONE
		
ZILOG:

	LXI	D,MSGZILOG
	MVI	C,WRSTR
	CALL BDOS
	JMP DONE

JAPAN:

	LXI	D,MSGJAPAN
	MVI	C,WRSTR
	CALL BDOS
	
DONE:
	LXI	D,MSGCRLF
	MVI	C,WRSTR
	CALL BDOS	

	RET			; RETURN TO CP/M

PRTHEX:
	PUSH	D
	MOV D,A
	RRC
	RRC
	RRC
	RRC
	ANI	0FH			; ISOLATE HIGH 4 BITS
	ADI	'0'			; TO ASCII
	CPI	'9'
	JC	PRINTHI
	ADI	'A'-'9'-1
	
PRINTHI:
	MOV	E,A
	MVI	C,WRCHR
	PUSH	D
	CALL	BDOS
	POP		D
	MOV	A,D			; D CONTAINS THE VALUE TO PRINT
	ANI	0FH
	ADI	'0'			; TO ASCII
	CPI	'9'
	JC	PRINTLO
	ADI	'A'-'0'
	
PRINTLO:
	MOV	E,A
	MVI	C,WRCHR
	PUSH	D
	CALL	BDOS
	POP		D
	POP		D
	RET

MSGSIGNIN:	DB	'Z80 Processor Type Detection (C) 2024 Sergey Kiselev',0DH,0AH
			DB	'Processor Type: $'
MSGU880:	DB	'U880 $'
MSGZ80:		DB	'Z80 $'
MSGNMOS:	DB	'NMOS$'
MSGCMOS:	DB	'CMOS $'
MSGZILOG:	DB	'Zilog or SGS/ST$'
MSGJAPAN:	DB	'NEC or Toshiba$'
MSGUNKNOWN:	DB	' Unknown$'
MSGCRLF:	DB	0DH,0AH,'$'

	END
