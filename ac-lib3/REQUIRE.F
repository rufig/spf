( 02.08.1999 Черезов А. )

( Расширение СП-Форта функциями загрузки библиотек из унифицированных
  для SPF путей.
  
  REQUIRE слово_из_библиотеки ~автор/путь/к/библиотеке
  или
  S" слово_из_библиотеки" S" ~автор/путь/к/библиотеке" REQUIRED

  Последовательность. Сначала require пытается загрузить библиотеку
  по заданному пути, считая его полным путем к библиотеке. Удобно для
  старых библиотек. В случае неудачи делается попытка загрузить из
  пути LocalLibPath~автор/путь/к/библиотеке. В случае неудачи - должен
  загружаться [и кешироваться локально] WebLibPath~автор/путь/к/библиотеке
  но эта возможность пока не реализована [это не сложно, но придется и
  сокеты за собой тащить, или внешнюю программку запускать - я пока не 
  решил :^]
)

CREATE LocalLibPath C" e:\eserv2-forth\forth\wwwroot\" ",
CREATE WebLibPath   C" http://www.forth.org.ru/" ",

: FindWord ( addr u -- 0 | xt 1 | xt -1 )
  DUP HERE C! HERE 1+ SWAP MOVE HERE FIND  \ ох и неудобные эти "c-addr" ;)
  ?DUP IF EXIT THEN
  DROP 0
;
: LibName ( addr u -- addr2 u2 )
  DUP >R PAD SWAP MOVE
  PAD R@ + SWAP R> OVER + >R MOVE
  PAD R@ + 0! PAD R>
;
: LocalLibName ( addr u -- addr2 u2 )
  LocalLibPath COUNT LibName
;
: WebLibName ( addr u -- addr2 u2 )
  WebLibPath COUNT LibName
;
: WEB-INCLUDED ( addr u -- )
  TYPE ." - WebIncluded is'n implemented." CR -5002 THROW
;
: IncludeLib ( addr u -- ... )
  2>R
  2R@ + 0 SWAP C!
  2R@              ['] INCLUDED CATCH 0= IF 2R> 2DROP EXIT THEN 
  \ библиотеки старого типа
  2DROP \ это не имя библиотеки, а мусор после "сорвавшегося" в CATCH слова
  2R@ LocalLibName ['] INCLUDED CATCH 0= IF 2R> 2DROP EXIT THEN
  2DROP
  2R@ WebLibName   ['] WEB-INCLUDED CATCH 0= IF 2R> 2DROP EXIT THEN
  2DROP
  2R> TYPE ." - can't find library." -5001 THROW
;
: REQUIRED ( waddr wu laddr lu -- )
  2SWAP FindWord
  IF DROP 2DROP EXIT
  ELSE IncludeLib THEN
;
: REQUIRE ( "word" "libpath" -- )
  BL SKIP BL PARSE
  BL SKIP BL PARSE
  REQUIRED
;

\ Примеры:

\ REQUIRE RG_OpenKey /~ac/lib/win/registry.f

\ S" RG_OpenKey" S" /~ac/lib/win/registry.f" REQUIRED