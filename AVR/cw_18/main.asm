ldi R22, 100						
			ldi R20, 33		

Delay:		ldi R16, 0      ; m³odszy bajt
			ldi R17, 0      ; starszy bajt

Wait1:		add R16, R20
			adc R17, R21

			brbc 0, Wait1

			ldi R16, 13
			
Wait2:		dec R16
			nop	
			brne Wait2
			dec R22
			brbc 1, Delay
			
			nop								//debug
