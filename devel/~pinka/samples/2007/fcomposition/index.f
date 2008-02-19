REQUIRE EMBODY    ~pinka/spf/forthml/index.f


: import-word ( addr u -- ) 2DUP aka ;


`tc-host.f.xml FIND-FULLNAME2 EMBODY

  startup FIRE-EVENT

`index.f.xml EMBODY

target-wl ALSO!

CR ORDER
WORDS 



\EOF

\ FORTHPROC-WL STRINGS-WL STORAGE-WL HEAP-WL FILES-WL  5 SET-ORDER

spf ~pinka/lib/words.f FORTH-WORDLIST ReversWL WORDS BYE >words.txt
