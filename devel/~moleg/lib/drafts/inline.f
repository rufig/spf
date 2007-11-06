\ 03-11-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ inline подстановка кода при сборке слов (набросок)

 REQUIRE ALIAS   devel\~moleg\lib\util\alias.f
 REQUIRE COMPILE devel\~moleg\lib\util\compile.f
 REQUIRE STREAM{ devel\~moleg\lib\arrays\stream.f

\ ------------------------------------------------------------------------------

 ALIAS : ::
 ALIAS ; ;; IMMEDIATE

VOCABULARY INLINE  \ в этом словаре будут все примитивы

WARNING 0!
\ перехватываются ':' и ';' хотя правильнее было бы перехватывать '[' и ']'
\ Однако, для этого нужно менять код ядра, либо собирать ядро без оптимизации,
\ это значит, что слова '[' и ']' внутри определений не стоит использовать
:: : ( --> ) ALSO INLINE [COMPILE] : ;;
:: ; ( --> ) PREVIOUS    [COMPILE] ; ;; IMMEDIATE
TRUE WARNING !

\ начинает создание макроса для инлайн подстановки
: inline{  ( | name hex-stream --> )
          ALSO INLINE DEFINITIONS
          : [COMPILE] STREAM{ ;

\ завершает hex-stream поток и завершает создание макроса
\ перед inline обязательно должен стоять символ } завершения потока
\ пробел между символом '}' и словом inline не обязателен
: inline ( asc # --> )
         SLIT, COMPILE S,
         [COMPILE] ; IMMEDIATE
         PREVIOUS DEFINITIONS
         ; IMMEDIATE

\ ------------------------------------------------------------------------------
\ примеры макросов для inline подстановки
inline{ DUP   8D6DFC 894500 }inline
inline{ DROP  8B4599 8D6D04 }inline
inline{ SWAP  8B5500 894500 8BC2 }inline
inline{ OVER  8D6DFC 894500 8B4504 }inline
inline{ NIP   8D6D04 }inline
inline{ TUCK  8D6DFC 8B5504 894504 895500 }inline
inline{ ROT   8B5500 894500 8B4504 895504 }inline
inline{ RDROP 5B 8D642404 }inline

?DEFINED test{ \EOF -- тестовая секция -----------------------------------------

test{ : proba OVER OVER ; 1 2 proba D= 1 + THROW
  S" passed" TYPE
}test

