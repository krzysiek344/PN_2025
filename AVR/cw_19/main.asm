			
			ldi R22, 100						
			ldi R20, 13		

Delay:		ldi R25, high(1986)      ; m³odszy bajt
			ldi R24, low(1986)       ; starszy bajt

Wait1:		sbiw R24, 1
			brne Wait1
            
            mov R16, R20
			
Wait2:		dec R16
			nop	
			brne Wait2
			dec R22
			brne Delay
			
			nop								//debug
