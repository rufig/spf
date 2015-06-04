\ 03.Feb.2007 ruv
\ $Id$
( Лексикон кодогенератора:

    -- запись данных /в область данных/
    HERE ALLOT , C, S, 
    SXZ, SCZ,
    CARBON

    -- запись кода /в область кода и в область данных при необходимости/
    EXEC, LIT, 2LIT, SLIT,
    CONCEIVE GERM BIRTH IT

    -- формирование кода, управляющего потоком исполнения
    BFW, ZBFW, RFW MBW BBW, ZBBW, BFW2, ZBFW2,
    \ abbr. from -- Branch, ZeroBranch, ForWard, BackWard, Mark, Resolve.
    \ обязательно используют лишь управляющий стек.

    -- возможна совмещенность областей кода и данных в зависимости от реализации.


 'S,' -- записывает только указанный ему блок данных /счетчик в единицах адреса/ и больше ничего.
 'SLIT,' -- никак не специфицирует, не навязывет формат, а лишь гарантирует [c-addr u] при исполнении;
          возможно наличие x0 в конце блока данных вне счетчика, если это удобно /когда API хост-системы требуют Z-строки/.
 'EXEC,' -- откладывает исполнение семантики, представленной токеном xt.
 'EXIT,' -- откладывает выход из слова.

  GERM [ -- xt ] дает токен формируемого кода.
  Пара CONCEIVE [ -- ]  BIRTH [ -- xt ] сохраняет и восстанавливает предыдущий GERM
    и требует согласованности по управляющему стеку CS.
  IT   [ -- xt ] дает самый последний токен, созданный кодогератором.


  Cлово '&' [ c-addr u -- xt ]  -- постфиксный вариант ' [tick]
  /вообще, оно к кодогенерации имеет малое отношение/.
)


REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f
REQUIRE Require   ~pinka/lib/ext/requ.f

: SXZ, ( a u -- ) DUP  , S, 0 C, ;
: SCZ, ( a u -- ) DUP C, S, 0 C, ;

: CARBON ( a1 u -- a2 u )
  HERE OVER 2SWAP S,
;

\ Некоторые слова в SPF4 имеют специальную процедуру 
\ для откладывания их исполнения (компиляции), -- как например inlines.
Require ADVICE-COMPILER inlines.f \ все особые слова SPF4 обработанны

\ Слово ADVICE-COMPILER ( xt-compiler xt -- ) позволяет навесить
\ необходимую семантику компиляции на xt
\ а слово GET-COMPILER? ( xt -- xt-compiler true | xt false ) 
\ дает эту семантику, если она имеется.
\ Слово "EXEC," (отложить исполнение) использует специфичный компилятор,
\ если он задан для данного xt.

\ Дискуссионный вопрос о сигнатуре xt-compiler.
\ Пока принято, что это слово замкнуто на xt и имеет стек ( -- )



Require >CS control-stack.f \ управляющий стек

Require PUSH-DEVELOP native-context.f \ контекст поиска и именования форт-слов


\ ---
\ Лексикон кодогенератора, в список CODEGEN-WL
WORDLIST DUP CONSTANT CODEGEN-WL  LAST @ SWAP VOC-NAME! \ ссылка на имя словаря, SPF4 (!)

CODEGEN-WL PUSH-DEVELOP

Include codegen.f

DROP-DEVELOP \ see:  CODEGEN-WL NLIST
\ ---


Require NAMING- native-wordlist.f \ простые списки форт-слов

' CODEGEN-WL `CODEGEN NAMING- \ alias
CODEGEN ALSO! ' IT `IT NAMING- PREVIOUS \ export
