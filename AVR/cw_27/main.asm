
MainLoop:
    ldi R16, low(100)
    ldi R17, high(100)
    rcall DelayInMs
    rjmp MainLoop

;--------------------------------------------------

DelayInMs:
    push R16
    push R17
    push R24
    push R25

    lds R16, 
    Wait:
        rcall DelayOneMs
        sbiw R16, 1
        brne Wait

    pop R25
    pop R24
    pop R17
    pop R16
    ret
;--------------------------------------------------

DelayOneMs:
    push R24
    push R25

    ldi  R25, high(1986)
    ldi  R24, low(1986)

DelayOneMs_Wait:
    sbiw R24, 1
    brne DelayOneMs_Wait

    pop R25
    pop R24
    ret

;--------------------------------------------------


