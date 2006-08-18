\ word for allocation of a dynamic 1-D array memory
\ typical usage:  & a{ #elements }malloc

0 VALUE malloc-fail?

: cell_size ( addr -- n )      >BODY CELL+ @ ;       \ gets array cell size

                                      \ ---------------------
: }malloc ( addr n -- )               \ | size | data area
                                      \ ---------------------
          OVER cell_size DUP >R *        \ save extra cell_size on rstack
          \ now add space for the cell_size entry
          CELL+ ALLOCATE 
	  TO malloc-fail?
          OVER >BODY !

          \ now store the cell size in the beginning of the block
          >BODY @ R> SWAP !
;

\ word to release dynamic array memory, typical usage:  & a{ }free

: }free   ( addr -- )
        >BODY DUP
        @ FREE
        TO malloc-fail?
        0 SWAP !
;

\ word for allocation of a dynamic 2-D array memory
\ typical usage:  & a{{ #rows #cols }}malloc
                                       \  -------------------------
: }}malloc ( addr n m -- )             \  | m | size | data area 
                                       \  -------------------------
          2 PICK cell_size DUP
          >R OVER >R         \ save extra cell_size and m on rstack
          * *                \ calculate the space needed
          \ now add space for the cell_size entry and m
          CELL+ CELL+ ALLOCATE
          TO malloc-fail?

          SWAP OVER CELL+ SWAP >BODY !    \ store pointer to allocated space
                                          \ Note: pointing to size field not m

          \ now store m and cell size in the beginning of the block
          R> OVER !
          R> SWAP CELL+ !

;

: }}free    }free ;

