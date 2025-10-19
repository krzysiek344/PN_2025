.equ Digits_P   = PORTB
.equ Segments_P = PORTD

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

;------------------------
ldi R16, 0x01
out DDRB, R16
ldi R16, 0x7F
out DDRD, R16

ldi R24, low(250)      
ldi R25, high(250)

;==========================
rcall SetZero

MainLoop:
    SELECT_SEGM 0x2
    rcall DelayInMs

    SELECT_SEGM 0x4
    rcall DelayInMs

    SELECT_SEGM 0x8
    rcall DelayInMs

    SELECT_SEGM 0x10
    rcall DelayInMs

    rjmp MainLoop
;===========================

SetZero:
    ldi R16, 0x3F
    out Segments_P, R16
    ret

SetOne:
    ldi R16, 0x06
    out Segments_P, R16
    ret

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

    ldi R25, high(1986)
    ldi R24, low(1986)

DelayOneMs_Wait:
    sbiw R24, 1
    brne DelayOneMs_Wait

    POPIT R25, R24
    ret
