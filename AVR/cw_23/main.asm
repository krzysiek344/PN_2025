MainLoop:
        rcall DelayOneMs
        ldi R22, 100  
        rcall DelayInMs 
        rcall RandomFun  
        rjmp  MainLoop 


;--------------------------------------------------

DelayInMs:							
        Delay1:	rcall DelayOneMs
                dec R22
			    brne Delay1
                ret     

DelayOneMs:     
        ldi R20, 13		

       	ldi R25, high(1986)      
	    ldi R24, low(1986)      

        Wait1:	sbiw R24, 1
			    brne Wait1
            
                mov R16, R20
			
        Wait2:		dec R16
			    nop	
			    brne Wait2
	    ret
                

RandomFun: 
        ldi R20, 1
        ldi R21, 2
        add R20, R21
        ret



