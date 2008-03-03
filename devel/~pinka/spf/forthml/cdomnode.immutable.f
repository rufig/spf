\ Feb.2007 ruv
\ $Id$

\ Дает набор слов доступа к текущему xml-узлу (cnode);
\ имена слов, работающих с текущим узлом, имеют первую букву заглавной,
\ в отличии от аналогичных слов DOM, ожидающих узел явным параметром.

\ Требует ячейку cnode-a

TEMP-WORDLIST GET-CURRENT   OVER ALSO CONTEXT ! DEFINITIONS

\ Слова wrap и wrap2 служат для создания оберток
\ к словам,  имеющим соответственно 
\ сигнатуру ( i*x node -- j*x ) и ( i*x node -- j*x node|0 ).
\ Входная строка-имя используется в режиме R/W.

: wrap ( a u -- )
  CONCEIVE
    `cnode-a & EXEC,
    `@       & EXEC,
    2DUP     & EXEC,
  SWAP DUP C@ 32 - OVER C! SWAP
  BIRTH NAMING
;
: wrap2 ( a u -- )
  CONCEIVE
    `cnode-a & EXEC,
    `@       & EXEC,
     2DUP    & EXEC,
    `cnode-a & EXEC,
    `!       & EXEC,
  SWAP DUP C@ 32 - OVER C! SWAP
  BIRTH NAMING
;

SET-CURRENT

`nodeType       wrap
`nodeName       wrap
`nodeValue      wrap
\ `ownerDocument  wrap  \ он дает doc, а не node
`prefix         wrap
`namespaceURI   wrap

`parentNode     wrap2
`firstChild     wrap2
`lastChild      wrap2
`nextSibling    wrap2
`previousSibling wrap2

`firstChildByTagName    wrap2
`firstChildByTagNameNS  wrap2
`nextSiblingByTagName   wrap2
`nextSiblingByTagNameNS wrap2
`nextSiblingEqualNS     wrap2

`getAttribute   wrap
`getAttributeNS wrap
`hasAttribute   wrap
`hasAttributeNS wrap
`hasChildNodes  wrap
`firstChildValue wrap
`baseURI        wrap

`namespace-uri-for-prefix wrap

\ : mount ( node -- ) cnode-a ! ;
\ : dismount ( -- node ) cnode-a @ cnode-a 0! ;

: cnode  ( -- node ) cnode-a @ ;
: cnode! ( node -- ) cnode-a ! ;

: GetName ( -- a u ) `name GetAttribute ;

PREVIOUS FREE-WORDLIST
