\ Формирования строки текущей даты

REQUIRE TIME&DATE lib\include\facil.f

: MONTH,
   NextWord HERE OVER ALLOT
   SWAP CMOVE
;

CREATE MONTHS
MONTH, Jan
MONTH, Feb
MONTH, Mar
MONTH, Apr
MONTH, May
MONTH, Jun
MONTH, Jul
MONTH, Aug
MONTH, Sep
MONTH, Oct
MONTH, Nov
MONTH, Dec

: MONTH ( n -- addr u )
    1- 3 * MONTHS + 3
;

: DATE ( day mt year -- addr u )
   0 <# # # # # 2DROP [CHAR] . HOLD MONTH DROP 2+ DUP C@ HOLD 1- DUP C@ HOLD 1- C@ HOLD 0
       [CHAR] . HOLD # # 2DROP 0 0 #>
;

: NOWADAYS ( -- addr u )
   TIME&DATE 2>R >R
   2DROP DROP R> 2R>
   DATE
;

\ NOWADAYS TYPE
