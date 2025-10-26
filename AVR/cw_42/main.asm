; U�ycie standardowych definicji X, Y
; Zak�adamy, �e XL=R26, XH=R27, YL=R28, YH=R29 (zgodne z rejestrem X, Y)
.def RL = R20       ; remainder (niska cz��)
.def RH = R21       ; remainder (wysoka cz��)
.def QL = R22       ; quotient (niska cz��)
.def QH = R23       ; quotient (wysoka cz��)
.def QCtrL = R24    ; wewn�trzny licznik (niska cz��)
.def QCtrH = R25    ; wewn�trzny licznik (wysoka cz��)

;===================================================

MainLoop:
    ldi R26, low(1200)   ; Wczytaj dividend = 1200 do X (R26:R27)
    ldi R27, high(1200)
    ldi R28, low(500)    ; Wczytaj divisor = 500 do Y (R28:R29)
    ldi R29, high(500)
    rcall Divide
    ; Po wywo�aniu: RL:RH (R20:R21) = 200 (reszta)
    ;               QL:QH (R22:R23) = 2 (iloraz)
    rjmp MainLoop

Divide:
    push R0
    push R1
    push R24
    push R25
    push R20
    push R21
    push R22
    push R23
    push R26
    push R27
    push R28
    push R29

    clr QCtrL          ; Zeruj quotient
    clr QCtrH

Loop:
    cp R26, R28        ; Por�wnaj dividend (X) z divisor (Y)
    cpc R27, R29
    brlo EndLoop       ; Je�li dividend < divisor, zako�cz

    sub R26, R28       ; Dividend = Dividend - Divisor
    sbc R27, R29
    adiw QCtrL:QCtrH, 1 ; Zwi�ksz quotient o 1
    rjmp Loop

EndLoop:
    mov RL, R26        ; Reszta = Dividend
    mov RH, R27
    mov QL, QCtrL      ; Iloraz = Licznik
    mov QH, QCtrH

    pop R29
    pop R28
    pop R27
    pop R26
    pop R23
    pop R22
    pop R21
    pop R20
    pop R25
    pop R24
    pop R1
    pop R0
    ret