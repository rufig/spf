( 03.Mar.2000 Andrey Cherezov )

( Сокращение записи:
  VOCABULARY TextMbox
  GET-CURRENT ALSO TextMbox DEFINITIONS
  ...
  PREVIOUS SET-CURRENT

  теперь можно писать так:
  InVoc{ TextMbox
  ...
  }PrevVoc

  Также можно использовать слова
  Public{
  : WORD1 ... ;
  }Public
  для "экспорта" определений во внешний словарь
)

: InVoc{ ( "vocabulary" -- current )
\ следующие слова будут компилироваться в словарь "vocabulary"

  >IN @ ['] ' CATCH
  IF >IN ! VOCABULARY GET-CURRENT
     ALSO LATEST NAME> EXECUTE DEFINITIONS
  ELSE 
     NIP GET-CURRENT SWAP ALSO EXECUTE DEFINITIONS
  THEN
;

: }PrevVoc ( current -- )
\ вернуть ORDER в состояние перед InVoc

  PREVIOUS SET-CURRENT
;

: Public{ ( current1 -- current1 current2 )
\ следующие слова будут видны извне текущего словаря (в родительском словаре)

  GET-CURRENT OVER SET-CURRENT
;

: }Public ( curren1 current2 -- current1 )

  SET-CURRENT
;