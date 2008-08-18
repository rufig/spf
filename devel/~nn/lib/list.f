REQUIRE ON ~nn/lib/onoff.f

USER DoListEXIT?
USER AddedNode
: DoListEXIT DoListEXIT? ON ;

: DoList ( xt list -- )
  SWAP >R 
  BEGIN
    @ ?DUP
  WHILE
    DUP R@ EXECUTE
    DoListEXIT? @ IF R> 2DROP DoListEXIT? 0! EXIT THEN
  REPEAT RDROP
;

: NodeValue CELL+ @ ;

: FreeList ( list -- )
  DUP @
  BEGIN
    ?DUP
  WHILE
    DUP @ SWAP FREE THROW
  REPEAT
  0!
;

: AddNode ( value list -- )
  2 CELLS ALLOCATE THROW >R
  SWAP R@ CELL+ !
  DUP @ R@ !
  R@ SWAP !
  R> AddedNode !
;

: AppendNode ( node list -- )
    BEGIN DUP @ ?DUP WHILE NIP REPEAT 
    AddNode ;

\ Delete all entries of value from a list
: DelNode ( value list --)
    SWAP >R
    BEGIN DUP @ ?DUP WHILE
      DUP NodeValue R@ =
      IF ( list node --)
        DUP @ SWAP FREE THROW
        OVER !
      ELSE
        NIP
      THEN
    REPEAT
    DROP RDROP
;

: InList? ( value list -- node/0)
    SWAP >R @
    BEGIN ?DUP WHILE
      DUP NodeValue R@ =
      IF RDROP EXIT THEN
      @
    REPEAT
    RDROP FALSE
;

