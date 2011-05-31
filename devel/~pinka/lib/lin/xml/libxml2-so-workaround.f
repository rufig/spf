( see also:
  ~ac/lib/ns/ns.f
  ~ac/lib/ns/so-xt.f
  ~pinka/spf/ffi/core.f
)

REQUIRE STHROW ~pinka/spf/sthrow.f

: EXEC-FOREIGN-C11 ( x1 ptr -- x2 )
  OVER >R EXECUTE RDROP
;

\ Order: i*x libxml2 libxslt

GET-ORDER 2 PICK CONSTANT libxml2 NDROP

: find_xmlFree ( -- ptr|0 )
  S" xmlFree" libxml2 DL::SEARCH-WORDLIST 0= IF 0 THEN
;

VARIABLE _xmlFree ..: AT-PROCESS-STARTING _xmlFree 0! ;..

: func_xmlFree ( -- entry_point|0 )
  _xmlFree @ DUP IF @ EXIT THEN DROP
  find_xmlFree DUP IF DUP _xmlFree ! @ EXIT THEN
  0
;
: real_xmlFree ( addr 1 -- x )
  DROP func_xmlFree DUP IF EXEC-FOREIGN-C11 EXIT THEN DROP
  S" libxml2 xmlFree is not found" STHROW
;
