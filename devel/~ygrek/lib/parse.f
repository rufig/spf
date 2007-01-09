REQUIRE { lib/ext/locals.f

\ S" createdoes>" 6 /GIVE -> S" does>" S" create"
: /GIVE { a u n -- a+n u-n a n }
    u n < IF u -> n THEN

    a n + 
    u n -
    a
    n ;

: NUMBER ( a u -- n -1 | 0 )
  0 0 2SWAP >NUMBER NIP IF 2DROP FALSE ELSE D>S TRUE THEN ; 
