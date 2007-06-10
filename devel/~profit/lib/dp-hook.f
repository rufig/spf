\ Перехват всех видов компиляции в кодофайл

\ Опеределяется болванка DP-HOOK куда можно записать
\ желаемые действия по проверке идущей компиляции.

\ Хаковатая штука. И то спасибо надо сказать что в SPF
\ DP -- не переменная, а "умное" определение, которое
\ ещё можно подменить "на лету".

\ Из-за конфликта ~ac/lib/ns/so-xt.f c NEAR_NFA:
\ http://sourceforge.net/tracker/index.php?func=detail&aid=1734449&group_id=17919&atid=117919
\ реализация DUPLICATE выглядит несколько более грязной чем могла бы быть.

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE R@ENTER, ~profit/lib/bac4th.f
REQUIRE REPLACE-WORD lib/ext/patch.f
REQUIRE NextNFA lib\ext\vocs.f

MODULE: dp-hook

\ Выдрано из lib/ext/disasm.f
: FIND-REST-END ( xt -- addr | 0)
    DUP NextNFA DUP
    IF 
      NIP
      NAME>C 1- \ Skip CFA field
    ELSE
      DROP
      DP @ - ABS 100 > IF 0 EXIT THEN \ no applicable end found
      DP @ 1-
    THEN

    BEGIN \ Skip alignment
      DUP C@ 0= WHILE 1- 
    REPEAT ;


\ : DUPLICATE HEADER ' DUP FIND-REST-END OVER - HERE SWAP DUP ALLOT RET, CMOVE ;
: DUPLICATE HEADER ' 10000 HERE SWAP DUP ALLOT RET, CMOVE ;
\ Берёт из потока два имени. С первым создаёт новое
\ определение. У второго имени находит содержимое
\ его кода и _копирует_ его в новое слово.
\ Относительные переходы в командах jmp и call ломаются

DUPLICATE DP1 DP \ копируем содержимое DP в DP1 , так как DP мы сейчас сломаем
\ SEE DP1 \ удостоверяемся что DP1 идентичен DP

EXPORT

' NOOP ->VARIABLE &DP-HOOK \ переменная хранит адрес кода обработчика компиляции
\ xt в &DP-HOOK -- перехватчик компиляции, в нём можно делать всякие проверки/оптимизации

\ Использовать перекрываемое определение (scattered colon)
\ технически много сложнее, поэтому сделано так. Хотя можно 
\ было бы и векторное определение, но схема 
\ переменная-хранилище/вызывающее-слово удобнее для bac4th'а
\ из-за вложенности и откатываемости (см. ~profit/lib/compile2Heap.f)
:NONAME &DP-HOOK @ >R ['] NOOP &DP-HOOK ! [ R@ENTER, ]  R> &DP-HOOK ! DP1 ; ' DP REPLACE-WORD
\ Обратите внимание что во время запуска обработчика перехват
\ снимается. Это сделано для того чтобы можно было безболезненно
\ использовать HERE и прочее в самом DP-HOOK

: SET-DP-HOOK ( xt --> \ <-- ) PRO  &DP-HOOK B!  CONT ; \ включить на время работы определения xt как перехватчик компиляции
: DIS-DP-HOOK ( --> \ <-- ) PRO  ['] NOOP &DP-HOOK B!  CONT ; \ отключить все перехватчики компиляции на время работы определения

;MODULE

/TEST
:NONAME ." ." ; &DP-HOOK !

$> 1 ,
$> : r DUP ;

:NONAME HERE . ; &DP-HOOK !


$> 1 ,
$> : r1 DUP ;