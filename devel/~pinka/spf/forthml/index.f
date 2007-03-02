\ 18.Feb.2007
( “рансл€тор ForthML

»спользование
  S" url-of.f.xml" EMBODY
  -- создает объект по указанной модели в текущем контексте


ќграничени€
  -- пока трансл€тор не многопоточен.
)

\ REQUIRE EXC-DUMP2   ~pinka/spf/exc-dump.f
REQUIRE [UNDEFINED]     lib/include/tools.f
REQUIRE AsQName         ~pinka/samples/2006/syntax/qname.f \ пон€тие однословных строк в виде `abc
REQUIRE getAttributeNS  ~pinka/lib/lin/xml/libxml2-dom.f
REQUIRE FINE-HEAD       ~pinka/samples/2005/lib/split-white.f
REQUIRE Require         ~pinka/lib/ext/requ.f

MODULE: forthml-support

REQUIRE GERM-A  ~pinka/spf/compiler/index.f

VARIABLE cnode-a

Include cdomnode.immutable.f

EXPORT

Require gtNUMBER aliases.f \ набор синонимов

DEFINITIONS

Include ttext-index.auto.f \ в виде простейшего форт-текста
\ предоставл€ет T-TEXT -- слово дл€ трансл€ции текста,
\ €дро дл€ трансл€ции xml-дерева и переменную STATE

Include ~pinka/fml/forthml-rules.f \ в виде простейшего форт-текста
\ набор правил дл€ трансл€ции ForthML 

EXPORT

`EMBODY `EMBODY aka

;MODULE