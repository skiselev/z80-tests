; Z80TYPE.ASM - DETERMINE AND PRINT Z80 CPU TYPE
; WRITTEN BY SERGEY KISELEV <SKISELEV@GMAIL.COM>
;
; RUNS ON CP/M SYSTEMS WITH ZILOG Z80 AND COMPATIBLE PROCESSORS
; USES SIO INTERRUPT VECTOR REGISTER FOR TESTS
;
; BUILDING AND RUNNIG STEPS:
; A>ASM Z80TYPE
; A>LOAD Z80TYPE
; A>Z80TYPE

BDOS	EQU	5
WRCHR	EQU	2
WRSTR	EQU	9
CMDLINE	EQU	80H		; CP/M command line offset
; SIO CHANNEL B COMMAND PORT - RC2014/SC DEFAULT
SIOBC	EQU	82H

	ORG	0100H

	LXI	D,MSGSIGNIN
	CALL	PRINTSTR
	
	LXI	H,CMDLINE
	MOV	A,M		; get the number of characters
	CPI	0
	JZ	NOARGS

ARGS1:
	INX	H
	MOV	A,M
	CPI	20H
	JNZ	ARGS2
	DCR	C
	JNZ	ARGS1

ARGS2:
	CPI	'/'
	JNZ	ARGSERR
	INX	H
	DCR	C
	JZ	ARGSERR
	MOV	A,M
	CPI	'D'
	JZ	ARGDEBUG
	JMP	ARGSERR
	
ARGSERR:
	LXI	D,MSGUSAGE
	CALL	PRINTSTR
	RET

ARGDEBUG:
	MVI	A,1
	LXI	H,DEBUG
	MOV	M,A
	
NOARGS:
	CALL	TESTCMOS
	LXI	H,ISCMOS
	MOV	M,A		; store result to ISCMOS
		
	CALL	TESTU880
	LXI	H,ISU880
	MOV	M,A		; store result to ISU880
	
	CALL	TESTXY
	LXI	H,XYRESULT
	MOV	M,A

;-------------------------------------------------------------------------
; Debug
	LXI	H,DEBUG
	MOV	A,M
	CPI	0
	JZ	DETECTCPU
	

	LXI	H,ISCMOS
	MOV	A,M
	LXI	D,MSGRAWCMOS	; display CMOS test result
	CALL	PRINTSTR
	CALL	PRINTHEX
	
	LXI	H,ISU880
	MOV	A,M		; store result to ISU880	
	LXI	D,MSGRAWU880	; display U880 test result
	CALL	PRINTSTR
	CALL	PRINTHEX

	LXI	H,XYRESULT
	MOV	A,M
	LXI	D,MSGRAWXY	; display XF/YF flags test result
	CALL	PRINTSTR
	CALL	PRINTHEX

	LXI	D,MSGCRLF
	CALL	PRINTSTR
	
	CALL	TESTFLAGS	; TEST HOW FLAGS SCF AFFECTS FLAGS

;-------------------------------------------------------------------------
; CPU detection logic
DETECTCPU:

	LXI	D,MSGCPUTYPE
	CALL	PRINTSTR

; check for U880 CPU

	LXI	H,ISU880
	MOV	A,M
	CPI	0		; Is it a U880?
	JZ	CHECKZ80	; check Z80 flavor
	
	LXI	H,XYRESULT
	MOV	A,M
	CPI	0FFH		; does it always set XF/YF?
	LXI	D,MSGU880NEW
	JZ	DONE		; jump if a new U880/Thesys Z80
	LXI	D,MSGU880OLD
	JMP	DONE

; check for Z80 type
CHECKZ80:

	LXI	H,ISCMOS
	MOV	A,M
	CPI	0		; Is it a NMOS CPU?
	JNZ	CHECKCMOS	; check CMOS Z80 flavor

; check for Sharp LH5080A
	LXI	H,XYRESULT
	MOV	A,M
	CPI	30H
	JZ	SHARPLH5080A
	CPI	0FFH		; does it always set XF/YF?
	JZ	NMOSZ80
	CPI	0FDH		; does it sometimes not set XF when FLAGS.3=1?
	JZ	NECU780C
	CPI	0F0H
	JZ	NECU780C1
	CPI	0F4H
	JZ	KR1858VM1
	LXI	D,MSGNMOSUNKNOWN
	JMP	DONE

SHARPLH5080A:
	LXI	D,MSGSHARPLH5080A
	JMP	DONE
	
NMOSZ80:
	LXI	D,MSGNMOSZ80
	JMP	DONE
	
NECU780C:
	LXI	D,MSGNECD780C
	JMP	DONE

NECU780C1:
        LXI     D,MSGNECD780C1
        JMP     DONE

KR1858VM1:
	LXI	D,MSGKR1858VM1
	JMP	DONE

CHECKCMOS:
	LXI	H,XYRESULT
	MOV	A,M
	CPI	0FFH		; does it always set XF/YF?
	JZ	CMOSZ80
	CPI	3FH		; does it never set YF when A.5=1?
	JZ	TOSHIBA

; test for NEC D70008AC. These CPUs seem to behave as following:
; A.5=1 & F.5=0 => YF=1
; A.3=1 & F.3=0 => XF is not set at all, or only sometimes is set
; A.5=0 & F.5=1 => YF is sometimes set
; A.3=0 & F.3=1 => XF is sometimes set
; Note: All of 3 D70008AC that I have behave a bit differently here
;       this might need to be updated when more tests are done
	CPI	20H		; YF is often set when A.5=1?
	JNC	CMOSUNKNOWN	; XYRESULT > 1Fh, not a NEC...
	ANI	0FH		; F.5=1 & A.5=0 and F.3=1 & A.3=0 results
	CPI	03H		; F.5=1 & A.5=0 never result in YF set?
	JC	CMOSUNKNOWN
	ANI	03H		; F.3=1 & A.3=0 results
	JNZ	NEC

CMOSUNKNOWN:	
	LXI	D,MSGCMOSUNKNOWN
	JMP	DONE
	
CMOSZ80:
	LXI	D,MSGCMOSZ80
	JMP	DONE

TOSHIBA:
	LXI	D,MSGTOSHIBA
	JMP	DONE

NEC:
	LXI	D,MSGNECD70008AC
	JMP	DONE

DONE:
	CALL	PRINTSTR
	LXI	D,MSGCRLF
	CALL	PRINTSTR
	RET			; RETURN TO CP/M
	
;-------------------------------------------------------------------------
; TESTCMOS - Test if the CPU is a CMOS variety according to OUT (C),0 test
; Note: CMOS Sharp LH5080A is reported as NMOS
; Input:
;	None
; Output:
;	A = 00 - NMOS
;	A = FF - CMOS
;------------------------------------------------------------------------- 
TESTCMOS:
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
	MOV	B,A		; SAVE THE ORIGINAL VECTOR TO REGISTER B
	MVI	C,SIOBC
	DB	0EDH, 071H	; UNDOCUMENTED OUT (C),<0|0FFH> INSTRUCTION
				; WRITE 0 OR FF TO THE SIO INTERRUPT VECTOR
	MVI	A,02H		; SET SIO CHANNEL B REGISTER POINTER
				; TO REGISTER 2 - INTERRUPT VECTOR REGISTER
	OUT	SIOBC
	IN	SIOBC		; READ THE NEW INTERRUPT VECTOR
	MOV	C,A		; SAVE THE NEW VECTOR TO REGISTER B
	MVI	A,02H		; SET SIO CHANNEL B REGISTER POINTER
				; TO REGISTER 2 - INTERRUPT VECTOR REGISTER
	OUT	SIOBC
	MOV	A,B		; RESTORE THE ORIGINAL INTERRUPT VECTOR
	OUT	SIOBC		; WRITE IT TO THE SIO
	EI
	MOV	A,C		; VALUE WRITTEN BY OUT (C),<0|0FFH> INSTRUCTION
	RET

;-------------------------------------------------------------------------
; TESTU880 - Check if the CPU is MME U880 or Thesys Z80
; Input:
;	None
; Output:
;	A = 0 - Non-U880
;	A = 1 - U880
;-------------------------------------------------------------------------
TESTU880:
	LXI	H,0FFFFH
	LXI	B,00100H+SIOBC	; USE SIO CHANNEL B COMMAND PORT FOR TESTS

	DI
	MVI	A,02H		; SET SIO CHANNEL B REGISTER POINTER
				; TO REGISTER 2 - INTERRUPT VECTOR REGISTER
	OUT	SIOBC
	IN	SIOBC		; READ THE CURRENT INTERRUPT VECTOR
	STC
	DB	0EDH,0A3H	; Z80 OUTI INSTRUCTION
	PUSH	PSW		; SAVE THE ORIGINAL VECTOR ON THE STACK
	MVI	A,02H		; SET SIO CHANNEL B REGISTER POINTER
				; TO REGISTER 2 - INTERRUPT VECTOR REGISTER
	OUT	SIOBC
	POP	PSW		; RESTORE THE ORIGINAL INTERRUPT VECTOR
	OUT	SIOBC		; WRITE IT TO THE SIO
	EI
	MVI	A,1		; Assume it is a U880, set A = 1
	JC	TESTU880DONE	; It is a U880, exit
	XRA	A		; Not a U880, set A = 00

TESTU880DONE:
	RET

;-------------------------------------------------------------------------
; TESTXY - Tests how SCF (STC) instruction affects FLAGS.5 (YF) and FLAGS.3 (XF)
; Input:
;	None
; Output:
;	A[7:6] - YF result of F = 0, A = C | 0x20 & 0xF7
;	A[5:4] - XF result of F = 0, A = C | 0x08 & 0xDF
;	A[3:2] - YF result of F = C | 0x20 & 0xF7, A = 0
;	A[1:0] - XF result of F = C | 0x08 & 0xDF, A = 0
;	Where the result bits set as follows:
;	00 - YF/XF always set as 0
;	11 - YF/XF always set as 1
;	01 - YF/XF most of the time set as 0
;	10 - YF/XF most of the time set as 1
;-------------------------------------------------------------------------
TESTXY:
	MVI	C,0FFH		; loop counter
	
TESTXY1:
	LXI	H,XFYFCOUNT	; results stored here

; check F = 0, A = C | 0x20 & 0xF7
	MVI	E,00H		; FLAGS = 0
	MOV	A,C
	ORI	020H		; A.5 = 1
	ANI	0F7H		; A.3 = 0
	MOV	D,A		; A = C | 0x20 & 0xF7
	PUSH	D		; PUSH DE TO THE STACK
	POP	PSW		; POP A AND FLAGS FROM THE STACK (DE)
	STC			; SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
				; ALSO MIGHT CHANGE YF AND XF FLAGS
	CALL	STOREYCOUNT

; check F = 0, A = C | 0x08 & 0xDF
	MVI	E,00H		; FLAGS = 0
	MOV	A,C
	ORI	08H		; A.3 = 1
	ANI	0DFH		; A.5 = 0
	MOV	D,A		; A = C | 0x08 & 0xDF
	PUSH	D		; PUSH DE TO THE STACK
	POP	PSW		; POP A AND FLAGS FROM THE STACK (DE)
	STC			; SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
				; ALSO MIGHT CHANGE YF AND XF FLAGS
	CALL	STOREXCOUNT

; check F = C | 0x20 & 0xF7, A = 0
	MOV	A,C
	ORI	020H		; FLAGS.5 = 1
	ANI	0F7H		; FLAGS.3 = 0
	MOV	E,A		; FLAGS = C | 0x20 & 0xF7
	MVI	D,00H		; A = 0
	PUSH	D		; PUSH DE TO THE STACK
	POP	PSW		; POP A AND FLAGS FROM THE STACK (DE)
	STC			; SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
				; ALSO MIGHT CHANGE YF AND XF FLAGS
	CALL	STOREYCOUNT

; check F = C | 0x08 & 0xDF, A = 0
	MOV	A,C
	ORI	08H		; FLAGS.3 = 1
	ANI	0DFH		; FLAGS.5 = 0
	MOV	E,A		; FLAGS = C | 0x08 & 0xDF
	MVI	D,00H		; A = 0
	PUSH	D		; PUSH DE TO THE STACK
	POP	PSW		; POP A AND FLAGS FROM THE STACK (DE)
	STC			; SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
				; ALSO MIGHT CHANGE YF AND XF FLAGS
	CALL	STOREXCOUNT

	DCR	C
	JNZ	TESTXY1

	
	MVI	C,4		; iteration count - number of bytes
	LXI	H,XFYFCOUNT	; counters

TESTXY2:
	RAL
	RAL
	ANI	0FCH		; zero two least significant bits
	MOV	B,A		; store A to B
	MOV	A,M
	CPI	7FH
	JNC	TESTXY3		; jump if the count is 0x80 or more
	CPI	0
	JZ	TESTXY5		; the count is 0 leave bits at 0
	MVI	A,1		; the count is between 1 and 0x7F, set result bits to 01
	JMP	TESTXY5
TESTXY3:
	CPI	0FFH
	MVI	A,2		; the count is between 0x80 and 0xFE, set result bits to 10
	JNZ	TESTXY4
	MVI	A,3		; the count is 0xFF, set result bits to 11
	JMP	TESTXY5
TESTXY4:
	MVI	A,1		; the count is 0x7F or less, set result bits to 01
TESTXY5:
	ORA	B
	INX	H
	DCR	C
	JNZ	TESTXY2
	RET

;-------------------------------------------------------------------------
; STOREXCOUNT - Isolates and stores XF to the byte counter at (HL)
; Input:
;	FLAGS	- flags
;	HL	- pointer to the counters
; Output:
;	HL	- incremented by 1 (points to the next counter)
; Trashes A and DE
;-------------------------------------------------------------------------
STOREXCOUNT:
	PUSH	PSW		; transfer flags
	POP	D		; to E register
	MOV	A,E
	ANI	08H		; isolate XF
	JZ	STOREXDONE
	INR	M		; increment the XF counter (HL)
STOREXDONE:
	INX	H		; point to the next entry
	RET

;-------------------------------------------------------------------------
; STOREYCOUNT - Isolates and stores YF to the byte counter at (HL)
; Input:
;	FLAGS	- flags
;	HL	- pointer to the counters
; Output:
;	HL	- incremented by 1 (points to the next counter)
; Trashes A and DE
;-------------------------------------------------------------------------
STOREYCOUNT:
	PUSH	PSW		; transfer flags
	POP	D		; to E register
	MOV	A,E
	ANI	20H		; isolate YF
	JZ	STOREYDONE
	INR	M		; increment the YF counter (HL)
STOREYDONE:
	INX	H		; point to the next entry
	RET
	
;-------------------------------------------------------------------------
; TESTFLAGS - TEST HOW SCF INSTRUCTION AFFECTS YF AND XF FLAGS
; NOTE: YF IS FLAGS.5 AND XF IS FLAGS.3
; INPUT:
;	NONE
; OUTPUT:
;	PRINTED ON CONSOLE
;-------------------------------------------------------------------------	
TESTFLAGS:
	LXI	D,MSGFLAGS
	MVI	C,WRSTR
	CALL	BDOS
	MVI	D,00H
TFLOOP1:
	MVI	E,00H
TFLOOP2:
	PUSH	D
	DI
	PUSH	D		; PUSH DE TO THE STACK
	POP	PSW		; POP A AND FLAGS FROM THE STACK (DE)
	CMC			; SET CF FLAG, DEPENDING ON THE CPU TYPE THIS
				; ALSO MIGHT CHANGE YF AND XF FLAGS
	PUSH	PSW		; STORE A AND F
	POP	D		; NEW FLAGS IN E
	EI
	MOV	A,E		; FLAGS TO ACCUMULATOR
	POP	D
	JMP	CONT

PRINTFLAGS:
	CALL	PRINTHEX	; PRINT ACCUMULATOR
	MOV	A,E		; FLAGS TO ACCUMULATOR
	POP	D
	PUSH	PSW
	MOV	A,D		; PRINT ORIGINAL ACCUMULATOR(FLAGS)
	CALL	PRINTHEX
	POP	PSW
	CALL	PRINTHEX	; PRINT NEW FLAGS
	PUSH	D
	LXI	D,MSGCRLF
	CALL	PRINTSTR
	POP	D
CONT:

	LXI	H,XFCOUNT	; POINT TO XF COUNTER
	RRC			; BIT 3 TO CF
	RRC
	RRC
	RRC
	JNC	TFLOOP4
	INR	M		; INCREMENT COUNTER IF FLAG IS SET
	JNZ	TFLOOP4		; NO OVERFLOW
	INX	H		; MOVE TO THE HIGH BIT
	INR	M		; INCREMENT HIGHER BIT

TFLOOP4:
	LXI	H,YFCOUNT	; POINT TO YF COUNTER
	RRC			; BIT 5 TO CF
	RRC
	JNC	TFLOOP5
	INR	M		; INCREMENT COUNTER IF FLAG IS SET
	JNZ	TFLOOP5		; NO OVERFLOW
	INX	H		; MOVE TO THE HIGH BIT
	INR	M		; INCREMENT HIGHER BIT
TFLOOP5:
	INR	E
	JNZ	TFLOOP2
	INR	D		; INCREMENT D
	JNZ	TFLOOP1

; PRINT VALUES
	MVI	C,4		; 4 BYTES
	LXI	H,YFCOUNT+1	; POINT AT THE MSB
TFLOOP6:
	MOV	A,M
	CALL 	PRINTHEX
	DCX	H
	DCR	C
	JNZ	TFLOOP6		; PRINT NEXT DIGIT

	LXI	D,MSGCRLF
	MVI	C,WRSTR
	CALL	BDOS
	RET

; PRINT VALUES
	LXI	H,YFCOUNT+1	; MSB OF YF COUNT
	MOV	A,M
	CALL 	PRINTHEX
	DCX	H		; LSB OF YF COUNT
	MOV	A,M
	CALL 	PRINTHEX
	LXI	H,XFCOUNT+1	; MSB OF XF COUNT
	MOV	A,M
	CALL 	PRINTHEX
	DCX	H		; LSB OF XF COUNT
	MOV	A,M
	CALL 	PRINTHEX

	LXI	D,MSGCRLF
	MVI	C,WRSTR
	CALL	BDOS
	RET

;-------------------------------------------------------------------------
; PRINTHEX - PRINT BYTE IN HEXADECIMAL FORMAT
; INPUT:
;	A - BYTE TO PRINT
; OUTPUT:
;	NONE
;-------------------------------------------------------------------------
PRINTHEX:
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW		; SAVE PRINTED VALUE ON THE STACK
	RRC			; ROTATE HIGHER 4 BITS TO LOWER 4 BITS
	RRC
	RRC
	RRC
	CALL	PRINTDIGIT	; PRINT HIGHER 4 BITS
	POP	PSW		; RESTORE PRINTED VALUE
	PUSH	PSW		; PUSH IT TO THE STACK AGAIN
	CALL	PRINTDIGIT	; PRINT LOWER 4 BITS
	POP	PSW	
	POP	H
	POP	D
	POP	B
	RET

;-------------------------------------------------------------------------	
; PRINTDIGIT - PRINT DIGIT IN HEXADECIMAL FORMAT
; INPUT:
;	A - DIGIT TO PRINT, LOWER 4 BITS 
; OUTPUT:
;	NONE
; TRASHES REGISTERS A, FLAGS, BC, DE, HL
;-------------------------------------------------------------------------	
PRINTDIGIT:
	ANI	0FH		; ISOLATE LOWER 4 BITS
	ADI	'0'		; CONVERT TO ASCII
	CPI	'9'+1		; GREATER THAN '9'?
	JC	PRINTIT
	ADI	'A'-'9'-1	; CONVERT A-F TO ASCII
	
PRINTIT:
	MOV	E,A
	MVI	C,WRCHR
	CALL	BDOS
	RET

;-------------------------------------------------------------------------
; PRINTSTR - Print string
; INPUT:
;	D - address of the string to print
; OUTPUT:
;	None
; Note: String must be terminated with a dollar sign
;-------------------------------------------------------------------------
PRINTSTR:
	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,WRSTR
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

DEBUG		DB	0
ISCMOS		DB	0
ISU880		DB	0
XYRESULT	DB	0
XFYFCOUNT	DB	0,0,0,0
XFCOUNT		DW	0
YFCOUNT		DW	0
MSGSIGNIN	DB	'Z80 Processor Type Detection (C) 2024 Sergey Kiselev'
MSGCRLF		DB	0DH,0AH,'$'
MSGUSAGE	DB	'Invalid argument. Usage: z80type [/D]',0DH,0AH,'$'
MSGRAWCMOS	DB	'Raw results:       CMOS: $'
MSGFLAGS	DB	'XF/YF flags test:  $'
MSGRAWU880	DB	' U880: $'
MSGRAWXY	DB	' XF/YF: $'
MSGCPUTYPE	DB	'Detected CPU type: $'
MSGU880NEW	DB	'Newer MME U880, Thesys Z80, Microelectronica MMN 80CPU$'
MSGU880OLD	DB	'Older MME U880$'
MSGSHARPLH5080A	DB	'Sharp LH5080A$'
MSGNMOSZ80	DB	'Zilog Z80, Zilog Z08400 or similar NMOS CPU',0DH,0AH
		DB      '                   '
		DB	'Mostek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1$'
MSGNECD780C	DB	'NEC D780C, GoldStar Z8400, possibly KR1858VM1$'
MSGNECD780C1	DB	'NEC D780C-1$'
MSGKR1858VM1	DB	'Overclocked KR1858VM1$'
MSGNMOSUNKNOWN	DB	'Unknown NMOS Z80 clone$'
MSGCMOSZ80	DB	'Zilog Z84C00$'
MSGTOSHIBA	DB	'Toshiba TMPZ84C00AP, ST Z84C00AB$'
MSGNECD70008AC	DB	'NEC D70008AC$'
MSGCMOSUNKNOWN	DB	'Unknown CMOS Z80 clone$'

	END
