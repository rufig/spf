\
\ Вывод XML тегов бэктрекингом
\
\ На прямом ходе выводится открывающий тэг, при откате - закрывающий.

REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE STR@ ~ac/lib/str5.f

0 VALUE counter
0 VALUE indent#

: line CR indent# SPACES ;

: tag
   2DUP
   PRO
   line " <{s}>" STYPE
   indent# 1+ TO indent#
   BACK indent# 1- TO indent# " </{s}>" STYPE TRACKING
   CONT
   ;

\ Example

: inner=> PRO 
   3 0 DO
   counter " inner{n}" DUP STR@ CONT STRFREE
   counter 1+ TO counter 
   LOOP
;

: sub=> PRO S" sub1" CONT S" sub2" CONT ;

: start
   S" start" tag
     sub=> tag inner=> tag " {counter DUP *}" STYPE ;

\EOF

Запись S" a" tag S" b" tag S" c" tag сгенерирует вложенные тэги 
 <a><b><c></c></b></a>
Чтобы получить тэги на одном уровне их надо перебирать с помощью *> <*> <* или PRO CONT 
 S" a" tag PRO S" b" tag CONT S" c" CONT
или
 S" a" tag *> S" b" tag <*> S" c" <*
даст
 <a><b></b><c></c></a> 

Тэги с атрибутами (пока?) не понятно как красиво реализовать.



