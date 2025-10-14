Inf_Loop: ldi R20, 10
nop
nop
nop
nop
nop
Loop: dec R20
nop
nop
brne Loop
rjmp Inf_Loop

; c) Cycles = (R20 * 3)
