( –абота с сокетами в стиле PHP.  Andrey Cherezov 30.Mar.2000

  fsockopen < server port -- socketline >
    Ќапример: " www.forth.org.ru" 80 fsockopen -> s
    - соединитьс€ с сервером server по порту port и вернуть соединенный сокет.

  fclose < socketline -- >
    - закрыть сокет и соответственно разорвать его соединение
    - дл€ той стороны это будет graceful close, т.е. нормальное закрытие

  fputs < str socketline -- >
    Ќапример " MAIL FROM:<ac@forth.org.ru>{CRLF}" s fputs
    - отправить строку str в сокет socketline

  fgets < socketline -- str >
    - прочесть строку из сокета

  ¬се слова throwable - в случае любой ошибки выполн€етс€ THROW.
  —бор строчной пам€ти на совести вызывающей программы.

  ƒополнительный пример TEST в конце текста.

)

REQUIRE CreateSocket ~ac/lib/win/winsock/ws2/sockets.f
REQUIRE SocketLine   ~ac/lib/win/winsock/ws2/socketline2.f
REQUIRE STR@         ~ac/lib/str2.f

\ socketline - замена сокета во всех операци€х
\ специальна€ структура, хран€ща€ доп.данные дл€ буферизации

: fsock ( socketline -- socket )
  sl_socket @
;
: fsockopen ( server port -- socketline )
  { server port \ sock ip }
  CreateSocket THROW -> sock
  60000 sock SetSocketTimeout THROW
  server STR@ GetHostIP THROW -> ip
  ip port sock ConnectSocket THROW
  sock SocketLine
;
\ : fclose ( socketline -- )
\   fsock CloseSocket THROW
\ ;
: fclose ( socketline -- )
\ fixed by Sergey Shisminzev [sergey@michint.kiev.ua]
  DUP fsock CloseSocket THROW  \ лучше DROP
  FREE THROW
;
: fputs ( str socketline -- )
  { str sock }
  str STR@
  sock fsock WriteSocket THROW
;
: fgets ( socketline -- str )
  { sock \ str }
  "" -> str
  sock SocketReadLine str STR!
  str
;

( \ ѕример: обращение к локальному веб-серверу и печать 20 строк ответа

: TEST
  { \ s }
  SocketsStartup THROW
  " localhost" 80 fsockopen -> s
" GET / HTTP/1.0
Connection: close

" s fputs
  20 0 DO s fgets STYPE CR LOOP
  s fclose
;
)