ldi R21, 5
Loop1: ldi R20, 100
Loop2: dec R20
nop 
brne Loop2
dec R21
brne Loop1


