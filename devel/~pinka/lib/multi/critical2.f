\ 18.Jan.2004  ~ruv
\ $Id$

REQUIRE WinNT?      ~ac\lib\win\winver.f
REQUIRE ENTER-CS    ~pinka\lib\multi\critical.f

WINAPI: TryEnterCriticalSection    KERNEL32.DLL

VECT ENTER-CS?  ( cs -- flag )
\ Если секция cs свободна, завладеть ей и вернуть true,
\ иначе вернуть false

' TryEnterCriticalSection TO ENTER-CS?

: ENTER-CS?(notNT) ( cs -- flag )
  ENTER-CS -1
;
: 0TRYENTERCS ( -- )
  WinNT? IF  ['] TryEnterCriticalSection
  ELSE       ['] ENTER-CS?(notNT)
  THEN        TO ENTER-CS?
;

..: AT-PROCESS-STARTING   0TRYENTERCS ;..
