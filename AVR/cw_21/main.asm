MainLoop:  
rcall DelayNCycles 
rcall RandomFun  
rjmp  MainLoop 




DelayNCycles:
nop 
nop 
nop 
ret     

RandomFun: 
ldi R20, 1
ldi R21, 2
add R20, R21
ret


; tak wszytko si� zgadza, przypomina to troch� dobrze ustawione rjmp
