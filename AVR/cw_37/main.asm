
MainLoop:
    ldi R16, 7      
    rcall DigitTo7segCode
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


SegCode: .db 0x3F, 0x4F, 0x5B, 0x4F, 0x66,  0x6D, 0x7D, 0x07, 0x7F, 0x6F   