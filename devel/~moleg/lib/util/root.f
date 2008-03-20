\ 20-12-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ добавляем в СПФ словарь ROOT
\ тем, кто работал в smal32 понятно, на сколько это удобно!

 REQUIRE ALIAS    devel\~moleg\lib\util\alias.f
 REQUIRE THIS     devel\~moleg\lib\util\useful.f

VOCABULARY ROOT

 \ оставить в контексте два словаря ROOT FORTH
 : ONLY ( --> ) ONLY ROOT ALSO FORTH ;

ALSO ROOT DEFINITIONS

 ALIAS FORTH      FORTH
 ALIAS VOCABULARY VOCABULARY
 ALIAS ALSO       ALSO
 ALIAS ONLY       ONLY
 ALIAS PREVIOUS   PREVIOUS
 ALIAS ORDER      ORDER
 ALIAS WORDS      WORDS
 ALIAS WARNING    WARNING
 ALIAS WITH       WITH
 ALIAS THIS       THIS
 ALIAS SEAL       SEAL
 ALIAS UNDER      UNDER
 ALIAS RECENT     RECENT

ONLY DEFINITIONS

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ тут просто проверка на собираемость.
  S" passed" TYPE
}test

\EOF
 После подключения этой библиотечки в контексте будет находиться
 минимум два словаря: ROOT FORTH
 Данный подход удобен тем, что случайное упоминание имени произвольного
 словаря без предваряющего ALSO не приведет к катастрофическим последствиям,
 из которых можно выйти только по ctrl+c, так как в контексте будет
 всегда находиться еще один словарь, в котором находятся все слова,
 необходимые для восстановления правильного ORDER-a словарей.
 Слово ONLY после подключения данной библиотечки оставляет в контексте
 не один, а два словаря!!!
