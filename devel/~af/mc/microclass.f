\ Andrey Filatkin, af@forth.org.ru
\ ��������� ~day\mc\microclass.f
( 13.05.2000 Dmitry Yakimov
  ver. 1.5.
  ��� ���������� ���� �������� ����� � ~1001bytes, ���������� � ���������� [!].
)
( ���� ���������� ����������� ��� ������ ��������. ���� �����������
  ������������, ������������� ��������\����������� ��������.
  ��� ���� ����� ������� � ���������. � ������ ������� ������ ���������
  ���� ������ _mc, � ������� �������� self. ��� ������� ������� ��������,
  ��� ��� �������� self � USER-����������.

  �������� �������:
     CLASS: Test
        0
          CELL FIELD x
          CELL FIELD y
        CONSTANT /Test

        M: INIT   x ! y ! ;
     ;CLASS

     CHILD: Test Test1
        /Test
          CELL FIELD z
        CONSTANT /Test1
        M: INIT   INHERIT z ! ;
     ;CLASS
      
  �������� ������������ �������:
     ALSO Test 1 2 /Test OBJECT 
       ...
     PREVIOUS

  �������� ������������� �������:
     : foo
       [ ALSO Test ] 1 2 /Test NEWOBJ
         ...
       DELETEOBJ [ PREVIOUS ]
     ;
)

REQUIRE {  ~af/lib/locals.f

VOCABULARY MicroClass
GET-CURRENT ALSO MicroClass DEFINITIONS  \ MicroClass private

USER uObj
USER uObjMethodShadowed

\ ���������� ���� �������� ��������
: FIELD ( u.offset1 u.size "name" -- u.offset2 )
  CREATE IMMEDIATE OVER , +
  DOES> ?COMP  @ LIT, S" _mc +" EVALUATE
;

\ ��� ������������ �����
: M:
  WARNING @ >R WARNING 0!
  >IN @ >R  PARSE-NAME  R> >IN !
  uObj @ SEARCH-WORDLIST 0= IF 0 THEN uObjMethodShadowed !
  :
  R> WARNING !
  S" { _mc } " EVALUATE
;

: ;CLASS ( wid -- )  PREVIOUS PREVIOUS SET-CURRENT ;

: LOOK-INIT (  -- 0 | xt 1 | xt -1 )
  S" INIT" CONTEXT @ SEARCH-WORDLIST
;

: LOOK-DESTROY ( wid -- 0 | xt 1 | xt -1 )
  S" DESTROY" CONTEXT @ SEARCH-WORDLIST
;

: (NEW) ( length  -- addr )
  DUP ALLOCATE THROW
  DUP ROT ERASE
;

\ ������������ ���� ����
: INHERIT ( -- )
  uObjMethodShadowed @ ?DUP
  IF
    S" _mc" EVALUATE
    COMPILE,
  THEN
; IMMEDIATE

: DO-IT-DEF ( -- wid.compilation.prev )
  ALSO MicroClass
  ALSO LATEST-NAME NAME> EXECUTE \ ������� ����� ������� � CONTEXT
  GET-CURRENT DEFINITIONS  \ ������� ��� �������
  GET-CURRENT uObj !
;

SET-CURRENT  \ Export (public)

: CLASS: ( "name" -- wid.compilation.prev )
  VOCABULARY DO-IT-DEF
;

: CHILD: ( "name.parent" "name.new" -- wid.compilation.prev )
  '  XT>WID  CLASS:  SWAP ( wid.compilation.prev wid.parent )
  GET-CURRENT CHAIN-WORDLIST \ ����� ������� ���������� � ������ �������������
;

\ �������� ������� � ��������� ������������
: OBJECT  ( length  -- addr )
  HERE OVER ALLOT
  DUP ROT ERASE
  LOOK-INIT IF OVER >R EXECUTE R> THEN
;

\ �������� ������� � ����
: NEWOBJ  \ Run-time: ( u.obj-size -- addr.obj )
  STATE @
  IF
    POSTPONE (NEW)
    LOOK-INIT IF POSTPONE DUP POSTPONE >R COMPILE, POSTPONE R> THEN
  ELSE
    (NEW)
    LOOK-INIT IF OVER >R EXECUTE R> THEN
  THEN
; IMMEDIATE

\ �������� �������
: DELETEOBJ  \ Run-time: ( addr.obj -- )
  STATE @
  IF
    LOOK-DESTROY IF POSTPONE DUP COMPILE, THEN POSTPONE FREE POSTPONE THROW
  ELSE
    LOOK-DESTROY IF OVER >R EXECUTE R> THEN FREE THROW
  THEN
; IMMEDIATE

PREVIOUS  \ End of the MicroClass private scope
