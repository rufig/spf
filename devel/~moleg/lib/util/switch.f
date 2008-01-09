\ 2008-01-08 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ выбор варианта по номеру (конечный автомат)

 REQUIRE init:          .\devel\~mOleg\lib\util\run.f
 REQUIRE imm_word       .\devel\~moleg\lib\newfind\search.f
 REQUIRE COMPILE        .\devel\~moleg\lib\util\compile.f
 REQUIRE NEXT-WORD      .\devel\~mOleg\lib\util\parser.f

\ выбрать u-тый вариант из списка слов,
\ полученных между SWITCH: err_name namea nameb ... ;SWITCH
: (switch) ( u --> )
           ADDR * R@ @ OVER CELL + SWAP 0 SWAP WITHIN
           IF R@ + [ 2 CELLS ] LITERAL
            ELSE DROP R@ CELL
           THEN + A@ EXECUTE
           R> DUP @ + CELL + >R ;

\ маркер оканчивает секцию SWITCH: ;ENDSWITCH
: ;SWITCH ( --> ) ." ;SWITCH without SWITCH:" TYPE -1 THROW  ; IMMEDIATE

\ начинает секцию SWITCH: ;SWITCH
: SWITCH: ( --> )
          STATE @ IFNOT init: THEN 5 controls +!
          COMPILE (switch) <MARK 1 0 A,
          BEGIN NEXT-WORD DUP WHILE
                SFIND DUP IFNOT -1 THROW THEN    \ если слово не найдено
                imm_word = WHILENOT
              A,
            REPEAT ['] ;SWITCH = IFNOT -1 THROW THEN
          THEN >RESOLVE
          -5 controls +!
          controls @ IFNOT [COMPILE] ;stop THEN
          ; IMMEDIATE

\ первое слово после SWITCH: выполняется в случае выхода за диапазон

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ : inv 123 ; : 1st 234 ; : 2st 345 ; : 3st 456 ; : 4st 567 ;
      : test SWITCH: inv 1st 2st 3st 4st ;SWITCH 678 ;
      0 test 234 678 D= 0= THROW
      1 test 345 678 D= 0= THROW
      2 test 456 678 D= 0= THROW
      3 test 567 678 D= 0= THROW
      4 test 123 678 D= 0= THROW
     -1 test 123 678 D= 0= THROW
      2 SWITCH: inv 1st 2st 3st 4st ;SWITCH 456 <> THROW
  S" passed" TYPE
}test