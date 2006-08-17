\                                            Максимов М.О. 

0xFF CONSTANT MAX$@   \ maximum length of contents of a counted string

: "CLIP"        ( a1 n1 -- a1 n1' )   \ clip a string to between 0 and MAXCOUNTED
                0 MAX MAX$@ AND ( UMIN ) ;

: $!         ( addr len dest -- )
                SWAP "CLIP" SWAP
                2DUP 2>R
                CHAR+ SWAP MOVE
                2R> C! ;
: PLACE $! ;
: $+!       ( addr len dest -- ) \ append string addr,len to counted
                                     \ string dest
                >R "CLIP" MAX$@  R@ C@ -  MIN R>
                                        \ clip total to MAXCOUNTED string
                2DUP 2>R

                COUNT CHARS + SWAP MOVE
                2R> +! ;
: +PLACE $+! ;

: $C+!       ( c1 a1 -- )    \ append char c1 to the counted string at a1
                DUP 1+! COUNT + 1- C! ;

: C+PLACE $C+! ;

