\ Пример: создание нескольких слов во время исполнения через
\ DOES> внутри START{ ... }EMERGE

REQUIRE START{ ~profit/lib/bac4th.f

: ABC-VOC ( "name -- )
CURRENT @
VOCABULARY 
LAST @ NAME> ALSO EXECUTE DEFINITIONS
S" a" CREATED
START{ DOES> DROP  CR S" a" TYPE }EMERGE
S" b" CREATED
START{ DOES> DROP  CR S" b" TYPE }EMERGE
S" c" CREATED
START{ DOES> DROP  CR S" c" TYPE }EMERGE
PREVIOUS SET-CURRENT ;

ABC-VOC abc

ALSO abc
a b c