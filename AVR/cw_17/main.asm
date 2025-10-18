ldi R22, 12
Delay:
    ldi R21, 11
    Loop1: 
       ldi R20, 239
      Loop2: 
         dec R20 
         brne Loop2
      dec R21
      brne Loop1

    ldi R21, 26
    MiniLoop: 
      dec R21
      brne MiniLoop
    nop
    nop
    dec R22
    brne Delay

