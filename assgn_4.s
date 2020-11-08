 AREA     appcode, CODE, READONLY
	 IMPORT printMsg
     IMPORT printSigmoid
     EXPORT __main
	 ENTRY 
__main  FUNCTION

                   
				   mov R8,#4 ; 
				   mov r3, #7 ; 
; weights and bias
logic_AND        VLDR.F32 s31 ,=-0.1 	;w0
		           VLDR.F32 s30 ,=0.2    ;w1   
                   VLDR.F32	s29 ,=0.2 	;w2
                   VLDR.F32 s28 ,=-0.2;  bias  
				   SUB R3,R3,#1 ; 
				   B DATA_SELECT  ; 

				   
logic_OR           VLDR.F32 s31 ,=0.2 	;w0
		           VLDR.F32 s30 ,=0.2  ;w1   
                   VLDR.F32	s29 ,=0.2	;w2
                   VLDR.F32 s28 ,=-0.1;  bias  
				   SUB R3,R3,#1 ; 

			   B DATA_SELECT  ; 
				   
logic_NOT         VLDR.F32 s31 ,=-0.5 	;w0
		           VLDR.F32 s30 ,=-0.7    ;w1   
                   VLDR.F32	s29 ,=0.0 	;w2
                   VLDR.F32 s28 ,=0.1;  bias 
				   SUB R3,R3,#1 ;

				   B DATA_SELECT ;; 
				   
				   
logic_XOR        VLDR.F32 s31 ,=-5.0 	;w0
		           VLDR.F32 s30 ,=20.0    ;w1   
                   VLDR.F32	s29 ,=10.0 	;w2
                   VLDR.F32 s28 ,=1.0 ;  bias
					SUB R3,R3,#1 ; 

					B DATA_SELECT  ;
			
logic_XNOR         VLDR.F32 s31 ,=-5.0 	;w0
		           VLDR.F32 s30 ,=20.0    ;w1   
                   VLDR.F32	s29 ,=10.0	;w2
                   VLDR.F32 s28 ,=1.0;  bias
                   SUB R3,R3,#1 ; 
				   B DATA_SELECT  ; 

logic_NAND         VLDR.F32 s31 ,=0.6 	;w0
		           VLDR.F32 s30 ,=-0.8    ;w1   
                   VLDR.F32	s29 ,=-0.8	;w2
                   VLDR.F32 s28 ,=0.3;  bias  
				   SUB R3,R3,#1 ; 
				   B DATA_SELECT  ;
				   
logic_NOR        VLDR.F32 s31 ,=0.2 	;w0
		           VLDR.F32 s30 ,=0.2    ;w1   
                   VLDR.F32	s29 ,=0.2	;w2
                   VLDR.F32 s28 ,=-0.7;  bias 
					SUB R3,R3,#1 ;
					B DATA_SELECT   ; 
                   				  


DATA_SELECT cmp R8, #4 
         beq set1

         cmp R8, #3
         beq set2

		cmp R8, #2
		beq set3

		cmp R8, #1
		beq set4 



set1    VLDR.F32 s25 , =1 ;x0
        VLDR.F32 s26 , =0 ;x1
        VLDR.F32 s27 , =0 ;x2
		B   CALCULATE_z;   
set2    VLDR.F32 s25 , =1 ;x0
        VLDR.F32 s26 , =0 ;x1
        VLDR.F32 s27 , =1 ;x2	
		B   CALCULATE_z;   
set3    VLDR.F32 s25 , =1 ;x0
        VLDR.F32 s26 , =1 ;x1
        VLDR.F32 s27 , =0 ;x2	
		B   CALCULATE_z;   
set4    VLDR.F32 s25 , =1 ;x0
        VLDR.F32 s26 , =1 ;x1
        VLDR.F32 s27 , =1 ;x2	
		B   CALCULATE_z;   

  CALCULATE_z 	VMUL.F32 S24,S31,S25 ; W0.X0
			VMUL.F32 S23,S30,S26 ; W1.X1
			VMUL.F32 S22,S29,S27 ; W2.X2
			VADD.F32 S21,S24,S23 ; W0.X0 + W1.X1
			VADD.F32 S20,S21,S22 ; W0.X0 + W1.X1 + W2.X2
			VADD.F32 S19,S20,S28 ; W0.X0 + W1.X1 + W2.X2 + BIAS = Z
			B sigmoid_fun ; calculating 1/(1 + e^(-x)) 
			
sigmoid_fun	MOV R7, #1 ; power of X
	        
	
	;;;;;;; input z to the sigmoid will be s19;;;;;;;;;;;;;;;;;;
	VNEG.F32 S1,S19 ; changing x to -x
	
	VLDR.F32 S3, = 1 
	VLDR.F32 S12, = 1 ; THIS FP REG S12 WILL DISPLAY THE RESULT of e^-x
	MOV R9, #25; Number of iterations
	;;; EXP SERIES EDITION;;;
	MOV R10, #1 ; temp reg to calculate factorial
mult_	  VMUL.F32 S3,S3,S1 ; temp=temp*x

FACTORIAL  MUL R10,R10,R7 ; calculating factorial for denominator
		   
		   
          vmov S14,R10 
          VCVT.F32.u32 S14,S14 ; converting S14 to Floating point 
	      VDIV.F32 S13,S3,S14 ; dividing by factorial 
		  VADD.F32 S12,S12,S13 ;  adding to the result ( result of e^(-x) ) 
		  
iter ADD R7,R7, #1 ; incrmenting power of x
	 SUB R9,R9, #1 ; decrementing iterations number
	 CMP R9, #0 
	 BNE mult_
	
SIGMOID VLDR.F32 S2, =1 ;
        VADD.F32 S11,S12,S2 ; calculating 1+e^(-x)
		VDIV.F32 S7,S2,S11 ; calculating 1/ 1+e^(-x)

		VLDR.F32 S17, = 0.5 ; 

	    VCMP.F32 S7,S17 ; 
		
		VMRS APSR_nzcv, FPSCR
		MOVLE R0, #0
		MOVGT R0, #1
		;MOV R0, R12
	    BL printSigmoid ; printing outputs of logic gates
		sub R8, R8, #1 ; decrementing dataset register 
		cmp R8,#0
		BEQ LOGIC_SELECT
	    B DATA_SELECT
	
	
LOGIC_SELECT mov R8,#4
		  cmp r3, #6 
		  beq logic_OR
		  
		  cmp r3, #5
		  beq logic_NOT
		  
		  cmp r3, #4
		  beq logic_XOR
		  
		  cmp r3, #3
		  beq logic_XNOR
		  
		  cmp r3,#2
		  beq logic_NAND
		  
		  cmp r3, #1
		  beq logic_NOR
		  
		  cmp r3, #0 
		  beq stop
	
	
	
stop	B stop; stop program	 
		 
     ENDFUNC
     END
