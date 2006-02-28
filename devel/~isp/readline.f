\ From: "Ilya S. Potrepalov" <potrepalov@asc-ural.ru>
\ Newsgroups: fido7.su.forth
\ Date: Tue, 28 Feb 2006 04:25:10 +0000 (UTC)

\ READ-LINE  чтение строки из файла
BASE @ DECIMAL

USER _lt_
USER _ltl_

USER sb

: DOS-LINES     ( -- )      13 _lt_ C!  10 _lt_ 1+ C!  2 _ltl_ ! ;
: UNIX-LINES    ( -- )      10 _lt_ C!                 1 _ltl_ ! ;

DOS-LINES

: (shift-position)       ( n file_id -- ior )
    TUCK FILE-POSITION ?DUP
    IF   NIP NIP EXIT  THEN
    ROT S>D D+ ROT REPOSITION-FILE 
;


: READ-LINE    ( ac u1 file_id -- u2 f ior )
    \ Прочесть следующую строку из файла, заданого file_id, в память
    \  по адресу ac.  Читается не больше u1 символов (байтов).  До двух
    \  определенных реализацией символов "конец строки" могут быть
    \  прочитаны в память за концом строки, но не включены в счетчик u2.
    \  Буфер строки ac должен иметь размер как минимум u1+2 символа.
    \ Если операция успешна, флаг f "истина" и ior ноль.  Если конец строки
    \  получен до того, как прочитаны u1 символов, то u2 - число реально
    \  прочитанных символов (0<=u2<=u1), не считая символа "конец строки".
    \ Когда u2=u1 конец строки еще не прочитан.
    \ Под ДОС (и WINDOWS) Файл file_id должен быть открыт в режиме BIN

    >R  SWAP DUP sb !       ( сколько-можно-прочитать адрес-куда-читать )
    BEGIN
        2DUP SWAP 255 MIN 
        _ltl_ @ 1- +        \ читаем конец строки без одного байта
        R@ OVER >R READ-FILE        ( u a  u2' ior )
        ?DUP IF
            SWAP 2SWAP NIP +                        ( ior a+u2' )
            sb @ -                                  ( ior u2 )
            0 ROT   RDROP RDROP EXIT
        THEN                                        ( u a u2' )

        2DUP OVER sb @ <>                           ( u a u2' a u2' f )
        \ если читаем не первый фрагмент, то для поиска
        \ конца строки используем один байт из предыдущего фрагмента
        IF  1+ SWAP 1- SWAP  THEN
        _lt_ _ltl_ @ SEARCH
        IF
            RDROP >R
            sb @ -  NIP NIP NIP R>                  ( u2 u3 )
            _ltl_ @ -       \ не возвращать crlf
            ?DUP IF
                NEGATE R@ (shift-position)
                ?DUP  IF  0 SWAP  RDROP EXIT  THEN
            THEN
            -1 0  RDROP EXIT
        THEN
        2DROP                                       ( u a u2' )
        R> OVER <>
        IF  \ дочитали до конца файла               ( u a u2' )
            \ последняя строка может содержать символы, но быть без терминатора
            + NIP sb @ - DUP 0<> 0 RDROP EXIT
        THEN
        TUCK  + >R  - R>
        OVER 1 <
    UNTIL
    OVER +  sb @ -
    SWAP ?DUP IF
        R@ (shift-position)
        ?DUP IF  0 SWAP  RDROP EXIT  THEN
    THEN
    -1 0  RDROP
;

BASE !
