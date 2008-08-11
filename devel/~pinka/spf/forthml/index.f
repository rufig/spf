\ 18.Feb.2007
\ $Id$
( “рансл€тор ForthML [как расширение к SPF4]

»спользование
  S" url-of.f.xml" EMBODY [ i*x c-addrz u -- j*x ]
  -- создает объект по указанной модели в текущем контексте


ќграничени€
  -- пока трансл€тор не многопоточен.
)


REQUIRE [UNDEFINED]     lib/include/tools.f
REQUIRE AsQName         ~pinka/samples/2006/syntax/qname.f \ пон€тие однословных строк в виде `abc
REQUIRE CORE_OF_REFILL  ~pinka/spf/fix-refill.f
REQUIRE Require         ~pinka/lib/ext/requ.f
REQUIRE AT-SAVING-BEFORE ~pinka/spf/storage.f

REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f


REQUIRE GET-FILE      ~ac/lib/lin/curl/curl.f
REQUIRE UNICODE>UTF8  ~ac/lib/win/com/com.f
\ здесь, чтобы не ушли в отдельный словарь вместе с lin/xml/xml.f


Require ULT             aliases.f \ набор синонимов

REQUIRE EQUAL           ~pinka/spf/string-equal.f
REQUIRE SPLIT-          ~pinka/samples/2005/lib/split.f
REQUIRE FINE-HEAD       ~pinka/samples/2005/lib/split-white.f


REQUIRE CODEGEN-WL      ~pinka/spf/compiler/index.f



\ прив€зка к libxml2 и XMLDOM -- в отдельный словарь XMLDOM-WL

CODEGEN-WL ALSO!

[UNDEFINED] getAttributeNS [IF]
`XMLDOM-WL WORDLIST-NAMED PUSH-DEVELOP

`~pinka/lib/lin/xml/libxml2-dom.f        INCLUDED

DROP-DEVELOP
[ELSE]
 `getAttributeNS FORTH-WORDLIST SEARCH-WORDLIST  [IF]
  FORTH-WORDLIST CONSTANT XMLDOM-WL              [ELSE]
 .( Wid of libxml2-dom.f is not found ) CR ABORT [THEN]
[THEN]

PREVIOUS



\ -----
\ ¬нутренности реализации в словарь forthml-support (список forthml-hidden)

CODEGEN-WL ALSO!  XMLDOM-WL  ALSO!
MODULE: forthml-support  EXPORT  CONTEXT @ CONSTANT forthml-hidden  DEFINITIONS

VARIABLE cnode-a \ текущий узел XML-документа

Include cdomnode.immutable.f  \ DOM-доступ к текущегму узлу, обход XML-дерева

;MODULE PREVIOUS PREVIOUS


?C-JMP TRUE TO ?C-JMP  \ включение хвостовой оптимизации: [CALL XXX][RET] --> [JMP XXX]
                       \ актуально дл€ цепочки обработчиков.
( prev-flag )




GET-CURRENT GET-ORDER ( ..prev-context.. )

FORTH-WORDLIST XMLDOM-WL CODEGEN-WL forthml-hidden  4 SET-ORDER  DEFINITIONS

: T-WORD-TC ( i*x addr u -- j*x )
  CODEGEN-WL     FIND-WORDLIST IF EXECUTE EXIT THEN
  FORTH-WORDLIST FIND-WORDLIST IF EXECUTE EXIT THEN
  NOTFOUND
;
: (INCLUDED-PLAIN-TC) ( i*x -- j*x )
  BEGIN PARSE-NAME DUP WHILE T-WORD-TC REPEAT 2DROP
;
: INCLUDED-PLAIN-TC ( a u -- )
  FIND-FULLNAME2 FILE ['] (INCLUDED-PLAIN-TC) EVALUATE-WITH
  \ - relative to current file
;

`ttext-index.auto.f INCLUDED-PLAIN-TC \ в виде простейшего форт-текста
\ предоставл€ет T-PLAIN -- слово дл€ трансл€ции текста,
\ €дро дл€ трансл€ции xml-дерева, переменные состо€ни€ M и STATE


..: AT-PROCESS-STARTING init-document-context ;.. \ дл€  model/trans/document-context2.f.xml
                        init-document-context \ входит в работу и здесь же


VECT T-PAT  ' T-SLIT TO T-PAT \ используетс€ при <get-name/>

`~pinka/fml/forthml-core.f Included \ базовый набор слов (правил) ForthML


\ ---
\ set and restore CURFILE on EMBODY (spf4 specific)
0 PUSH-WARNING

: EMBODY ( i*x url-a url-u -- j*x )
  CURFILE @ >R   2DUP HEAP-COPY CURFILE !
    0 ['] EMBODY RECEIVE-WITH \ делает SAVE-ERR
  CURFILE @ FREE THROW   R> CURFILE !
    THROW
;
DROP-WARNING

: _EMBODY FIND-FULLNAME EMBODY ;

\ лексикон ForthML первого уровн€:
`~pinka/fml/src/rules-common.f.xml _EMBODY
`~pinka/fml/src/rules-forth.f.xml  _EMBODY


\ расширение лексикона ForthML до второго уровн€:
`~pinka/model/lib/string/match-white.f.xml  _EMBODY
`~pinka/model/trans/rules-std.f.xml         _EMBODY
`~pinka/model/trans/split-line.f.xml        _EMBODY
`~pinka/model/trans/rules-ext.f.xml         _EMBODY
`~pinka/model/trans/rules-string.f.xml      _EMBODY



\ поддержка конструировани€ имени через "{}" в значении атрибута name
document-context-hidden PUSH-SCOPE `tpat-hidden WORDLIST-NAMED PUSH-DEVELOP
`~pinka/model/trans/tpat.f.xml              _EMBODY
DROP-DEVELOP DROP-SCOPE   `T-PAT tpat-hidden FIND-WORDLIST 0EQ THROW TO T-PAT


\ отображение URI-баз (например, http://forth.org.ru/ на каталог локальной файловой системы)
`~pinka/model/trans/xml-uri-map.f.xml       _EMBODY


FORTH-WORDLIST PUSH-CURRENT
`~pinka/model/trans/obey.f.xml              _EMBODY
DROP-CURRENT

\ экспериментальна€ поддержка shared lexicons
`~pinka/model/trans/sharedlex.f.xml         _EMBODY

..: AT-PROCESS-STARTING init-sharedlex ;..
                        init-sharedlex

FORTH-WORDLIST PUSH-CURRENT  0 PUSH-WARNING
: ORDER
  ORDER
  sharedlex-hidden::SCOPE-DEPTH IF SHAREDLEX-ORDER. THEN
;
DROP-WARNING  DROP-CURRENT



SET-ORDER SET-CURRENT

TO ?C-JMP  \ оставл€ть включенным нельз€, т.к. дает глюки дл€ r-чувствительных слов.


forthml-hidden PUSH-SCOPE

`EMBODY             2DUP aka

`CONTAINS           2DUP aka
`STARTS-WITH        2DUP aka
`ENDS-WITH          2DUP aka
`SUBSTRING-AFTER    2DUP aka
`SUBSTRING-BEFORE   2DUP aka

`MATCH-HEAD         2DUP aka

`IS-WHITE           2DUP aka
`WORD|TAIL          2DUP aka

`T-PLAIN            2DUP aka

DROP-SCOPE
