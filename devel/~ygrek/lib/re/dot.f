\ $Id$
\ Представление структуры RE в виде dot диаграммы

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE DOT-LINK ~ygrek/lib/dot.f

\ -----------------------------------------------------------------------

MODULE: regexp

: STATE>S { nfa -- a u }
   nfa .c @ STATE_SPLIT = IF S"  " EXIT THEN
   nfa .c @ STATE_FINAL = IF S" final" EXIT THEN
   nfa .c @ STATE_MATCH_ANY = IF S" any" EXIT THEN
   nfa .c @ STATE_SPACE_CHAR = IF S" space" EXIT THEN
   nfa .c @ STATE_ANCHOR_BOL = IF S" BOL" EXIT THEN
   nfa .c @ STATE_ANCHOR_EOL = IF S" EOL" EXIT THEN
   nfa .c @ [CHAR] \ = IF S" \\" EXIT THEN
   nfa .c @ BL 1+ < IF nfa .c @ <# [CHAR] ) HOLD S>D #S S" ascii(" HOLDS #> EXIT THEN
   nfa .c 1 ;

: (dot-draw) { from nfa | s1 s2 -- }
   nfa " {n}" DUP STR@ nfa STATE>S DOT-LABEL STRFREE
   from " {n}" -> s1  nfa " {n}" -> s2
   s1 STR@ s2 STR@ DOT-LINK
   s1 STRFREE s2 STRFREE
   nfa re_visited member? IF EXIT THEN
   nfa re_visited vcons TO re_visited
   nfa .out1 @ ?DUP IF nfa SWAP RECURSE THEN
   nfa .out2 @ ?DUP IF nfa SWAP RECURSE THEN ;

: dot-draw ( nfa -- ) clean-visited 0 SWAP (dot-draw) clean-visited ;

: find-finalstate ( nfa -- nfa2 ) BEGIN DUP .out1 @ WHILE .out1 @ REPEAT ;

EXPORT

\ представить RE в виде dot-диаграммы в файле a u
\ a1 u1 - символьное представление регэкспа (для надписи)
: dottify ( a1 u1 re a u -- )
   dot{
    DOT-CR S" rankdir=LR;" DOT-TYPE
    .nfa @
    DUP find-finalstate { last }
    ( nfa ) dot-draw

    \ 0 - стартовая вершина
    S" 0" S" box" DOT-SHAPE
    S" 0" 2SWAP DOT-LABEL

    \ last - финальная вершина
    " {#last}"
    DUP STR@ S" box" DOT-SHAPE
        STRFREE

   }dot ;

\ ? - флаг успеха
: dotto: ( a u "name" -- ? )
   2DUP
   ['] BUILD-REGEX CATCH
   IF
    2DROP
    2DROP
    PARSE-NAME 2DROP
    FALSE
   ELSE
    >R R@ PARSE-NAME dottify R> FREE-REGEX
    TRUE
   THEN ;

;MODULE
