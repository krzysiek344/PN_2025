; Definicje rejestr�w dla Divide
.def NumL = R16    ; dividend (niska cz��) - unikalna nazwa
.def NumH = R17    ; dividend (wysoka cz��)
.def DenL = R18    ; divisor (niska cz��) - unikalna nazwa
.def DenH = R19    ; divisor (wysoka cz��)
.def RemL = R20    ; remainder (niska cz��)
.def RemH = R21    ; remainder (wysoka cz��)
.def QuotL = R26   ; quotient (niska cz��, u�ycie R26, aby unikn�� konfliktu z Dig0-Dig3)
.def QuotH = R27   ; quotient (wysoka cz��)
.def CtrL = R28    ; wewn�trzny licznik (niska cz��)
.def CtrH = R29    ; wewn�trzny licznik (wysoka cz��)

; Definicje rejestr�w dla NumberToDigits
.def Dig0 = R22    ; Tymczasowe cyfry (tysi�ce)
.def Dig1 = R23    ; (setki)
.def Dig2 = R24    ; (dziesi�tki)
.def Dig3 = R25    ; (jedno�ci)

; P�tla g��wna do debugowania
MainLoop:
    ldi R16, low(1357)  ; Wczytaj liczb� testow� 1357
    ldi R17, high(1357)
    rcall NumberToDigits
    ; Po wywo�aniu: R16 = 1 (tysi�ce), R17 = 3 (setki), R18 = 5 (dziesi�tki), R19 = 7 (jedno�ci)
    rjmp MainLoop       ; Niesko�czona p�tla do debugowania

; Podprogram NumberToDigits
NumberToDigits:
    push R0
    push R1
    push R20
    push R21
    push R22
    push R23
    push R24
    push R25
    push R26
    push R27
    push R28
    push R29

    ; Krok 1: Podziel przez 1000 (cyfra tysi�cy)
    mov NumL, R16       ; Kopiuj liczb� wej�ciow�
    mov NumH, R17
    ldi DenL, low(1000)
    ldi DenH, high(1000)
    rcall Divide
    mov Dig0, QuotL     ; Tysi�ce = Quotient

    ; Krok 2: Podziel reszt� przez 100 (cyfra setek)
    mov NumL, RemL
    mov NumH, RemH
    ldi DenL, low(100)
    ldi DenH, high(100)
    rcall Divide
    mov Dig1, QuotL     ; Setki = Quotient

    ; Krok 3: Podziel reszt� przez 10 (cyfra dziesi�tek)
    mov NumL, RemL
    mov NumH, RemH
    ldi DenL, low(10)
    ldi DenH, high(10)
    rcall Divide
    mov Dig2, QuotL     ; Dziesi�tki = Quotient

    ; Krok 4: Jedno�ci to reszta
    mov Dig3, RemL      ; Jedno�ci = Remainder

    ; Przenie� cyfry do rejestr�w wyj�ciowych
    mov R16, Dig0       ; Tysi�ce
    mov R17, Dig1       ; Setki
    mov R18, Dig2       ; Dziesi�tki
    mov R19, Dig3       ; Jedno�ci

    pop R29
    pop R28
    pop R27
    pop R26
    pop R25
    pop R24
    pop R23
    pop R22
    pop R21
    pop R20
    pop R1
    pop R0
    ret

; Podprogram Divide
Divide:
    push R0
    push R1
    push R20
    push R21
    push R26
    push R27
    push R28
    push R29

    clr CtrL           ; Zeruj quotient
    clr CtrH

Loop:
    cp NumL, DenL      ; Por�wnaj dividend z divisor
    cpc NumH, DenH
    brlo EndLoop       ; Je�li dividend < divisor, zako�cz

    sub NumL, DenL     ; Dividend = Dividend - Divisor
    sbc NumH, DenH
    adiw CtrL:CtrH, 1  ; Zwi�ksz quotient o 1
    rjmp Loop

EndLoop:
    mov RemL, NumL     ; Reszta = Dividend
    mov RemH, NumH
    mov QuotL, CtrL    ; Iloraz = Licznik
    mov QuotH, CtrH

    pop R29
    pop R28
    pop R27
    pop R26
    pop R21
    pop R20
    pop R1
    pop R0
    ret