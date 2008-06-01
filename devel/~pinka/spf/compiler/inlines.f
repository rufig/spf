\ 18.Feb.2007 Sun 18:31
\ $Id$
\ see also src/compiler/spf_inline.f
\ NON-OPT-WL contains five words: EXECUTE  ?DUP  R>  >R  RDROP


REQUIRE BIND-NODE ~pinka/samples/2006/lib/plain-list.f 
REQUIRE AsQName   ~pinka/samples/2006/syntax/qname.f \ пон€тие однословных строк в виде `abc

VARIABLE h-compilers

: ADVICE-COMPILER ( xt-compiler xt -- )
  0 , HERE SWAP , SWAP , h-compilers BIND-NODE
;
: GET-COMPILER? ( xt -- xt-compiler true | xt false )
  DUP h-compilers FIND-NODE IF NIP CELL+ @ TRUE EXIT THEN FALSE
;
\ да, вот так :)  » не надо вводить дополнительных полей в старые заголовки.
\ -----

: COMPILE(?DUP)
  HERE TO :-SET ['] C-?DUP  INLINE, HERE TO :-SET \ нужно как в THEN
;
: COMPILE(EXECUTE)
  ['] C-EXECUTE INLINE,
;

' COMPILE(?DUP)         ' ?DUP    ADVICE-COMPILER
' COMPILE(EXECUTE)      ' EXECUTE ADVICE-COMPILER
`RDROP   SFIND 0= THROW ' RDROP   ADVICE-COMPILER
`R>      SFIND 0= THROW ' R>      ADVICE-COMPILER
`>R      SFIND 0= THROW ' >R      ADVICE-COMPILER

\ hint: ' (тик) ищет c NON-OPT-WL на вершине, 
\ поэтому здесь имена разрешаютс€ через SFIND

\ I-NATIVE не ищет в NON-OPT-WL, с учетом этого
\ пропишем компил€торы дл€ эти слов из словар€ FORTH:

' COMPILE(?DUP)         `?DUP    SFIND 0= THROW ADVICE-COMPILER
' COMPILE(EXECUTE)      `EXECUTE SFIND 0= THROW ADVICE-COMPILER

\ "сами себе" компил€торы:
`RDROP   SFIND 0= THROW  DUP  ADVICE-COMPILER
`R>      SFIND 0= THROW  DUP  ADVICE-COMPILER
`>R      SFIND 0= THROW  DUP  ADVICE-COMPILER




\ ƒл€ слов, чувствительных к уровню стека возвратов, нельз€ делать хвостовую оптимизацию.
\ ѕрописываю собственный компил€тор дл€ слова "2R>", чтобы генерить верный код
\ дл€ него даже при включенной хвостовой оптимизации ("?C-JMP").

: COMPILE(2R>)
  ['] 2R> COMPILE,
  HERE TO :-SET
;

' COMPILE(2R>) ' 2R> ADVICE-COMPILER
