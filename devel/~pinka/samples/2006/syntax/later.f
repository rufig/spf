\ 13.Feb.2006

REQUIRE enqueueNOTFOUND ~pinka\samples\2006\core\trans\nf-ext.f 

REQUIRE AsLaterSintax ~pinka\samples\2006\syntax\later.core.f 

' AsLaterSintax enqueueNOTFOUND

\ Позднее (динамическое) связывание, синтаксис: translator.message
\ translator -- это интерфейс типа общий транслятор ( addr u -- i*x ) к некому объекту.
\ Пример:  EVALUATE.test

\EOF
\ Example

REQUIRE HASH@ ~pinka/lib/hash-table.f

small-hash VALUE params

: param ( a u -- a1 u1 )
  params HASH@
;

: test-set ( -- )
  S" value1" S" name1" params HASH!
  S" value2" S" name2" params HASH!
  ." values setted" CR
;
: test-get ( -- )
  ." name1 = " param.name1 TYPE CR
  ." name2 = " param.name2 TYPE CR
;
: test
  test-get
  test-set
  test-get
;
