\ 09-10-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ определение, с какой архитектурой имеем дело:
\ big endian или little endian

 REQUIRE B@        devel\~mOleg\lib\util\bytes.f

\ определить разрядность базовой адресуемой единицы для данной архитектуры.
\ предполагается, что старший бит числа знаковый, а операции сдвига влево
\ логические.
: ?CELL# ( --> bits )
         -1 0 BEGIN OVER WHILE
                    1 + SWAP 1 RSHIFT SWAP
              REPEAT NIP ;

\ получить уникальное для данной разрядности число
\ младшие разряды числа одинаковы для любой разрядности.
: unnum ( --> n )
        ?CELL# 4 -
        1 BEGIN OVER 0 > WHILE
                DUP DUP + 4 LSHIFT OR
                SWAP 4 - SWAP
          REPEAT NIP ;

\ место для хранения числа, по которому определяем тип машины
CREATE archtag unnum ,

\ TRUE если порядок хранения байт в памяти от младшего к старшему (ix86)
: ?LITTLE-ENDIAN ( --> flag ) archtag B@ 0x21 = ;

\ TRUE если порядок хранения байт в памяти обратный,
\ то есть сначала старшее значение, затем младшее.
: ?BIG-ENDIAN ( --> flag ) archtag B@ 0x21 <> ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ ?CELL# 32 <> THROW      \ СПФ сейчас 32 битный
      ?LITTLE-ENDIAN 0= THROW \ ix86 процессор хранит байты в обратном порядке
      ?BIG-ENDIAN THROW       \ это пока что не ожидается

S" passed" TYPE
}test
