\ stringstack v0.10

\ download as http://forthfreak.net/stringstack
REQUIRE [IF] lib/include/tools.f
REQUIRE OFF lib/ext/onoff.f
REQUIRE PLACE lib/include/string.f

 WARNING DUP @ SWAP OFF
 TRUE \ FALSE  
 CONSTANT USE_LIBRARY
 WARNING !

 \ 01.03.2006г. Абдрахимов И.А.
 \ Маленькое изменение в слове push$, производится выделение памяти на 1
 \ байт больше и вставка нуля в конце строки

 \ strings.f   string words  (should be) ANS conform. compiles with vanilla gforth
 \ v0.10  20050107 Speuler  added -scan$, -skip$, searchn$ and dropn$
 \ v0.09a 20041008 Speuler  added scan$ skip$ description
 \ v0.09  20020305 Speuler  added scan$ skip$
 \ v0.08, 20020211 Speuler  added mid$  reverse$  translate$
 \ v0.07, 20020211 Speuler  improved left$, right$, split$, pick$, roll$, .s$, constants for throw values
 \ v0.06, 20020211 Speuler  fixed bug in example, speeded up dup$ drop$ swap$ over$, added left$ right$
 \ v0.05, 20020210 Speuler  added split$  merge$
 \ v0.04, 20020210 Speuler  added compare$  roll$  search$  subsearch$
 \ v0.03, 20020210 Speuler  added depth$  .s$  pick$
 \ v0.02, 20020210 Speuler  factored out refcount decrementing, pushing to flushstrings
 \ v0.01, 20020210 Speuler  initial implementation




 \ stringstack words:
 \  tos$     ( -- a n )     gives topmost string, same as 0 pick$ (but no test whether topmost elements actually exists)
 \  push$    ( a n -- )     pushs a string to stringstack
 \  pop$     ( -- a n )     pops a string from stringstack, marks it as freeable if last ref
 \  dup$     ( -- )         duplicates string on stringstack
 \  drop$    ( -- )         drops a string on stringstack, marks as freeable if last ref
 \  dropn$   ( n -- )       drop top n strings
 \  swap$    ( -- )         swaps top two strings on stringstack
 \  over$    ( -- )         pushs a copy of nos string
 \  free$    ( -- )         frees memory used by freeable strings
 \  depth$   ( -- n )       number of items on string stack
 \  compare$ ( n1 n2 -- n3 ) compare strings at stack pos n1 and n2
 \  pick$    ( n1 -- a n2 ) return nth string, counting from top of string stack
 \  roll$    ( n -- )       roll string at string stack pos n to top of string stack
 \  searchn$ ( a n1 n2 -- n3 -1 | 0 ) search for a n1 through n2 elements
 \  search$  ( a n -- n -1 | 0 )  search through stringstack, return stack position of match, or 0
 \  subsearch ( a n -- n -1 | 0 ) substring search through stringstack.
 \  left$    ( n -- )       leaves n left chars, or cuts off -n right chars
 \  right$   ( n -- )       leaves n right chars, or cuts off -n left chars
 \  mid$     ( index len -- ) extracts string subsection. negative index counts from the right.
 \  reverse$ ( -- )         mirror image of string
 \  split$   ( n -- )       splits top string into two at position n. n<0 counts fromon string end
 \  merge$ ( -- )           appends top string to nos string
 \  translate$ ( a n -- )   replace chars in string against chars from table at a
 \  skip$    ( c -- n )     returns length of string after skipping leading cs 
 \  scan$    ( c -- n )     returns length of string from first c to string end
 \ -scan$    ( c -- n )     reverse scan, from right end of string
 \ -skip$    ( c -- n )     reverse skip, from right end of string
 \  .s$      ( -- )         display stack dump of string stack. number shown is string reference count

 \ string count is cell size, i.e. strings > 255 bytes are ok.
 \ split$ and merge$ have been implemented to avoid having to use length-limited strings words


 BASE @ DECIMAL  
 1024 CONSTANT MAXSTRINGS


 \ ---------- general stuff ----------

 \ throw values
  -4 CONSTANT STACK_UNDERFLOW    \ string stack underflow
 -24 CONSTANT INVALID_ARGUMENT   \ pick$, roll$ index too high
  32 CONSTANT MAXTYPE            \ max chars per string typed by .s$

 CELL 2 = [IF]  ' 2/ ALIAS CELL/  ( n1 -- n2 )   [THEN]
 CELL 4 = [IF] : CELL/ ( n1 -- n2 )        2 RSHIFT ; [THEN]
 CELL 8 = [IF] : CELL/ ( n1 -- n2 )        3 RSHIFT ; [THEN]


 \ USE_LIBRARY [IF]

   \ REQUIRE CELL-       REQUIRE INC       REQUIRE DEC         REQUIRE SKIM
   \ REQUIRE PLUCK       REQUIRE 3DUP      REQUIRE EXCHANGE    REQUIRE SWAPCHARS

 \ [ELSE]

 \  : CELL- ( X1 -- X2 )   CELL -  ;
   : INC   ( A -- )   1 SWAP +!  ;
   : DEC   ( A -- )   -1 SWAP +!  ;
   : SKIM  ( A1 -- A2 X )    CELL+ DUP CELL- @  ;
   : PLUCK ( X1 X2 X3 -- X1 X2 X3 X1 )   2 PICK  ;
   : 3DUP ( X1 X2 X3 -- X1 X2 X3 X1 X2 X3 )  PLUCK PLUCK PLUCK ;
   : EXCHANGE ( X1 A -- X2 )     DUP @ -ROT ! ;
   : SWAPCHARS ( A1 A2 -- )   DUP >R C@  SWAP DUP C@  R> C! C! ;

 \ [THEN]



 \ builds stack with structure   maxdepth, depth, stackdata.
 \ expects that stack space has been allocated already at a
 \ depth and maxdepth are given in bytes.
 : stack  ( N A -- )                       0 OVER CELL+ ! !  ;


 : stack:  ( N -- )                        CREATE HERE OVER CELL+ CELL+ ALLOT stack  ;
 : sp   ( A1 -- A2 )                       CELL+ DUP @ + ;          \ return address of top stack element
 : push ( X A -- )                         CELL+ CELL OVER +! DUP @ + !  ;

 : pop  ( a -- x )
    CELL+ DUP >R
    DUP @
    DUP DUP 0< SWAP 0= OR
    IF
       STACK_UNDERFLOW THROW 
    THEN
    + @                        \ read stacked data.
    [ CELL NEGATE ] LITERAL
    R> +!                      \ unbump stack pointer
 ;

 : stackused ( a -- n )        CELL+ @ CELL/ ;    \ given a stack, returns depth
 : stackfree ( a -- n )        SKIM SWAP @ - CELL/ ;  \ given a stack, returns free



 \ --------------- string stack stuff -------------------


 MAXSTRINGS CELLS stack: stringstack
 MAXSTRINGS CELLS stack: flushstack


 : depth$ ( -- n )    stringstack stackused ;
 : 'tos$  ( -- a )     stringstack sp ;               \ returns address of top element in string stack 
 : tos$ ( -- a n )    'tos$ @ CELL+ SKIM  ;           \ same as 0 pick$


 \ allocates space for refcount, stringlen, string
 \ refcount and stringlen are cell size
 : alloc$  ( len -- addr 0 | 0 err )   CELL+ CELL+ ALLOCATE  ;

 \ push string to flushstrings if refcount is 0. decrement refcount
 : ?free$  ( a -- )
    DUP @ 0= IF                 \ refcount = 0 ?
       DUP flushstack push      \ string freeable
    THEN
    DEC                         \ decrement refcount
 ;

 : assure_valid_index ( n -- ) depth$ 2DUP U> >R = R> OR IF INVALID_ARGUMENT THROW THEN ;

 \ releases unused string space. right now there is the risk of
 \ flushstack overflow. you need to call free$ before that happens.
 : free$ ( a -- 0 | err )   flushstack stackused  0 ?DO flushstack pop FREE THROW LOOP ;

 : push$  ( a n -- )
    DUP 1+ alloc$ THROW        \ a1 n a2
    DUP OFF                 \ set refcount
    DUP stringstack push     
    CELL+ 2DUP !            \ set stringlen
    CELL+ SWAP 2DUP + >R MOVE         \ copy string
    R> 0 SWAP C!
 ;


 : pop$  ( -- a n )   stringstack pop DUP ?free$  CELL+ SKIM  ;



 \ ------------------- string stack primitives -------------------
 \ (calling them primitives because there exist data stack, non-string equivalents for these)



 : drop$  ( -- )     stringstack pop ?free$  ;
 : dropn$ ( n -- )   0 ?DO  drop$  LOOP ;
 : dup$  ( -- )      'tos$ @  DUP INC stringstack push  ;

 : swap$  ( -- )   'tos$ CELL- DUP SKIM SWAP EXCHANGE SWAP ! ;
 : over$  ( -- )   'tos$ CELL- @ DUP INC  stringstack push ;


 \ return the nth string from top of string stack as address/count.
 \ beware that pick$ does NOT put the nth string on top of string stack.
 : pick$  ( n -- a n )   DUP assure_valid_index   CELLS NEGATE   'tos$ + @  CELL+ SKIM  ;


 : roll$   ( n -- )
    DUP assure_valid_index
    CELLS 'tos$ DUP >R             \ address tos, keep
    OVER - DUP @ >R                \ read target string handle
    CELL+ DUP CELL- ROT MOVE       \ move all down
    R> R> !                        \ write rolled string to tos
 ;   



 \ compares string1 at stack pos n1 with string2 at n2, returns -1 if
 \ string1, string2 are in descending order, 0 if strings are identical,
 \ 1 if string1, string2 are in ascending order.
 : compare$ ( n1 n2 -- -1 | 0 | 1 )   >R pick$  R> pick$  COMPARE ;


 \ -------------- more operations on stacked strings ----------------



 \ show string stack dump. first number is string reference count
 : .s$  ( -- )
    depth$ 0 ?DO
       CR I pick$
       OVER CELL- CELL- @ .        \ ref count
       TUCK MAXTYPE MIN
       TUCK TYPE
       - ?DUP IF                   \ string was truncated
          ." ... +" .              \ indicate "there's more"
       THEN
    LOOP
 ;

: scan >R BEGIN DUP WHILE OVER C@ R@ <> WHILE 1 /STRING REPEAT THEN RDROP ; 
: bounds OVER + SWAP ; 
 \ n gives len of remainder of string incl char scanned for
 : skip$ ( c -- n )   tos$ ROT SKIP NIP ; 

 \ n gives len of remainder of string incl char scanned for
 : scan$ ( c -- n )   tos$ ROT scan NIP ; 

 \ search for last occurance of c
 \ : -scan$  ( c -- n ) tos$ OVER >R tuck + swap 0 ?do 2DUP 1- C@ = ?leave 1- loop nip R> - ;

 \ returns len of remaining string, after having skipped any c at the end of the string
 \ : -skip$  ( c -- n ) tos$ OVER >R tuck + swap 0 ?do 2DUP 1- C@ <> ?leave 1- loop nip R> - ;



 \ seperate string stack top at bl into words
 \ : scanskipdemo ( a n -- )  
 \   begin
 \      bl scan$                \ search next space
 \   ?dup while                 \ space found:
 \      negate split$           \   split string at space
 \      bl skip$ right$         \   cut off leading space 
 \   repeat ;



 \ search for string a n1 in top n2 string stack elements
 : searchn$  ( a n1 n2 -- n -1 | 0 )
    BEGIN DUP
    WHILE
       1- 3DUP pick$ COMPARE   
       0= IF
          NIP NIP TRUE
 	 EXIT
       THEN
    REPEAT
    NIP NIP
 ;

 : search$  ( a n1 -- n2 -1 | 0 )  depth$ searchn$ ;


 : subsearch$  ( a n1 -- n2 -1 | 0 )
    depth$
    BEGIN DUP
    WHILE
       1- 3DUP pick$
       PLUCK OVER U>
       IF
          2DROP 2DROP TRUE
       ELSE
          DROP OVER COMPARE
       THEN
       0= IF
          NIP NIP TRUE
 	 EXIT
       THEN
    REPEAT
    NIP NIP
 ;

 \ appends tos string to nos string
 : merge$  ( -- )  pop$ >R pop$ TUCK R@ + push$ 'tos$ @ CELL+ CELL+ +  R>  MOVE ;


 \ splits string on stringstack into two strings at position n.
 \ also accepts negative index, which counts from end of string.
 \ index out of bounds will be truncated to string boundary.
 : split$  ( n -- )
    >R pop$
    R@ 0< IF
       DUP R> + 0 MAX >R
    THEN
    DUP R> MIN
    PLUCK OVER push$
    /STRING push$
 ;




 \ if top string is referenced more than once, detach it, and create a single-ref copy
 \ returns address and len of top string
 \ used before in-sito modification of top string, like reverse$
 : detach$  ( -- a n )
    'tos$ @ @         ( refcount )
    IF                ( multiple references )
       pop$ push$     ( create physical duplicate of string )
    THEN  tos$ ;


 \ helper word for left$ and right$
 : clipped   ( n1 n2 n3-- n4 )   0< IF  + 0 MAX  ELSE  MIN  THEN ;

 \ n>=0 : leaves left n chars of string
 \ n<0 :  cuts -n chars off the end of string
 \ index out of bounds will be truncated to string boundary.
 : left$  ( n -- )   >R pop$ R> DUP clipped push$ ;

 \ n>=0 : leaves right n chars of string
 \ n<0 :  cuts -n chars off the left of string
 \ index out of bounds will be truncated to string boundary.
 : right$ ( n -- )   >R pop$ DUP R> 2DUP clipped - /STRING push$ ;

 \ extracts string subsection.
 \ index>=0: start counting from left. index<0: start counting from right.
 \ index or len out of bounds will be truncated to string boundary.
 : mid$ ( index len -- )  SWAP ?DUP IF NEGATE right$ THEN  0 MAX left$ ;

 : reverse$ ( -- )    detach$ DUP 2/ 0 ?DO 1- 2DUP OVER + SWAP I + SWAPCHARS LOOP  2DROP ;

 \ pass a translation table, starting with ascii 0, of length n. 
 \ each character in top string is replaced against the corresponding character from table.
 : translate$   ( a n -- )
    detach$
    bounds ?DO
       DUP I C@ U>                                  \ string character in table ?
       IF
          OVER I C@ + C@                            \ read table character
 	 I C!                                      \ store in string
       THEN
    LOOP
    2DROP  ;

  
 \ example tables:
 \ create 1to1  128 0 [do] [i] c, [loop]                       \ tables contains chars 0...127
 \ '_  1to1 bl + c!                                            \ replace space against underscore in translation table
 \    1to1 128 translate$                                      \ replace spaces in top string against underscores
 \ bl 1to1 bl + c!                                             \ fix table 1 to 1 again, as we'll reuse it for example 3

 \ create noctrlchars  here 32 dup allot bl fill               \ creates table with 32 spaces
 \  noctrlchars 32 translate$                                  \ translates control chars against spaces

 \ 1to1 'a +   1to1 'A +   26 move                             \ lowercast capitals in table
 \ 1to1 'Z 1+ translate$                                       \ lowercast string



 \ ------------------------------------------------------------

 BASE !

\EOF

: test
S" Abdrahimov" push$
S" Ilya" push$
S" Arkadyevich" push$
\ 1 pick$
\ dup$
\ [CHAR] d skip$ .
\ [CHAR] r scan$ .
\ S" ya" subsearch$ IF . THEN
\ reverse$
\ 3 split$
\ merge$
CR ." ===="
.s$
CR ." ===="
\ tos$
\ 0 2 compare$ .
\ 1 pick$
\ CR pop$ TYPE
\ CR pop$ TYPE
\ CR pop$ TYPE
\ drop$
\ drop$
\ drop$
 free$
;
test