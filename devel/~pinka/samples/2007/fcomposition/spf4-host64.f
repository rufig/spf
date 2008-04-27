REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`envir.f.xml            FIND-FULLNAME2 EMBODY  xml-struct-hidden::start
`spf4-64.f.xml          FIND-FULLNAME2 EMBODY

\ форт-процессор 64x загружен в словарь emu64
\ дополняем его следующими словами:
GET-CURRENT emu64 SET-CURRENT

: EXECUTE DROP EXECUTE ;
: CATCH DROP CATCH S>D ;
: THROW DROP THROW ;
: ABORT ABORT ;
: ALLOCATED DROP ALLOCATED 0 TUCK ;
: TYPE DROP NIP TYPE ;
: NEXT-LINE-STDIN ( -- a u true | false ) NEXT-LINE-STDIN IF 0 TUCK -1. EXIT THEN 0. ;
: ?STACK ?STACK ;
: OK OK ;
: BYE BYE ;

SET-CURRENT

\ под-списки слов в словаре emu64, как слова, являются "старорежимными",
\ они дают wid одинарной ячейкой, т.к. созданы штатным (инструментальным)
\ интерпретатором и должны быть действенны в штатном трансляторе
\ (к ним относятся TC-WL, doubling-hidden, dataspace-hidden и т.п.)
\ Лучше бы их исключить из emu64


`envir64.f.xml          FIND-FULLNAME2 EMBODY
\ предустановки в окружении перед расширением 64x подсистемы.

\ см.
\ emu64 NLIST
\ emu64::TC-WL NLIST
\ Слова типа f:init, f:text и т.п. служат только как сноски имен и необязательны.
\ Правила на элементы xi:* см. через xml-struct-hidden NLIST


\ GET-CURRENT GET-ORDER \ не обязательно, т.к. и так корень.
EMU64 \ переключение на лексикон эмулятора 64x forthproc  
\ + краткий набор host-tools  (слово '\' там без IMMEDIATE-флага)
\ здесь ORDER даст
\ Context>: host-tools emu64
\ Current: emu64

`spf4-host64.f.xml      FIND-FULLNAME2 EMBODY \ расширение 64x подсистемы.
\ подключили кодогенератор и интерпретатор в чистом контексте, чтобы случайно
\ не взять какое-то слово из инструментальной системы; 
\ там же и инициализировали подсистему.

SPF4 \ вернулись в корневой контекст инструментальной системы
\ SET-ORDER SET-CURRENT 

emu64::QUIT
\ запустили 64x транслятор plainForth
\ слово OK работает из инструментальной системы, демонстрируя двойные значения на стеке.
\ возврат в инструментальную систему доступен по Ctrl+Z,Enter -- "конец входного потока"
