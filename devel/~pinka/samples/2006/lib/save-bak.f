\ 21.Feb.2006
\ $Id$

REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE RENAME-FILE-OVER ~pinka/lib/FileExt2.f
REQUIRE COPY-FILE-OVER   ~pinka/lib/FileExt.f

: FILE.BAK ( a u -- a u a1 u1 )
  2DUP <# S" .bak" HOLDS HOLDS 0. #>
;
: FILE.NEW ( a u -- a u a1 u1 )
  2DUP <# S" .new" HOLDS HOLDS 0. #>
;
: OCCUPY-SAFE ( a u file-a file-u -- )
  2DUP FILE-EXIST IF 2DUP FILE.BAK COPY-FILE-OVER THROW THEN
  FILE.NEW   2SWAP 2>R 2DUP 2>R   OCCUPY
  2R> 2R> RENAME-FILE-OVER THROW
;
: ROLL-BAK-CATCH ( file-a file-u -- ior )
  FILE.BAK 2SWAP RENAME-FILE-OVER
;
: ROLL-BAK ( file-a file-u -- )
  ROLL-BAK-CATCH THROW
;
