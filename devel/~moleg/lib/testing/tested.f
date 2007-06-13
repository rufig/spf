\ 06-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ подключение библиотеки в режиме тестирования
\ с автоматической проверкой изменений произошедших в системе
\ после подключения указанной библиотеки.

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
 REQUIRE MARKERS   devel\~mOleg\lib\util\marks.f
 REQUIRE TILL      devel\~mOleg\lib\util\for-next.f

\ укоротить строку asc # на u символов от начала
: SKIPn ( asc # u --> asc+u #-u ) OVER MIN TUCK - >R + R> ;

\ распечатать строку в поле шириной l символов,
\ если строка длиннее l, печатать хвост строки длиной в l символов
: TYPE] ( asc # l --> )
        2DUP >
        IF OVER SWAP - SKIPn TYPE
         ELSE OVER - 0 MAX >R TYPE R> SPACES
        THEN ;

\ вернуть FALSE если содержимое массивов или длина не равны
: cmparr ( [a1] # [a2] # --> flag )
         SP@ OVER 1 + CELLS 2DUP 2>R +
         2R> TUCK COMPARE 0= ;

FALSE WARNING ! \ -----------------------------------------------------------

        USER TESTING      \ включение режима тестирования

\ интерпретировать указанный файл, если в контексте не найдено слово key
\ режим тестирования сбрасывается для всех вложенных файлов.
: REQUIRE ( / key file --> )
          FALSE TESTING change >R
                REQUIRE
          R> TESTING ! ;

\ интерпретировать файл, имя которого идентифицируется строкой ascZ #
\ режим тестирования сбрасывается для всех вложенных файлов
: INCLUDED ( ascZ # --> )
           FALSE TESTING change >R
                 INCLUDED
           R> TESTING ! ;

\ попытаться подключить файл в режиме тестирования
: (TESTED) ( asc # --> flag )
           TRUE TESTING !
           CR ." Testing: " 2DUP 0x46 OVER - 0 MAX TYPE]
           ['] (INCLUDED) CATCH
           DUP IF CR ."          can't compile library"
                  CR ERR-STRING TYPE CR
               THEN ;

        USER last-base    \ переменная для контроля изменений состояния BASE
        USER last-current \ переменная для контроля изменений CURRENT
        USER last-context \ указатель на копию контекста

\ проверить, были ли изменения на вершине стека данных
: ?DepthChanges ( ?? )
          TestMoment
          IFNOT CR    ."          stack leaking"
                ValidMark
                IF CR ."          superfluous values: "
                   CountToMark .SN ClearToMark
                 ELSE
                   CR ."          stack underflow for "
                   ForgetMark CountToMark 10 SWAP - . ." cells"
                THEN ClearToMark
            RDROP EXIT
          THEN ForgetMark ;

\ проверить изменения текущей системы исчисления
: ?base ( --> )
        BASE @ last-base @ <>
        IF 0 last-base change BASE !
           CR S"          BASE changed" TYPE
        THEN ;

\ изменен ли текущий словарь?
: ?current ( --> )
           GET-CURRENT last-current @ <>
           IF last-current @ SET-CURRENT
              CR S"          CURRENT changed" TYPE
           THEN ;

\ все ли слова в подключаемом файле завершены
: ?state ( --> )
         STATE @
         IF FALSE STATE !
            CR S"          STATE was ON" TYPE
         THEN ;

\ есть ли изменения в контексте
: ?context ( --> )
           GET-ORDER last-context @ GetFrom cmparr
           IFNOT CR S"          CONTEXT was changed" TYPE
                 SET-ORDER
            ELSE nDROP
           THEN nDROP
           last-context @ KillStack ;

\ массив для тестирования
: TestArray ( --> [arr] # ) 10 FOR R@ TILL ;

\ проверить, есть ли изменения под вершиной стека данных
: ?InternalCanges ( ?? )
                  CountToMark MarkMoment TestArray CountToMark cmparr
                  IFNOT ClearToMark CR S"          " TYPE .SN ."  <--"
                   ELSE ClearToMark
                  THEN ;

\ подключить указанный файл в режиме тестирования
: TESTED  ( ascZ # --> )
          last-base @ IF CR ." nested testing unsupported" -1 THROW THEN

          BASE @ last-base !          \ сохранили текущую систему исчисления
          GET-CURRENT last-current !  \ запомнили текущий словарь

          \ запомнили текущий контекст
          GET-ORDER 0x10 NewStack DUP last-context ! MoveTo

          \ запомнили текущий указатель вершины стека данных
          2>R  init-markers MarkMoment

          \ добавили 10 чисел от 1 до 10 на вершину стека данных,
          \ запомнили текущую позицию
          TestArray MarkMoment

          \ подключаем тестируемый файл
          2R> (TESTED)
          IF \ если ошибка, восстанавливаем все:
             0 last-base change BASE !     \ систему исчисления
             last-current @ SET-CURRENT    \ текущий словарь
             FALSE STATE !                 \ режим интерпретации
             ForgetMark ClearToMark        \ чистим стек данных
                                           \ восстанавливаем контекст
             last-context @ DUP GetFrom SET-ORDER
                            KillStack      \ удаляем временный стек
            EXIT  \ и выходим. Восстанавливать HERE не имеет смысла
          THEN

          ?base
          ?current
          ?context
          ?state
          ?DepthChanges
          ?InternalCanges ClearToMark

          ."  passed" ;

TRUE WARNING ! \ ------------------------------------------------------------

?DEFINED test{ \EOF

test{ \ просто тест на подключаемость.
  S" passed" TYPE
}test \EOF











