\ $Id$

( see ~pinka/lib/multi/Critical.f )

\ CS == Critical Section
\ no such thing in pthreads - need to define other lexicon

REQUIRE LINUX-CONSTANTS lib/posix/const.f

MODULE: pthread_mutex

SIZEOF_PTHREAD_MUTEX_T CONSTANT /CS
CREATE CS-LIST 0 ,
CREATE attr SIZEOF_PTHREAD_MUTEXATTR_T ALLOT
: init-attr 
  (( attr )) pthread_mutexattr_init DROP
  (( attr PTHREAD_MUTEX_RECURSIVE_NP )) pthread_mutexattr_settype DROP \ check 0 here
;
init-attr

: MAKE-CS, ( -- )  \  make on HERE
  HERE
  /CS ALLOT
  (( DUP attr )) pthread_mutex_init DROP
  CS-LIST @ ,
  CS-LIST !
;

EXPORT

: CREATED-CS ( name-a name-u -- )  \  name ( -- cs )
  CREATED MAKE-CS,
;
: CREATE-CS ( "name" -- )  \  name ( -- cs )
\ Создать критическую секцию с именем name
  CREATE MAKE-CS,
;

DEFINITIONS

: ActivateCSs ( -- )
  CS-LIST @     BEGIN
  DUP           WHILE
  (( DUP attr )) pthread_mutex_init DROP
  /CS + @   REPEAT DROP
;
: DeactivateCSs ( -- )
  CS-LIST @     BEGIN
  DUP           WHILE
  (( DUP )) pthread_mutex_destroy DROP
  /CS + @   REPEAT DROP
;
..: AT-PROCESS-STARTING   init-attr ActivateCSs    ;..
..: AT-PROCESS-FINISHING  DeactivateCSs  ;..

EXPORT

: ENTER-CS ( cs -- )
\ Войти (завладеть) в критическую секцию cs 
\ Пока какой-либо поток владеет критической секцией, 
\  остальные будут ждать внутри ENTER-CS
    1 <( )) pthread_mutex_lock DROP
;
: LEAVE-CS ( cs -- )
\ Покинуть (освободить) критическую секцию cs
    1 <( )) pthread_mutex_unlock DROP
;

: NEW-CS ( -- cs )
  /CS ALLOCATE THROW
  (( DUP attr )) pthread_mutex_init DROP
;
: DEL-CS ( cs -- )
  (( DUP )) pthread_mutex_destroy DROP
  FREE THROW
;

;MODULE
