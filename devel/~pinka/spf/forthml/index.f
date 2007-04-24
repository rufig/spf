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
REQUIRE AsQName         ~pinka/samples/2006/syntax/qname.f \ пон€тие однословных строк в виде `abc
REQUIRE getAttributeNS  ~pinka/lib/lin/xml/libxml2-dom.f
REQUIRE SPLIT-          ~pinka/samples/2005/lib/split.f
REQUIRE FINE-HEAD       ~pinka/samples/2005/lib/split-white.f
REQUIRE Require         ~pinka/lib/ext/requ.f


MODULE: forthml-support

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

`~pinka/fml/src/rules-common.f.xml FIND-FULLNAME EMBODY
`~pinka/fml/src/rules-forth.f.xml  FIND-FULLNAME EMBODY

TO ?C-JMP  \ оставл€ть включенным нельз€, т.к. дает глюки местами

EXPORT

`EMBODY `EMBODY aka

;MODULE 
\ ALSO forthml-support
