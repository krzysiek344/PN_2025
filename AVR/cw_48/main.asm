.include "tn2313def.inc"

// Rejestry przechowuj¹ce poszczególne cyfry wyœwietlacza
.def Digit_3 = R2 
.def Digit_2 = R3 
.def Digit_1 = R4 
.def Digit_0 = R5 

// Porty obs³uguj¹ce wyœwietlacz
.equ Digits_P = PORTB
.equ Segments_P = PORTD

// Licznik binarny
.def PulseEdgeCtrL = R0
.def PulseEdgeCtrH = R1

// Makro wype³niaj¹ce dwa podane rejestry liczb¹ 16-bitow¹
.macro LOAD_CONST
	ldi @0, HIGH(@2) ; POPRAWKA: HIGH do pierwszego arg
	ldi @1, LOW(@2)  ; POPRAWKA: LOW do drugiego arg
.endmacro

// Makro odœwie¿aj¹ce poszczególne cyfry wyœwietlacza
.macro SET_DIGIT
	ldi R16, 0
	out Digits_P, R16
	mov R16, Digit_@0
	rcall DigitTo7segCode
	out Segments_P, R16
	ldi R16, (16>>@0)  ; POPRAWKA: (16>>@0) zamiast (1<<@0)
	out Digits_P, R16
	rcall DelayOneMs
.endmacro

.cseg
.org 0x00
	rjmp _main
.org OC1Aaddr*2
	rjmp _timer_isr
.org PCIaddr*2
	rjmp _pcint0_isr

_main:
	; Inicjalizacja PB0 jako wejœcia
	ldi R16, 0x00
	out DDRB, R16
	ldi R16, (1<<PCIE)
	out GIMSK, R16
	ldi R16, (1<<PCINT0)
	out PCMSK, R16

	; Timer1 CTC (1Hz)
	ldi R16, (1<<CS12) | (1<<WGM12)
	out TCCR1B, R16
	ldi R16, LOW(31250)
	ldi R17, HIGH(31250)
	out OCR1AL, R16
	out OCR1AH, R17
	ldi R16, (1<<OCIE1A)
	out TIMSK, R16

	sei

	; Zerowanie cyfr
	clr Digit_3
	clr Digit_2
	clr Digit_1
	clr Digit_0

	ldi R16, 0b01111111
	out DDRD, R16
	ldi R16, 0b00011110  ; PB1-PB4 jako wyjœcia (OK)
	out DDRB, R16

_MainLoop:
	SET_DIGIT 0
	SET_DIGIT 1
	SET_DIGIT 2
	SET_DIGIT 3
	rjmp _MainLoop

;===================== PRZERWANIA =====================

_timer_isr:
	in R16, SREG
	push R16
	push R17
	push R18
	push R19

    cli                      ; POPRAWKA: Sekcja krytyczna (wy³¹czenie przerwañ)
	mov R16, PulseEdgeCtrL
	mov R17, PulseEdgeCtrH
    sei                      ; POPRAWKA: Koniec sekcji krytycznej
    
	rcall NumberToDigits

	mov Digit_0, R16
	mov Digit_1, R17
	mov Digit_2, R18
	mov Digit_3, R19

	pop R19
	pop R18
	pop R17
	pop R16
	out SREG, R16
	reti

_pcint0_isr:
	in R16, SREG
	push R16
	push R6

	inc PulseEdgeCtrL
	brne no_carry
	inc PulseEdgeCtrH
no_carry:

	pop R6
	pop R16
	out SREG, R16
	reti

;===================== OPÓNIENIA =====================

DelayOneMs:
	push R24
	push R25
	ldi R24, LOW(1995)
	ldi R25, HIGH(1995)
count_ms:
	sbiw R25:R24, 1
	brne count_ms
	pop R25
	pop R24
	ret

;===================== TABELA 7SEG =====================

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

SegCodesTable:
	.db 0b00111111, 0b00000110, 0b11011011, 0b01001111, 0b01100110
	.db 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111

;===================== DZIELENIE =====================

.def XXL = R16
.def XXH = R17
.def YYL = R18
.def YYH = R19
.def RL = R16
.def RH = R17
.def QL = R18
.def QH = R19
.def QCtrL = R24
.def QCtrH = R25

Divide:
	push QCtrL
	push QCtrH
	clr QCtrL
	clr QCtrH
repeat_sub:
	cp XXL, YYL
	cpc XXH, YYH
	brcs end_div
	sub XXL, YYL
	sbc XXH, YYH
	adiw QCtrH:QCtrL, 1
	rjmp repeat_sub
end_div:
	mov QL, QCtrL
	mov QH, QCtrH
	mov RL, XXL
	mov RH, XXH
	pop QCtrH
	pop QCtrL
	ret

;===================== KONWERSJA LICZBY =====================

.def Dig0 = R20
.def Dig1 = R21
.def Dig2 = R22
.def Dig3 = R23

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