REQUIRE InVoc{ ~micro/lib/voc.f

InVoc{ Tracer
  H-STDOUT VALUE TracerFile
  10 VALUE MaxDEPTH
  CHAR | VALUE IndentChar
  2 VALUE IndentSize
  VARIABLE Compile  Compile 0!
  VARIABLE Trace    Trace 0!

  InVoc{ Private
    VARIABLE Indent
    Indent 0!
    : .S
      H-STDOUT >R TracerFile TO H-STDOUT
      SP@ DEPTH 2 - CELLS +
      DEPTH 1- MaxDEPTH MIN 0 ?DO
        DUP @ .
        4 -
      LOOP
      DROP
      R> TO H-STDOUT
    ;
    
    : .Indent
      Indent @ 0 ?DO
        IndentChar EMIT
        IndentSize 1- SPACES
      LOOP
    ;

    : DoTrace ( xt -- )
      CREATE ,
      DOES>
        Trace @ IF
          @ EXECUTE
        ELSE
          DROP
          2DROP
        THEN
    ;

    :NONAME ( caddr1 caddr2 -- )
      H-STDOUT >R TracerFile TO H-STDOUT
      .Indent ." > " VOC-NAME. ."  " COUNT TYPE ."  "
      .S
      CR
      1 Indent +!
      R> TO H-STDOUT
    ; DoTrace In
    
    :NONAME ( caddr1 caddr2 -- )
      H-STDOUT >R TracerFile TO H-STDOUT
      -1 Indent +!
      .Indent ." < " VOC-NAME. ."  " COUNT TYPE ."  "
      .S
      CR
      R> TO H-STDOUT
    ; DoTrace Out

    : _: : ;
  }PrevVoc
  >> Private  
    Public{
      _: :
        _:
        Compile @ IF
          LATEST NAME>CSTRING POSTPONE LITERAL CURRENT @ POSTPONE LITERAL POSTPONE In
        THEN
      ;
      
      _: ;
        Compile @ IF
          LATEST NAME>CSTRING POSTPONE LITERAL CURRENT @ POSTPONE LITERAL POSTPONE Out
        THEN
        POSTPONE ;
      ; IMMEDIATE
    }Public
  <<
}PrevVoc

