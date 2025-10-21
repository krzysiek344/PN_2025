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

ldi R16, 0x01
out DDRB, R16
ldi R16, 0x7F
out DDRD, R16

;--------------------------------------------------

ldi R16, 0x3F
mov Digit_0, R16
ldi R16, 0x06
mov Digit_1, R16
ldi R16, 0x5B
mov Digit_2, R16
ldi R16, 0x4F
mov Digit_3, R16

LOAD_CONST R24, R25, 5

;==========================
MainLoop:
    ; cyfra 0
    mov R16, Digit_0
    out Segments_P, R16
    SELECT_SEGM 0x02
    rcall DelayInMs

    ; cyfra 1
    mov R16, Digit_1
    out Segments_P, R16
    SELECT_SEGM 0x04
    rcall DelayInMs

    ; cyfra 2
    mov R16, Digit_2
    out Segments_P, R16
    SELECT_SEGM 0x08
    rcall DelayInMs

    ; cyfra 3
    mov R16, Digit_3
    out Segments_P, R16
    SELECT_SEGM 0x10
    rcall DelayInMs

    rjmp MainLoop
;==========================

;---------------------------------------------------
DelayInMs:
    PUSHIT R24, R25

Wait:
    rcall DelayOneMs
    sbiw R24, 1           
    brne Wait

    POPIT R25, R24
    ret

;---------------------------------------------------
DelayOneMs:
    PUSHIT R24, R25

    ldi  R25, high(1986)
    ldi  R24, low(1986)
     
DelayOneMs_Wait:
    sbiw R24, 1
    brne DelayOneMs_Wait

    POPIT R25, R24
    ret
