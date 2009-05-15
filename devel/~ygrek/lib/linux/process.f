\ $Id$
\ see ~ac/lib/win/process/process.f

REQUIRE ANSI-FILE lib/include/ansi-file.f

: (forkexec) ( az -- x ior )
  (()) fork ?DUP
  IF
    NIP
    1 <( 0 0 )) waitpid ?ERR
  ELSE
    >R S" /bin/sh" DROP DUP 2 <( S" -c" DROP R> 0 )) execlp \ never returns
  THEN ;

: StartAppWait ( a u -- ? ) ANSI-FILE::>ZFILENAME DROP (forkexec) NIP 0 = ;

\ S" date" StartAppWait .

