REQUIRE :: ~ac/lib/win/com/samples/automation+.f

: STYPE DROP ASCIIZ> TYPE ;

: TEST { \ ie app }
  COM-init THROW

  Z" Messenger.MsgrObject" create-object THROW -> app
  app :: LocalState @
  DROP 2 =
  IF
    app :: LocalFriendlyName @
    STYPE SPACE

    app :: LocalLogonName @
    STYPE CR CR

    app :: List [0] @

    DROP FOREACH 
        OBJ-I DROP :: FriendlyName @
        STYPE SPACE
        OBJ-I DROP :: EmailAddress @
        STYPE CR
    NEXT
  ELSE ." Соединиться Messenger'ом надо сначала" THEN
  COM-destroy
;

TEST
