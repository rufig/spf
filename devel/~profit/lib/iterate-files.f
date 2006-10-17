REQUIRE /TEST ~profit/lib/testing.f
REQUIRE FIND-FILES-R ~ac/lib/win/file/findfile-r.f

: ITERATE-FILES ( addr u depth --  ) FIND-FILES-DEPTH !  R> FIND-FILES-R ;
: ITERATE-DIRS ( addr u depth --  ) FIND-FILES-DEPTH !  R> FIND-DIRS-R ;

/TEST
: allFilesInC S" c:" 1 ITERATE-FILES ( addr u data flag --> \ <-- ) 2DROP CR TYPE ;
allFilesInC