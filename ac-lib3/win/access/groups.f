REQUIRE { ~ac/lib/locals.f
REQUIRE UNICODE> ~ac/lib/win/com/com.f

WINAPI: NetLocalGroupEnum NETAPI32.DLL
WINAPI: NetUserEnum  NETAPI32.DLL

: ForEachGroup { xt \ totalentries entriesread bufptr -- }
  0 ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  0 ( level) 0 ( server)
  NetLocalGroupEnum 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
;
: ForEachUser { xt \ totalentries entriesread bufptr -- }
  0 ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  0 ( filter ) 0 ( level) 0 ( server)
  NetUserEnum 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
;
: TESTDUMP ( addr -- )
  UASCIIZ> UNICODE> TYPE CR
\  16 DUMP
;
' TESTDUMP ForEachGroup
' TESTDUMP ForEachUser
