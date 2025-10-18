MainLoop:
    ldi R22, 10
    sts 0x60, R22
    rcall DelayInMs
    rjmp MainLoop

;--------------------------------------------------

DelayInMs:
    lds R24, 0x60
    clr R25
    Wait:
        rcall DelayOneMs
        sbiw R24, 1
        brne Wait
        ret
;--------------------------------------------------

DelayOneMs:
    sts  0x60, R24
    sts  0x61, R25

    ldi  R25, high(1986)
    ldi  R24, low(1986)

DelayOneMs_Wait:
    sbiw R24, 1
    brne DelayOneMs_Wait

    lds  R24, 0x60
    lds  R25, 0x61
    ret

;--------------------------------------------------


