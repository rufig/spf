\ Работа со строками. Якимов Д. А. 31.01.99
\ Длина строки автоматически (!!!) увеличивается на 1 в связи
\ с присутствием нулевого байта в конце
\ Удобно при работе с WinAPI и вообще ;)
\ Структура строки - [ length body 0 ]
\                         1   ...  1

: C0! ( addr -- )
      0 SWAP C!
;
: csz ( addr -- )
      0 SWAP !
;

: "cs! ( addr u cs )
  >R DUP R@ C!
  R> 1+ SWAP CMOVE
;

: csLen
  COUNT SWAP DROP
;

: cs! 
  >R DUP csLen 1+ R>  SWAP CMOVE
;

: cs>ASCIIZ
  COUNT + 0 SWAP C!
; \

: 0csCreate ( size -- addr )
      2 + ALLOCATE THROW DUP 0!
;

: csCreate ( addr u -- addr1 )
        DUP >R 2+ ALLOCATE THROW DUP DUP DUP
        R@ SWAP C! 
        R@ + C0!
        ROT SWAP 1+ R> CMOVE
;

: csFree ( addr -- )
          FREE THROW
;

: getCs ( addr1 -- addr2 u )
          COUNT
;
: getCs>z ( addr1 -- addr2 )
          1+
;

\ копирует строку со счетчиком
: cs>A ( cs A -- )
  >R COUNT 1+ SWAP 1- SWAP 
  R> SWAP CMOVE
; 

: A>cs ( addr u cs -- )
       2DUP C!
       2DUP + 1+ C0!
       1+ SWAP CMOVE
;

: cs+A ( cs addr u -- )
       ROT DUP >R ROT   \ u cs addr R: cs
       OVER COUNT +     \ u cs addr addr2 R: cs
       ROT DROP         \ u addr addr2 R: cs
       >R OVER R>       \ u addr u addr2
       SWAP CMOVE            
       R@ C@ + R@ C!
       R> COUNT + 1+ C0!
;
      
    
: csLen ( cs cs -- u )
  >R COUNT SWAP DROP
  R> COUNT SWAP DROP +
;

\ cs2=cs2+cs1
: cs+! ( cs1 cs2 -- )
       2DUP
       SWAP COUNT       \ .. cs2 addr1 u1
       ROT COUNT +      \ .. addr1 u1 addr2+u2
       SWAP CMOVE       
       DUP >R
       csLen R@ C!
       R> DUP C@ + 1+ C0! 
;
\ cs1 -> cs2
: csCopy ( cs1 cs2 -- )
         >R DUP C@ 2+ R> SWAP CMOVE
;
\ добавляет к строке символ с
: csChar+! ( c cs -- )
       DUP >R
       COUNT + DUP >R C!
       R> 1+ C0!
       R@ C@ 1+ 
       R> C!
;

: csCompare ( cs cs -- flag )
            >R COUNT R> COUNT COMPARE
;

\ присутствие в конце строки 0 учитывается автоматически
: csResize ( cs u -- addr )
     1+ RESIZE THROW
;

(
 \ Tests
0 VALUE TS1
0 VALUE TS2
0 VALUE TS3

: TEST S" DIMA" csCreate TO TS1 S" LANA" csCreate TO TS2 ;

: T 
   S" dima" csCreate TO TS1
   TS1 S" +AELLA" cs+A
   TS1 COUNT TYPE
;
T
)

