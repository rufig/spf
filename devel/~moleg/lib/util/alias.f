\ 03-11-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ алиасы в СПФе.

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

\ создать слово, ассоциируемое с кодом другого слова.
: ALIAS ( | BaseName AliasName --> ) ' NextWord SHEADER LAST-CFA @ ! ;

\ ALIAS - это простой заголовок слова, связанный с чужим кодом.
\ в принципе следующие примеры аналогичны:
\  : ;; ( --> ) [COMPILE] ; ; IMMEDIATE
\  ALIAS ; ;; IMMEDIATE
\ за тем исключением, что ALIAS займет меньше места и будет работать
\ чуточку быстрее.
\ ВНИМАНИЕ: флаги базового слова не наследуются, так что, если вы хотите
\ создать алиас слова немедленного исполнения, дописывайте после IMMEDIATE

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ : proba 0x123DFE76 ;
      ALIAS proba test        \ создается имя test,
      test proba <> THROW     \ ассоциируемое с кодом слова proba
S" passed" TYPE
}test



