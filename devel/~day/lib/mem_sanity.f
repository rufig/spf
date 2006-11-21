
\ ~day\lib\mem_sanity.f

0xBADC0DE CONSTANT mem_stub

: FillStub ( u addr )
    2DUP !
    mem_stub OVER CELL+ !
    + CELL+ CELL+ mem_stub SWAP !
;

: ALLOCATE ( u -- addr ior )
    DUP 12 + ALLOCATE DUP 0=
    IF
      ( u addr ior )
      >R 2DUP FillStub
      NIP CELL+ CELL+ R>
    ELSE NIP
    THEN
;

: mem_abort1
   ABORT" corrupted heap at the beginning of block"
;

: mem_abort2
   ABORT" corrupted heap at the end of block"
;

: FREE
    DUP CELL- @ mem_stub <> mem_abort1
    DUP DUP CELL- CELL- @ + @ mem_stub <> mem_abort2
    2 CELLS - FREE
;
