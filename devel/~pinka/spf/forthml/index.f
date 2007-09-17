\ 18.Feb.2007
\ $Id$
( “рансл€тор ForthML [как расширение к SPF4]

»спользование
  S" url-of.f.xml" EMBODY [ i*x c-addrz u -- j*x ]
  -- создает объект по указанной модели в текущем контексте


ќграничени€
  -- пока трансл€тор не многопоточен.
)

REQUIRE EXC-DUMP2   ~pinka/spf/exc-dump.f

REQUIRE [UNDEFINED]     lib/include/tools.f
REQUIRE EQUAL           ~pinka/spf/string-equal.f
REQUIRE AsQName         ~pinka/samples/2006/syntax/qname.f \ пон€тие однословных строк в виде `abc
REQUIRE getAttributeNS  ~pinka/lib/lin/xml/libxml2-dom.f
REQUIRE SPLIT-          ~pinka/samples/2005/lib/split.f
REQUIRE FINE-HEAD       ~pinka/samples/2005/lib/split-white.f
REQUIRE Require         ~pinka/lib/ext/requ.f

MODULE: forthml-support

EXPORT  CONTEXT @  CONSTANT forthml-hidden  DEFINITIONS

[UNDEFINED] &

REQUIRE GERM-A  ~pinka/spf/compiler/index.f

        [IF]    EXPORT
: & & ;
                DEFINITIONS
        [THEN]

VARIABLE cnode-a

Include cdomnode.immutable.f

EXPORT

Require gtNUMBER aliases.f \ набор синонимов

DEFINITIONS

?C-JMP TRUE TO ?C-JMP  \ включение хвостовой оптимизации: [CALL XXX][RET] --> [JMP XXX]
                       \ актуально дл€ цепочки обработчиков.

Include ttext-index.auto.f \ в виде простейшего форт-текста
\ предоставл€ет T-PLAIN -- слово дл€ трансл€ции текста,
\ €дро дл€ трансл€ции xml-дерева, переменные состо€ни€ M и STATE

..: AT-PROCESS-STARTING _document-storage 0! ;.. \ дл€  model/trans/document-context.f.xml

UNIX-LINES
Include ~pinka/fml/forthml-core.f \ базовый набор слов (правил) ForthML
DOS-LINES

: EMBODY ( i*x url-a url-u -- j*x )
\ set and restore CURFILE (spf4 specific)
  CURFILE @ >R   2DUP HEAP-COPY CURFILE !
    ['] EMBODY CATCH
  CURFILE @ FREE THROW   R> CURFILE !
    THROW
;

\ лексикон ForthML первого уровн€:
`~pinka/fml/src/rules-common.f.xml FIND-FULLNAME EMBODY
`~pinka/fml/src/rules-forth.f.xml  FIND-FULLNAME EMBODY

\ расширение лексикона ForthML до второго уровн€:
`~pinka/model/lib/string/match-white.f.xml  FIND-FULLNAME EMBODY
`~pinka/model/trans/rules-std.f.xml         FIND-FULLNAME EMBODY
`~pinka/model/trans/split-line.f.xml        FIND-FULLNAME EMBODY
`~pinka/model/trans/rules-ext.f.xml         FIND-FULLNAME EMBODY
`~pinka/model/trans/rules-string.f.xml      FIND-FULLNAME EMBODY

\ отображение URI-баз (например, http://forth.org.ru/ на каталог локальной файловой системы)
`~pinka/model/trans/xml-uri-map.f.xml       FIND-FULLNAME EMBODY


TO ?C-JMP  \ оставл€ть включенным нельз€, т.к. дает глюки дл€ r-чувствительных слов.


EXPORT

`EMBODY             2DUP aka

`CONTAINS           2DUP aka
`STARTS-WITH        2DUP aka
`ENDS-WITH          2DUP aka
`SUBSTRING-AFTER    2DUP aka
`SUBSTRING-BEFORE   2DUP aka
`SPLIT-             2DUP aka
`SPLIT              2DUP aka
`MATCH-STARTS       2DUP aka


`IS-WHITE           2DUP aka
`FINE-HEAD          2DUP aka
`FINE-TAIL          2DUP aka
`SPLIT-WHITE-FORCE  2DUP aka
`-SPLIT-WHITE-FORCE 2DUP aka
`UNBROKEN           2DUP aka
`WORD|TAIL          2DUP aka

`T-PLAIN            2DUP aka

;MODULE 
\ ALSO forthml-support
