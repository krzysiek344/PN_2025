 ;### MACROS & defs (.equ)###

; Macro LOAD_CONST loads given registers with immediate value, example: LOAD_CONST  R16,R17 1234 
.MACRO LOAD_CONST  
    ldi @0, low(@2)
    ldi @1, high(@2)
.ENDMACRO 

/*** Display ***/
.equ DigitsPort             = PORTB
.equ SegmentsPort           = PORTD
.equ DisplayRefreshPeriod   = 5

; SET_DIGIT diplay digit of a number given in macro argument, example: SET_DIGIT 2
.MACRO SET_DIGIT  
    push R16
    push R17

    ldi R16, (2<<(@0))
    out DigitsPort, R16

    mov R16, Dig_@0
    rcall _DigitTo7segCode
    out SegmentsPort, R16

    LOAD_CONST R16, R17, DisplayRefreshPeriod
    rcall DelayInMs

    pop R17
    pop R16

.ENDMACRO 

; ### GLOBAL VARIABLES ###

.def PulseEdgeCtrL=R0
.def PulseEdgeCtrH=R1

.def Dig_0=R2
.def Dig_1=R3
.def Dig_2=R4
.def Dig_3=R5

; ### INTERRUPT VECTORS ###
.cseg		     ; segment pami?ci kodu programu 

.org	 0      rjmp	_main	 ; skok do programu g?ównego
.org OC1Aaddr	rjmp    _Timer_ISR
.org PCIBaddr   rjmp    _ExtInt_ISR ; skok do procedury obs?ugi przerwania zenetrznego 

; ### INTERRUPT SEERVICE ROUTINES ###

_ExtInt_ISR: 	 ; procedura obs?ugi przerwania zewnetrznego

    push R16
    in R16, SREG

    inc PulseEdgeCtrL
    brne NoOverflow
        inc PulseEdgeCtrH

    NoOverflow:

    out SREG, R16
    pop R16

reti   ; powrót z procedury obs?ugi przerwania (reti zamiast ret)      

_Timer_ISR:
    push R16
    push R17
    push R18
    push R19

    push R20
    in R20, SREG

    movw R17:R16, PulseEdgeCtrH:PulseEdgeCtrL
    clr PulseEdgeCtrH
    clr PulseEdgeCtrL

    lsr R17
    ror R16
    rcall _NumberToDigits

    movw Dig_1:Dig_0, R17:R16
    movw Dig_3:Dig_2, R19:R18


    out SREG, R20
    pop R20

	pop R19
    pop R18
    pop R17
    pop R16

  reti

; ### MAIN PROGAM ###

_main: 
    ; *** Initialisations ***
    cli
    ;--- Ext. ints --- PB0
    ;push R16
    ldi R16, (1<<PCIE0)
    out GIMSK, R16

    ldi R16, (1<<PCINT0)
    out PCMSK0, R16
    ;pop R16
	;--- Timer1 --- CTC with 256 prescaller
    ;push R16
    ;push R17
    ldi R16, ((1<<CTC1)|(1<<CS12))
    out TCCR1B, R16

    ldi R16, (1<<OCIE1A)
    out TIMSK, R16  

    LOAD_CONST R16, R17, 31250
    out OCR1AH, R17
    out OCR1AL, R16
   ; pop R17
   ; pop R16
	;---  Display  --- 
   ; push R16

    clr Dig_0
    clr Dig_1
    clr Dig_2
    clr Dig_3

    ldi R16, 0x1e
    out DDRB, R16

    ldi R16, 0x7F
    out DDRD, R16

   ; pop R16

	; --- enable gloabl interrupts
    sei

MainLoop:   ; presents Digit0-3 variables on a Display
			SET_DIGIT 0
			SET_DIGIT 1
			SET_DIGIT 2
			SET_DIGIT 3

			RJMP MainLoop

; ### SUBROUTINES ###

;*** NumberToDigits ***
;converts number to coresponding digits
;input/otput: R16-17/R16-19
;internals: X_R,Y_R,Q_R,R_R - see _Divider

; internals
.def Dig0=R22 ; Digits temps
.def Dig1=R23 ; 
.def Dig2=R24 ; 
.def Dig3=R25 ; 

_NumberToDigits:

	push Dig0
	push Dig1
	push Dig2
	push Dig3

	; thousands 
    LOAD_CONST R18, R19, 1000
    rcall _Divide
    mov Dig0, R18

	; hundreads 
    LOAD_CONST R18, R19, 100
    rcall _Divide
    mov Dig1, R18     

	; tens 
    LOAD_CONST R18, R19, 10
    rcall _Divide
    mov Dig2, R18   

	; ones 
    mov Dig3, R16

	; otput result
	mov R16,Dig0
	mov R17,Dig1
	mov R18,Dig2
	mov R19,Dig3

	pop Dig3
	pop Dig2
	pop Dig1
	pop Dig0

	ret

;*** Divide ***
; divide 16-bit nr by 16-bit nr; X/Y -> Qotient,Reminder
; Input/Output: R16-19, Internal R24-25

; inputs
.def XL=R16 ; divident  
.def XH=R17 

.def YL=R18 ; divider
.def YH=R19 

; outputs

.def RL=R16 ; reminder 
.def RH=R17 

.def QL=R18 ; quotient
.def QH=R19 

; internal
.def QCtrL=R24
.def QCtrH=R25

_Divide:push R24 ;save internal variables on stack
        push R25
		
        clr QCtrL
        clr QCtrH

        DivideLoop:

            cp XL, YL
            cpc XH, YH
            brlo ExitDivide

            sub XL, YL
            sbc XH, YH

            adiw QCtrH:QCtrL, 1

            rjmp DivideLoop

        ExitDivide:

        movw QH:QL, QCtrH:QCtrL

		pop R25 ; pop internal variables from stack
		pop R24

		ret

; *** DigitTo7segCode ***
; In/Out - R16

Table: .db 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0x7f,0x6f

_DigitTo7segCode:

push R30
push R31

    ldi R31, high(Table<<1)
    ldi R30, low(Table<<1)

    add R30, R16

    lpm R16, Z

pop R31
pop R30

ret

; *** DelayInMs ***
; In: R16,R17
DelayInMs:  
            push R24
			push R25

            movw R25:R24, R17:R16
            DelayLoop:
                rcall OneMsLoop
                sbiw R25:R24, 1
                brne DelayLoop

			pop R25
			pop R24

			ret

; *** OneMsLoop ***
OneMsLoop:	
			push R24
			push R25 
			
			LOAD_CONST R24,R25,2000                    

L1:			SBIW R24:R25,1 
			BRNE L1

			pop R25
			pop R24

			ret