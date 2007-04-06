\ colorlessForth без цвета. Идеи -- Chuck Moore и Terry Loveall.
\ Режим компиляции убирается. Остаётся только интерпретация.
\ Что делать со "словом" (точнее говоря строкой), определяется
\ последней буквой:

\ : -- определение
\ , -- компиляция ( COMPILE, )
\ . -- компиляция безусловного перехода ( BRANCH, ), хвостовая оптимизация
\ ; -- компиляция числового литерала ( LIT, )
\ ' -- трактовка строки как имени слова, у которого нужно выяснить xt
\ | -- запись в кодофайл числа ( | )
\ d -- определение
\ h -- определение

\ Обратите внимание на возможность комбинаций цветов:
\ DUP'; --> [ ' DUP ] LITERAL
\ 43d;  --> [ DECIMAL 43 ] LITERAL
\ DUP'| --> ' DUP ,
\ 43d|  --> DECIMAL 43 ,

\ Также надо отметить что у "цветов" . , ; | есть их аналоги цвета
\ которые свои аргументы (если есть) берут со стека.

\ Таким образом можно явно выражать наше нежелание компилировать
\ хвостовую оптимизацию:
\ DUP. --> DUP, .

\ См. также ~profit\lib\loveall.f

\ square: DUP, *.
\ 2x2: 2d; square, typeNumber.
\ 2x2

\ Интерпретатор сначала пытается исполнить пришедшее слово
\ непосредственно, если такого слова нет, то начинает анализ,
\ отделяя последнюю букву от остальной части слова и посылая
\ эти данные в отдельный обработчик для каждой буквы-"цвета"
\ а он там сам может со строкой-остальной частью слова 
\ что-нибудь сделать.

\ Через это возникает интересная возможность "перехвата" режимов.
\ Например, определив слово "SWAP," можно задать действия по компиляции
\ SWAP (оптимизация какая-нибудь). При этом само слово "SWAP" остаётся
\ незадетым.

\ TODO:
\ 1. Сделать совместимость с cascaded.f
\ 2. Возможно, стоит в обработчик all: сделать "правильный" выход их nf-ext 
\ (на выходе после неудачной обработки должно быть addr u FALSE, для передачи
\ следующим обработчикам nf-ext)
\ 3. Решить вопрос со строками (цвет " логичен, но как быть с многословными
\ строками?)
\ 4. Корявое название typeNumber


\ определение:  1d; typeNumber,    <--- CREATE определение 1 LIT, COMPILE .
\ определение2: 2d; typeNumber,    <--- CREATE определение 2 LIT, COMPILE .
\ определение3: 3d; typeNumber, .    <--- CREATE определение 3 LIT, COMPILE . RET,
\ определение3: 3d; typeNumber.    <--- CREATE определение 3 LIT, ' . BRANCH,

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE (: ~yz/lib/inline.f
REQUIRE lastChar ~profit/lib/strings.f
REQUIRE number ~profit/lib/number.f
REQUIRE charTable ~profit/lib/chartable-eng.f
REQUIRE enqueueNOTFOUND ~pinka/samples/2006/core/trans/nf-ext.f
REQUIRE KEEP ~profit/lib/bac4th.f
\ REQUIRE cascaded ~profit/lib/colorForth/cascaded.f

MODULE: colorSPF

: wordCode SFIND NOT IF 2DROP -321 THROW  THEN ;

charTable colors

colors
all: -321 THROW ;
char: ' wordCode ;
char: , wordCode COMPILE, ;
\ char: : CREATED DOES> EXECUTE ;
char: : SHEADER ;
char: . wordCode BRANCH, ;
char: d BASE KEEP  DECIMAL number ;
char: h BASE KEEP  HEX number ;

\ Цвета которые можно комбинировать
char: ; lastChar colors processChar  LIT, ;
char: | lastChar colors processChar  , ;

(
ALSO cascaded
\ режим каскадных определений выкидывает словарные структуры
\ из кодофайла

NEW: CSPFWords
\ заводим общий словарь для слов CSPF
PREVIOUS )

EXPORT

: startColorSPF
(: ( addr u -- addr u false | i*x true ) lastChar colors processChar TRUE ;) enqueueNOTFOUND
\ [COMPILE] ]
\ ALSO CSPFWords DEFINITIONS
;

;MODULE

/TEST
REQUIRE SEE lib/ext/disasm.f

startColorSPF

typeNumber: .. \ Хех.. Прям морзянка.
.: RET,.
;: LIT,.
|: ,.
,: COMPILE,.

if,:   TRUE, STATE, B!, IF.
then,: TRUE, STATE, B!, THEN.

\ ."' .": TRUE, STATE, B!, , .

fact: ( x -- fx ) ?DUP, 0=, if, 1d; . then, DUP, 1-, fact, *.

$> SEE fact
$> 4 fact typeNumber