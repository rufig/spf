REQUIRE DirObject ~day\joop\win\dirobject.f
REQUIRE ADD-CONST-VOC ~day\wincons\wc.f

  DirObject :new VALUE aFile       \ делать объект класса DirObject

  
  : SIMPLEDIR ( -- )
  \ Вывести список только директорий в c:
        S" c:\*" aFile :findFirst
        IF      BEGIN
                        FILE_ATTRIBUTE_DIRECTORY aFile :getAttr
                        = IF  CR  aFile :showFile THEN
                        aFile  :findNext 0=
                UNTIL   CR 
                aFile :findClose DROP
        THEN    ;




SIMPLEDIR
