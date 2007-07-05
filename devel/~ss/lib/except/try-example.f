REQUIRE {                  ~ac/lib/locals.f 
REQUIRE try                ~ss/lib/except/try.f 
REQUIRE WORDDEPTH          ~ss/lib/except/locals.f

: t { \ mem }
  1000000 ALLOCATE THROW -> mem
  try
    5000 Sleep DROP
    1 0 /
  finally
    mem FREE THROW
  end-try
;

: tt
  RP@ 
  try 
    ." return-depth=" RP@ - . CR
    ." GPF!->" 0 @
  except  DROP \ - код ошибки
    ." Ы?" 
    DROP \ если произошло исключение, то глубина стека = глубине стека до 
         \ до выполнения слова try
  end-try
;

: ttt  { \ var1 var2 }
  111 -> var1
  222 -> var2
  try ." (1)[try]" CR 
    ." var1=" var1 .
    BEGIN
      try  ." (2)[try]" CR 
        ." var2=" var2 .
        BEGIN
          TRUE
        WHILE
          ." var2=" var2 .
          TRUE IF ." Do err100->" 100 THROW THEN
          ." ...never go there!"
        REPEAT
      except ." (2)[except] " ." Exception! =" . CR 
        var1 . var2 . CR 
        ." Do err200->" 200 THROW 
\        ." Do nothing" CR
\        ." raising" CR raise 
        ." (2)[end-try]" CR
      end-try
    TRUE UNTIL
  finally  ." (1)[finally] "
    ." continue: var2=" var2 . OK
    var1 . var2 . CR
  ." (1)[end-try] " CR
  end-try 
;

OK
