\ 30.Mar.2004 Tue 23:26 ruv
\ 19.Aug.2004 Thu 21:30 переписанно.
\ $Id$

\ Обсуждение имен  -WITH  см.:
\ From: Michael Gassanenko <mlg@forth.org>
\ To: sp-forth@egroups.com
\ Date: Sat, 23 Dec 2000 07:52:01 +0300
\ Subject: Re: [sp-forth] EVALUATE-WITH (filtered)
\ Message-ID: <3A442F71.8C7830DC@forth.org>

REQUIRE [UNDEFINED]  lib\include\tools.f

[UNDEFINED] INCLUDED-WITH [IF]

\  по аналогии со словами INCLUDED и EVALUATE-WITH 

: INCLUDED-WITH ( a u  xt  -- )
\ Сохранить спецификации текущие входного потока.
\ Установить входной поток в соответствии с идентификатором источника a u
\ (это значит, что REFILL берет данные из указанного источника).
\ Выполнить xt.
\ Восстановить спецификации входного потока.
\ Другие изменения стека определяются заданным xt словом.
\ Если произошло исключение, спецификации входного потока
\ должны быть такими же, как до вызова этого слова.
  -ROT
  CURFILE @ >R
  2DUP R/O OPEN-FILE-SHARED THROW >R
  HEAP-COPY CURFILE !
  R@ SWAP RECEIVE-WITH ( fileid xt -- ior )
  R> CLOSE-FILE     SWAP
  CURFILE @ FREE    SWAP
  R> CURFILE !      THROW THROW THROW
;
[THEN]

[UNDEFINED] INCLUDED-LINES-WITH [IF]
: TranslateFlowWith ( xt -- )
  >R BEGIN REFILL WHILE R@ EXECUTE REPEAT RDROP
;
: INCLUDED-LINES-WITH ( a u  xt  -- )
\ Также, как INCLUDED-WITH,
\ но выполняет xt после каждого заполнения входного буфера.
  -ROT ['] TranslateFlowWith INCLUDED-WITH
;
[THEN]

[UNDEFINED] INCLUDE-FILE-WITH [IF]

\ по аналогии со словом INCLUDE-FILE 

: INCLUDE-FILE-WITH ( i*x fileid xt -- j*x )
  OVER >R  RECEIVE-WITH
  R> CLOSE-FILE SWAP THROW THROW
;
[THEN]


\ ===
\ поддержка старых имен этих слов  (discouraged words)
\ - только для совместимости! 

[UNDEFINED] INCLUDE-WITH [IF]
: INCLUDE-WITH INCLUDED-WITH ;
[THEN]
[UNDEFINED] INCLUDE-LIENS-WITH [IF]
: INCLUDE-LINES-WITH INCLUDED-LINES-WITH ;
[THEN]
[UNDEFINED] INCLUDE-SFILE-WITH [IF]
: INCLUDE-SFILE-WITH INCLUDED-WITH ;
[THEN]
