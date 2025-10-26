

.cseg         
.org 0x00     rjmp _main 
.org 0x02     rjmp _pcint0_isr    ; Przerwanie PCINT0 (PB0) dla ATmega32


; Definicje dla wyœwietlacza
.def Digit_3 = R2 
.def Digit_2 = R3 
.def Digit_1 = R4 
.def Digit_0 = R5 

; Porty obs³uguj¹ce wyœwietlacz
.equ Digits_P = PORTB
.equ Segments_P = PORTD

; Licznik binarny (0-9999)
.def PulseEdgeCtrL = R0
.def PulseEdgeCtrH = R1

.macro LOAD_CONST
	ldi @0, HIGH(@2)
	ldi @1, LOW(@2)
.endmacro

; Odœwie¿anie wyœwietlacza
.macro SET_DIGIT
	ldi R16, 0
	out Digits_P, R16
	mov R16, Digit_@0
	rcall DigitTo7segCode
	out Segments_P, R16
	ldi R16, (16>>@0)					 
	out Digits_P, R16
	LOAD_CONST R17, R16, 2
	rcall DelayInMs
.endmacro

_main:
	ldi R16, 0x00
	out DDRB, R16			; PB0 jako wejœcie, reszta portu na razie wejœcia

	ldi R16, (1<<PCIE0)
	sts PCICR, R16			; W³¹czenie przerwañ pinów zmianowych dla grupy 0 (PB0-PB7)
	
	ldi R16, (1<<PCINT0)
	sts PCMSK0, R16			; Aktywowanie przerwania dla PB0

	sei						; W³¹czenie globalnych przerwañ

	ldi R16, 0
	ldi R17, 0
	ldi R18, 0
	ldi R19, 0

	mov Digit_3, R16
	mov Digit_2, R17
	mov Digit_1, R18
	mov Digit_0, R19

	ldi R16, 0b01111111
	out DDRD, R16			; PORTD 0-6 jako wyjœcia
	ldi R16, 0b00011110
	out DDRB, R16			; PORTB 1-4 jako wyjœcia

_MainLoop:						
	SET_DIGIT 0
	SET_DIGIT 1
	SET_DIGIT 2
	SET_DIGIT 3
	rjmp _MainLoop

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

SegCodesTable: .db 0b00111111, 0b00000110, 0b11011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111

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

Divide:
	push QCtrL
	push QCtrH
	ldi QCtrL, 0
	ldi QCtrH, 0
RepeatSub:				
	cp XXL, YYL
	cpc XXH, YYH
	brcs EndDiv
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

_pcint0_isr:
	push R16
	push R17
	push R18
	push R19
	push R24
	push R25
	in R21, SREG
	push R21
	push R22
	push R23

	inc PulseEdgeCtrL
	brne SkipIncCtrH
	inc PulseEdgeCtrH
SkipIncCtrH:				

	ldi YYL, LOW(10000)
	ldi YYH, HIGH(10000)
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

	pop R23
	pop R22
	pop R21
	out SREG, R21
	pop R25
	pop R24
	pop R19
	pop R18
	pop R17
	pop R16
	reti