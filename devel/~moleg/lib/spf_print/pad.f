\ 04-06-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ дополнительные слова для удобной работы с буфером PAD

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE ADDR     devel\~moleg\lib\util\addr.f

?DEFINED char  1 CHARS CONSTANT char

        0x0D    CONSTANT cr_
        0x0A    CONSTANT lf_
        0x09    CONSTANT tab_
        CHAR .  CONSTANT point
        CHAR ,  CONSTANT comma

\ преобразовать число в символ
: >DIGIT ( N --> Char ) DUP 0x0A > IF 0x07 + THEN 0x30 + ;

\ добавить пробел в PAD
: BLANK ( --> ) BL HOLD ;

\ добавить указанное кол-во пробелов в PAD
: BLANKS ( n --> ) 0 MAX BEGIN DUP WHILE BLANK 1 - REPEAT DROP ;

\ инициализация буфера прямого преобразования »
: <| ( --> ) SYSTEM-PAD HLD A! ;

\ добавить символ в буфер PAD »
\ отличие от HOLD в том, что символ добавляется в конец формируемой строки
\ а не в ее начало.
: KEEP ( char --> ) HLD A@ C! char HLD +! ;

\ вернуть сформированную строку »
: |> ( --> asc # ) 0 KEEP SYSTEM-PAD HLD A@ OVER - char - ;

\ добавить строку в буфер PAD »
\ действие аналогично HOLDS за исключением того, что строка добавляется
\ в конец формируемой строки, а не в ее начало.
: KEEPS ( asc # --> ) HLD A@ OVER HLD +! SWAP CMOVE ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ пока просто проверка компилируемости.

  S" passed" TYPE
}test
