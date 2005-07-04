\ Упрощенная работа с записями
\ Ю. Жиловец, 17.07.2004

REQUIRE CASE  lib/ext/case.f

MODULE: record

0 CONSTANT _at
1 CONSTANT _to
2 CONSTANT _fr

VARIABLE op  _fr op !

: compile-byte
  op @ CASE
  _fr OF POSTPONE C@ ENDOF
  _to OF POSTPONE C! ENDOF
  ENDCASE
  _fr op !  
;

: compile-word
  op @ CASE
  _fr OF POSTPONE W@ ENDOF
  _to OF POSTPONE W! ENDOF
  ENDCASE
  _fr op !  
;

: compile-dword
  op @ CASE
  _fr OF POSTPONE @ ENDOF
  _to OF POSTPONE ! ENDOF
  ENDCASE
  _fr op !  
;

: compile-access-code
  DOES>
  DUP @ ( len) SWAP CELL+ @ ( off)
  [COMPILE] LITERAL POSTPONE +
  CASE
  1 OF compile-byte ENDOF
  2 OF compile-word ENDOF
  4 OF compile-dword ENDOF
\ ничего не добавляем, полученный код просто оставит адрес
  ENDCASE
;

: field ( off1 # -- off2)
  CREATE 2DUP 0 MAX , ,
  compile-access-code 
  ABS + IMMEDIATE
;

EXPORT

: RECORDEX: ( ->bl; off1 -- a off2)
  CREATE HERE SWAP 0 , DOES> @ 
;

: RECORD: ( ->bl; -- a off) 0 RECORDEX: ;

: RECORD; ( a off -- ) SWAP ! ;

: RECORDEX;  RECORD; ;

: =>  _to op ! ; IMMEDIATE
: AT  _at op ! ; IMMEDIATE

: cell  4 field ;
: word  2 field ;
: byte  1 field ;
: bytes NEGATE field ;

: DWORD cell ;
: HWND  cell ;
: INT   cell ;
: UINT  cell ;
: LPSTR cell ;
: HICON cell ;
: _WORD word ;
: BYTE  byte ;
: TCHAR bytes ;
: POINT 8  bytes ;
: RECT  16 bytes ;
: GUID  16 bytes ;

;MODULE
