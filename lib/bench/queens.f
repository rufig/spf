\ QUEENS.F
\ ‡ ¤ η  ® 8-¨ δ¥ΰ§οε
\ Al.Chepyzhenko

: CARRAY ( n )        CHARS CREATE ALLOT
         ( n -- addr)       DOES> + ;

8  CARRAY Gori
8  CARRAY Verti
15 CARRAY Dio1
15 CARRAY Dio2

: Clear ( -- )
   8 0 DO 0 I Verti C! LOOP
  15 0 DO 0 I Dio1  C! LOOP
  15 0 DO 0 I Dio2  C! LOOP ;

: Check ( n -- f )
  Clear TRUE SWAP 1+ 0
  DO
      I Gori C@
      DUP Verti DUP C@
      IF
          DROP DROP DROP FALSE
      ELSE
          TRUE SWAP C!
          DUP I + Dio1 DUP C@
          IF
              DROP DROP DROP FALSE
          ELSE
              TRUE SWAP C!
              DUP 7 + I - Dio2 DUP C@
              IF
                  DROP DROP DROP FALSE
              ELSE
                  TRUE SWAP C! DROP TRUE AND
              THEN
          THEN
      THEN
  LOOP ;

: Print ( -- )
  8 0
  DO
   I Gori C@ .
  LOOP CR ;

: TRYTO ( n )
  8 0
  DO
      I OVER Gori C!
      DUP Check
      IF
          DUP 7 <
          IF   DUP 1+ RECURSE
\          ELSE …—€’     \ !!!!!!!!!!!!!
          THEN
      THEN
  LOOP
  DROP
  ;


: test ( -- )
   0 TRYTO
   ;

