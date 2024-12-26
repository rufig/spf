\ 2024-12-27 ruv

\ see-also
\   devel/~mlg/SrcLib/ssss.f

[UNDEFINED] NDROP [IF]
: NDROP ( +n*x +n -- ) 0 ?DO DROP LOOP ;
[THEN]

: EMPTY-ORDER ( O: i*wid -- ;  S: -- )
  0 SET-ORDER
;
: ORDER-DEPTH ( O: +n.depth*wid ;  S: -- +n.depth )
  GET-ORDER DUP >R NDROP R>
;
: ORDER-TOP   ( O: wid1 ;  S: -- wid1 )
  GET-ORDER DUP IF OVER >R NDROP R> EXIT THEN -50 THROW
;
: DROP-ORDER  ( O: wid -- ;  S: -- )
  GET-ORDER DUP IF NIP 1 - SET-ORDER EXIT THEN -50 THROW
;
: PUSH-ORDER ( O: -- wid1 ;  S: wid1 -- ) \ AKA " >order "
  >R GET-ORDER R> SWAP 1+ SET-ORDER
;
: POP-ORDER ( O: wid1 -- ;  S: -- wid1 ) \ AKA " order> "
  GET-ORDER DUP IF SWAP >R 1- SET-ORDER R> EXIT THEN -50 THROW
;
: SET-ORDER-TOP  ( O: wid1 -- wid2 ;  S: wid2 -- )
  >R GET-ORDER DUP IF NIP R> SWAP SET-ORDER EXIT THEN -50 THROW
;
