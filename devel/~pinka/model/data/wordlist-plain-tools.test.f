REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`list-plain.f.xml EMBODY

`data-space.f.xml EMBODY

`wordlist-plain.f.xml EMBODY
`wordlist-plain-tools.f.xml EMBODY


  5000 ALLOCATED DATASPACE!


  VARIABLE A

  VARIABLE B

  VARIABLE C


  1 `w-1 A RELATE-WORDLIST
  2 `w-2 A RELATE-WORDLIST

  3 `w-3 B RELATE-WORDLIST
  4 `w-4 B RELATE-WORDLIST

  .( The A contains: )  A NLIST CR
  .( The B contains: )  B NLIST CR

  A C APPEND-WORDLIST
  B C APPEND-WORDLIST

  A B APPEND-WORDLIST

  .( The B contains: )  B NLIST CR
  .( The C contains: )  C NLIST CR
