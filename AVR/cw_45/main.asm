.cseg         
.org 0         
	rjmp _main 
.org OC1Aaddr     
	rjmp _timer_isr 


; Definicje dla wyœwietlacza
.def Digit_3 = R2 
.def Digit_2 = R3 
.def Digit_1 = R4 
.def Digit_0 = R5 

; Porty obs³uguj¹ce wyœwietlacz
.equ Digits_P = PORTB
.equ Segments_P = PORTD

; Licznik binarny (0-1000)
.def PulseEdgeCtrL = R0
.def PulseEdgeCtrH = R1

.macro LOAD_CONST
	ldi @0, HIGH(@2)
	ldi @1, LOW(@2)
.endmacro

; odswiezanie wyswietlacza
.macro SET_DIGIT
	ldi R16, 0
	out Digits_P, R16
	mov R16, Digit_@0
	rcall DigitTo7segCode
	out Segments_P, R16
	ldi R16, (16>>@0)					 
	out Digits_P, R16
	LOAD_CONST R17, R16, @1
	rcall DelayInMs
.endmacro

//==============================================
//
//setup:

_main:

ldi R16, (1<<CS12) | (1<<WGM12)		//
out TCCR1B, R16						//preskaler 256 i tryb CTC

ldi R16, LOW(100)					//
ldi R17, HIGH(100)					//
out OCR1AL, R16						//
out OCR1AH, R17						//porónanie CTC 100

ldi R16, (1<<OCIE1A)				//
out TIMSK, R16						//w³¹czenie przerwania od CTC timera1

sei					
 		
ldi R16, 0
ldi R17, 0
ldi R18, 0
ldi R19, 0

mov Digit_3, R16
mov Digit_2, R17
mov Digit_1, R18
mov Digit_0, R19

ldi R16, 0b01111111
out DDRD, R16
ldi R16, 0b00011110
out DDRB, R16

_MainLoop:						
	SET_DIGIT 0, 2
	SET_DIGIT 1, 2
	SET_DIGIT 2, 2
	SET_DIGIT 3, 2

	SET_DIGIT 0, 3
	SET_DIGIT 1, 3
	SET_DIGIT 2, 3
	SET_DIGIT 3, 3

	SET_DIGIT 0, 5
	SET_DIGIT 1, 5
	SET_DIGIT 2, 5
	SET_DIGIT 3, 5

	inc PulseEdgeCtrL
	brne SkipIncCtrH
	inc PulseEdgeCtrH
SkipIncCtrH:				

	ldi YYL, LOW(1000)
	ldi YYH, HIGH(1000)

	mov XXL, PulseEdgeCtrL
	mov XXH, PulseEdgeCtrH
	rcall Divide

	mov PulseEdgeCtrL, RL
	mov PulseEdgeCtrH, RH

	mov R16, PulseEdgeCtrL
	mov R17, PulseEdgeCtrH
	rcall NumberToDigits
	
	mov Digit_0, R16
	mov Digit_1, R17
	mov Digit_2, R18
	mov Digit_3, R19

	rjmp _MainLoop
//=====================================


//======================================
DelayInMs:
	push R24
	push R25

	mov R24, R16
	mov R25, R17
CallDelayOneMs:			
	rcall DelayOneMs
	sbiw R25:R24, 1
	brne CallDelayOneMs

	pop R25
	pop R24
	ret		

DelayOneMs:
	push R24
	push R25

	ldi R24, LOW(1995)
	ldi R25, HIGH(1995)
CountDown:				
	sbiw R25:R24, 1
	brne CountDown

	pop R25
	pop R24
	ret

//=================================================
DigitTo7segCode:	
	push ZH
	push ZL
	push R17

	ldi ZH, HIGH(SegCodesTable << 1)
	ldi ZL, LOW(SegCodesTable << 1)
	ldi R17, 0
	add ZL, R16
	adc ZH, R17
	lpm R16, Z

	pop R17
	pop ZL
	pop ZH
	ret

SegCodesTable: .db 0x3F, 0x06, 0xDB, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

; Inputs
.def XXL=R16 ; divident
.def XXH=R17
.def YYL=R18 ; divisor 
.def YYH=R19

; Outputs
.def RL=R16 ; remainder
.def RH=R17
.def QL=R18 ; quotient
.def QH=R19

; Internal
.def QCtrL=R24
.def QCtrH=R25

//===========================================
Divide:
	push QCtrL
	push QCtrH

	ldi QCtrL, 0
	ldi QCtrH, 0

RepeatSub:				
	cp XXL, YYL
	cpc XXH, YYH

	brmi EndDiv

	sub XXL, YYL
	sbc XXH, YYH
	adiw QCtrH:QCtrL, 1
	rjmp RepeatSub

EndDiv:					
	mov QL, QCtrL
	mov QH, QCtrH

	mov RL, XXL
	mov RH, XXH

	pop QCtrH
	pop QCtrL
	ret

; Internals
.def Dig0=R22 ; Digits temps
.def Dig1=R23 ;
.def Dig2=R24 ;
.def Dig3=R25 ;

//=================================================
NumberToDigits:					
	push Dig0
	push Dig1
	push Dig2
	push Dig3

	ldi YYL, LOW(1000)
	ldi YYH, HIGH(1000)

	rcall Divide
							
	mov Dig3, QL
							
	ldi YYL, LOW(100)
	ldi YYH, HIGH(100)

	rcall Divide

	mov Dig2, QL

	ldi YYL, LOW(10)
	ldi YYH, HIGH(10)

	rcall Divide

	mov Dig1, QL
	mov Dig0, RL

	mov R16, Dig0
	mov R17, Dig1
	mov R18, Dig2
	mov R19, Dig3

	pop Dig3
	pop Dig2
	pop Dig1
	pop Dig0
	ret

//=================================



_timer_isr:    
	inc R0  
	reti  