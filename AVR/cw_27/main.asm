
.macro POPIT
pop @0
pop @1
.endmacro

.macro PUSHIT
push @0
push @1
.endmacro

MainLoop:
    ldi R24, low(300)      
    ldi R25, high(300)     
    rcall DelayInMs
    rjmp MainLoop

;--------------------------------------------------

DelayInMs:
    PUSHIT R24, R25

Wait:
    rcall DelayOneMs
    sbiw R24, 1           
    brne Wait

    POPIT R25, R24
    ret

;--------------------------------------------------

DelayOneMs:
    PUSHIT R24, R25

    ldi  R25, high(1986)
    ldi  R24, low(1986)
     
DelayOneMs_Wait:
    sbiw R24, 1
    brne DelayOneMs_Wait

    POPIT R25, R24
    ret


