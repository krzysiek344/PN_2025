ldi R21, 13
Loop1: 
    ldi R20, 255
    Loop2: 
        dec R20 
        brne Loop2
    dec R21
    brne Loop1

ldi R21, 5
MiniLoop: 
    dec R21
    brne MiniLoop
nop

