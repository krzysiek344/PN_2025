; Definicje rejestrów dla Divide
.def NumL = R16    ; dividend (niska czêœæ) - unikalna nazwa
.def NumH = R17    ; dividend (wysoka czêœæ)
.def DenL = R18    ; divisor (niska czêœæ) - unikalna nazwa
.def DenH = R19    ; divisor (wysoka czêœæ)
.def RemL = R20    ; remainder (niska czêœæ)
.def RemH = R21    ; remainder (wysoka czêœæ)
.def QuotL = R26   ; quotient (niska czêœæ, u¿ycie R26, aby unikn¹æ konfliktu z Dig0-Dig3)
.def QuotH = R27   ; quotient (wysoka czêœæ)
.def CtrL = R28    ; wewnêtrzny licznik (niska czêœæ)
.def CtrH = R29    ; wewnêtrzny licznik (wysoka czêœæ)

; Definicje rejestrów dla NumberToDigits
.def Dig0 = R22    ; Tymczasowe cyfry (tysi¹ce)
.def Dig1 = R23    ; (setki)
.def Dig2 = R24    ; (dziesi¹tki)
.def Dig3 = R25    ; (jednoœci)

; Pêtla g³ówna do debugowania
MainLoop:
    ldi R16, low(1357)  ; Wczytaj liczbê testow¹ 1357
    ldi R17, high(1357)
    rcall NumberToDigits
    ; Po wywo³aniu: R16 = 1 (tysi¹ce), R17 = 3 (setki), R18 = 5 (dziesi¹tki), R19 = 7 (jednoœci)
    rjmp MainLoop       ; Nieskoñczona pêtla do debugowania

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

    ; Krok 1: Podziel przez 1000 (cyfra tysiêcy)
    mov NumL, R16       ; Kopiuj liczbê wejœciow¹
    mov NumH, R17
    ldi DenL, low(1000)
    ldi DenH, high(1000)
    rcall Divide
    mov Dig0, QuotL     ; Tysi¹ce = Quotient

    ; Krok 2: Podziel resztê przez 100 (cyfra setek)
    mov NumL, RemL
    mov NumH, RemH
    ldi DenL, low(100)
    ldi DenH, high(100)
    rcall Divide
    mov Dig1, QuotL     ; Setki = Quotient

    ; Krok 3: Podziel resztê przez 10 (cyfra dziesi¹tek)
    mov NumL, RemL
    mov NumH, RemH
    ldi DenL, low(10)
    ldi DenH, high(10)
    rcall Divide
    mov Dig2, QuotL     ; Dziesi¹tki = Quotient

    ; Krok 4: Jednoœci to reszta
    mov Dig3, RemL      ; Jednoœci = Remainder

    ; Przenieœ cyfry do rejestrów wyjœciowych
    mov R16, Dig0       ; Tysi¹ce
    mov R17, Dig1       ; Setki
    mov R18, Dig2       ; Dziesi¹tki
    mov R19, Dig3       ; Jednoœci

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
    cp NumL, DenL      ; Porównaj dividend z divisor
    cpc NumH, DenH
    brlo EndLoop       ; Jeœli dividend < divisor, zakoñcz

    sub NumL, DenL     ; Dividend = Dividend - Divisor
    sbc NumH, DenH
    adiw CtrL:CtrH, 1  ; Zwiêksz quotient o 1
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