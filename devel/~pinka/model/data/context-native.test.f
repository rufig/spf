REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`list-plain.f.xml EMBODY
`data-space.f.xml EMBODY      \ - need SCZ,
5000 ALLOCATED DATASPACE!
`wordlist-plain.f.xml EMBODY  \ - need FIND-WORDLIST


`context-native.f.xml EMBODY

  VARIABLE a

  a PUSH-DEVELOP

  123 `aaa CURRENT @ RELATE-WORDLIST

  `aaa POP-DEVELOP FIND-WORDLIST . . CR
  