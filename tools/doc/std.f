\ простановка ссылок на ANS
\ возможно в будущем будет копия ANS в дистре - тогда легко будет менять ссылки
\ и не загромождают текст в md шаблонах

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f

: NUMBER ( a u -- n -1 | 0 )
  0 0 2SWAP >NUMBER NIP IF 2DROP FALSE ELSE D>S TRUE THEN ; 

: get-part ( a u -- n )
   2DUP S" ." SEARCH 0= ABORT" WTF!"
   NIP - NUMBER 0= ABORT" WTF!!" ;

MODULE: qqq

 : std
    PARSE-NAME 
    2DUP
    2DUP get-part 
    -ROT
    " [{s}](http://forth.sourceforge.net/standard/dpans/dpans{n}.htm#{s})" STR@ ;

;MODULE

: REPLACE ( a u -- a1 u1 )
   ONLY qqq
   EVAL-FILE
   ONLY FORTH ;

: perform: ( "source" "target" -- ) PARSE-NAME 2DUP CR TYPE REPLACE DUP . PARSE-NAME 2DUP CR TYPE OCCUPY ;

: test
   S" 3.1.3" get-part 3 <> ABORT" FAILED"
   S" 42.431.3" get-part 42 <> ABORT" FAILED" 
   CR ." TEST PASSED" ;
