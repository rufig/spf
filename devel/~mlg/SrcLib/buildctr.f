REQUIRE M+ ~mlg/SrcLib/compat.f

\ Build Counter
\ Vestion 1.0
\ M.L.Gassanenko, 15.01.2001
\ File: buildctr.f
\
\ Use:
\	BUILDCTR filename.ext CONSTANT build#
\
\ The file filename.ext (created if does not exist) will
\ contain the build number, this number will be incremented
\ by 1 upon each execution of the phrase BUILDCTR filename.ext.

\ BUILDCTR ( "filename" -- u )
\ Skip leading space delimiters.  Parse filename delimited by a space.
\ If the file identified by filename exists, verify that it contains
\ only a decimal number (no non-numeric symbols permitter) and that
\ its length is not greater than the constant buildctr-max .
\ Read the contents of the file into PAD, convert the text to a number,
\ increment the number, and write the text back into the file.

\ This is an ANS Forth program requiring the wordsets:
\ CORE EXT, FILE EXT, DOUBLE
\ ( DOUBLE is not really necessary)

\ A note for beginners.
\ This is a really terrible piece of code. Never write like this.
\ I wrote one big definition to avoid interference with the application
\ name space.


BASE @ DECIMAL
1234			\ comment out or define : ?PAIRS <> ABORT" unpaired" ;

32 CONSTANT buildctr-max	\ max len of the number and the file

: BUILDCTR ( "filename" -- u )
    BASE @ >R DECIMAL

	BL WORD >R
	R@ COUNT R/O OPEN-FILE ( fid rc )			IF
	  DROP R@ COUNT R/W CREATE-FILE ( fid rc )
	  ABORT" could not open/create buildctr file"		THEN
	( fid ) >R ( r: fname fid )
	R@ FILE-SIZE ABORT" f-size err"
	( ud) OVER buildctr-max > OR				IF
	    R@ CLOSE-FILE 1 ABORT" too long buildctr file"	THEN
        ( u) >R ( r: fname fid len )
	PAD 2R@ SWAP READ-FILE SWAP R@ <> OR			IF
	    R> R@ CLOSE-FILE 1 ABORT" read err"			THEN
	0 0 PAD R> >NUMBER NIP					IF
	    R@ CLOSE-FILE 1 ABORT" wrong number format"		THEN
	R> CLOSE-FILE DROP
	( ud )

	1 M+		\ when DOUBLE wordset is present
\	DROP 1+ 0	\ when there is no DOUBLE wordset

	2DUP CR ." Build: " D. CR

	R@ COUNT W/O OPEN-FILE ( fid rc )			IF
	  DROP R@ COUNT W/O CREATE-FILE ( fid rc )
	    ABORT" could not create buildctr file"		THEN
	( fid ) R> DROP
	>R
	2DUP <# #S #> R@ WRITE-FILE
	R@ FILE-POSITION					IF
	  R> CLOSE-FILE 1 ABORT" pos error"			THEN
	R@ RESIZE-FILE
	R> CLOSE-FILE
	  ROT  ABORT" could not write to buildctr file"
	  SWAP ABORT" resize err"
	  ABORT" close err"
	DROP
    R> BASE !
;

1234 ?PAIRS		\ comment out or define : ?PAIRS <> ABORT" unpaired" ;
BASE !
