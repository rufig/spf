REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`list-plain.f.xml EMBODY
`data-space.f.xml EMBODY      \ - need SCZ,
5000 ALLOCATED DATASPACE!
`wordlist-plain.f.xml EMBODY  \ - need FIND-WORDLIST

`context-native.f.xml EMBODY

  : NLIST ( w -- ) ['] . SWAP FOREACH-LIST-VALUE ;
  : NAMING- ( xt D-name -- ) CURRENT @ RELATE-WORDLIST ;
  10 CELLS ALLOCATED ASSUME-SCOPE

  VARIABLE a

  a PUSH-DEVELOP
  123 `aaa NAMING-
  `aaa POP-DEVELOP FIND-WORDLIST . . CR

  CR
  VARIABLE b
  b PUSH-DEVELOP
    112 `aa NAMING-
    a PUSH-DEVELOP
      `aa I-NATIVE . . CR
      111 `aa NAMING-
      `aa I-NATIVE . . CR
    BEGIN-EXPORT
      `aa I-NATIVE . . CR
      222 `bb NAMING-
      .( a: ) a NLIST CR
      .( b: ) b NLIST CR
    END-EXPORT .( end export ) CR
      .( a: ) a NLIST CR
      .( b: ) b NLIST CR
    DROP-DEVELOP
    `bb I-NATIVE . . CR
  DROP-DEVELOP
