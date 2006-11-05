: asTib ( addr u -- )  #TIB ! TO TIB >IN 0! ;

: <TIB ( a u --) R> >IN @ >R #TIB @ >R TIB >R >R asTib ( >IN 0!) ;
: TIB> ( --)  R> R> R> asTib R> >IN ! >R ;

\ : asTib ( addr u -- )  #TIB ! TO TIB >IN 0! ;

\ : <TIB ( a u --) R> >IN @ >R #TIB @ >R TIB >R >R asTib >IN 0! ;
\ : TIB> ( --)  R> R> R> asTib R> >IN ! >R ;
