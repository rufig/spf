( Чтение строки исходного текста из входного потока: консоли или файла.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Ревизия: Сентябрь 1999
)

USER-VALUE SOURCE-ID ( -- 0|-1 ) \ 94 CORE EXT
\ Идентифицирует входной поток:
\ -1 - строка (через EVALUATE)
\  0 - пользовательское входное устройство
USER-VALUE SOURCE-ID-XT \ если не равен нулю, то содержит заполняющее
\ слово для REFILL

VECT <PRE>
USER CURSTR \ номер строки

: CONSOLE-HANDLES
\  0 TO SOURCE-ID
  -10 GetStdHandle TO H-STDIN 
  -11 GetStdHandle TO H-STDOUT
  -12 GetStdHandle TO H-STDERR
;

: REFILL ( -- flag ) \ 94 FILE EXT
\ Расширить семантику выполнения CORE EXT REFILL следующим:
\ Когда входной поток - текстовый файл, попытаться прочесть следующую
\ строку из текстового входного файла. Если успешно, сделать результат
\ входным буфером, установить >IN в ноль и вернуть "истину".
\ Иначе вернуть "ложь".
\ : REFILL ( -- flag ) \ 94 CORE EXT
\ Попытаться заполнить входной буфер из входного потока, вернуть
\ флаг "истина", если успешно.
\ Когда входным потоком является пользовательское входное устройство,
\ попытаться принять ввод в терминальный входной буфер. Если успешно,
\ сделать результат входным буфером, установить >IN в ноль и возвратить
\ "истину". Прием строки, не содержащей символов, считается успешным.
\ Если ввод с текущего входного устройства недоступен - возвратить "ложь".
\ Когда входным потоком является строка от EVALUATE, возвратить "ложь"
\ и не выполнять других действий.

\   CURSTR 1+!
\   TIB C/L
\   SOURCE-ID 0 > IF SOURCE-ID ( included text )
\                 ELSE SOURCE-ID
\                      IF 2DROP FALSE EXIT THEN ( evaluate string )
\                      H-STDIN ( user input )
\                 THEN
\   READ-LINE THROW ( ошибка чтения )
\   IF #TIB ! >IN 0! <PRE> -1
\   ELSE DROP 0 THEN
\ ;

( Исправления на тот случай, когда консоль не файл, и читать её
  следует через ACCEPT [который может быть не файловым]
  24.04.2000 А.Ч.
)
  CURSTR 1+!
  TIB C/L
  SOURCE-ID 0 > IF SOURCE-ID ( included text )
     SOURCE-ID-XT ?DUP IF EXECUTE ELSE READ-LINE THEN
     THROW ( ошибка чтения )
     IF #TIB !
     ELSE DROP FALSE EXIT THEN
  ELSE SOURCE-ID
     IF 2DROP FALSE EXIT THEN ( evaluate string )
     ['] ACCEPT CATCH ?DUP \ -1002=конец файла или pipe
                            \ остальные ошибки - ошибки чтения
     IF -1002 = IF FALSE EXIT THEN
        THROW
     ELSE #TIB ! THEN ( user input )
  THEN
  >IN 0! <PRE> -1
;
