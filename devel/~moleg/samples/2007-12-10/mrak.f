 1024 ALLOCATE THROW VALUE adr 

 : combs ( u -- adr u )
   0 adr >R 
   BEGIN 
   2DUP SWAP 1 + U< 
   WHILE 
   2DUP SWAP INVERT AND 0= 
   IF DUP R@ ! R> 4 + >R  THEN 
   1 + 
   REPEAT 
   2DROP adr R> OVER - 
 ;