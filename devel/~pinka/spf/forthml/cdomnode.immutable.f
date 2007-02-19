\ Feb.2007

\ ƒает набор слов доступа к текущему xml-узлу (cnode);
\ имена слов, работающих с текущим узлом, имеют первую букву заглавной,
\ в отличии от аналогичных слов DOM, ожидающих узел €вным параметром.

\ “ребует €чейку cnode-a

TEMP-WORDLIST GET-CURRENT   OVER ALSO CONTEXT ! DEFINITIONS

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

`getAttribute   wrap
`getAttributeNS wrap
`hasAttribute   wrap
`hasAttributeNS wrap

\ : mount ( node -- ) cnode-a ! ;
\ : dismount ( -- node ) cnode-a @ cnode-a 0! ;

: cnode  ( -- node ) cnode-a @ ;
: cnode! ( node -- ) cnode-a ! ;

PREVIOUS FREE-WORDLIST