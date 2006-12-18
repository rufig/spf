\ Temporary hex, and temporary decimal.  "h#" interprets the next word
\ as though the base were hex, regardless of what the base happens to be.
\ "d#" interprets the next word as though the base were decimal.
\ "o#" interprets the next word as though the base were octal.
\ "b#" interprets the next word as though the base were binary.

\  Also, words to stash and set, and retrieve, the base during execution
\     of a word in which they're used.  The words of the form  push-<base>
\     (where <base> is hex, decimal, etcetera) does the equivalent of
\     base @ >r <base>     The word  pop-base  recovers the old base...

REQUIRE S>NUM ~nn/lib/s2num.f

: #:  \ name  ( base -- )  \ Define a temporary-numeric-mode word
   CREATE C, IMMEDIATE
   DOES>
   BASE @ >R  C@ BASE !
   PARSE-NAME S>NUM
   STATE @ IF LIT, THEN
   R> BASE !
;


\ The old names; use h# and d# instead
10 #: TD
16 #: TH

 2 #: B#	\ BINARY NUMBER
 8 #: O#	\ OCTAL NUMBER
10 #: D#	\ DECIMAL NUMBER
16 #: H#	\ HEX NUMBER


: PUSH-BASE:  \ name   ( base -- )  \  Define a base stash-and-set word
   CREATE C,
   DOES>  R> BASE @ >R >R C@ BASE !
;


\  Stash the old base on the return stack and set the base to ...
10 PUSH-BASE:  PUSH-DECIMAL
16 PUSH-BASE:  PUSH-HEX

 2 PUSH-BASE:  PUSH-BINARY
 8 PUSH-BASE:  PUSH-OCTAL

\  Retrieve the old base from the return stack

: POP-BASE ( -- )  R> R> BASE ! >R ;

\EOF

DECIMAL
 B# 101010 .

: TH-TEST
  PUSH-OCTAL
   8 .
  POP-BASE
   8 .
;

TH-TEST




