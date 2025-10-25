.equ Digits_P = PORTB
.equ Segments_P = PORTD

.def  Digit_0 = R2
.def  Digit_1 = R3
.def  Digit_2 = R4
.def  Digit_3 = R5

.macro POPIT
    pop @0
    pop @1
.endmacro

.macro PUSHIT
    push @0
    push @1
.endmacro

.macro SELECT_SEGM
    ldi R16, @0
    out Digits_P, R16
.endmacro

.macro LOAD_CONST
    ldi @0, low(@2)
    ldi @1, high(@2)
.endmacro

.macro SET_DIGIT
    .if @0==0
        mov R16, Digit_0
    .elif @0==1
        mov R16, Digit_1
    .elif @0==2
        mov R16, Digit_2
    .elif @0==3
        mov R16, Digit_3
    .endif
    rcall DigitTo7segCode
    out Segments_P, R16
    .if @0==0
        SELECT_SEGM 0x02
    .elif @0==1
        SELECT_SEGM 0x04
    .elif @0==2
        SELECT_SEGM 0x08
    .elif @0==3
        SELECT_SEGM 0x10
    .endif
    rcall DelayInMs
.endmacro



ldi R16, 0x1F
out DDRB, R16
ldi R16, 0x7F

out DDRD, R16

ldi R16, 3
mov Digit_0, R16
ldi R16, 4
mov Digit_1, R16
ldi R16, 5
mov Digit_2, R16
ldi R16, 6
mov Digit_3, R16

LOAD_CONST R24, R25, 5

MainLoop:

    SET_DIGIT 0
    SET_DIGIT 1
    SET_DIGIT 2
    SET_DIGIT 3

    rjmp MainLoop

DigitTo7segCode:
    push R30
    push R31

    ldi R30, low(SegCode<<1)
    ldi R31, high(SegCode<<1)

    add R30, R16
    adc R31, R1

    lpm R16, Z

    pop R31
    pop R30
    ret

SegCode: .db 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F


DelayInMs:
    PUSHIT R24, R25
Wait:
    rcall DelayOneMs
    sbiw R24, 1
    brne Wait
    POPIT R25, R24
    ret

DelayOneMs:
    PUSHIT R24, R25
    ldi  R25, high(1986)
    ldi  R24, low(1986)
DelayOneMs_Wait:
    sbiw R24, 1
    brne DelayOneMs_Wait
    POPIT R25, R24
    ret
