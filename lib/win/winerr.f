\ Добавление к DECODE-ERROR
\ Вы можете перегружать DECODE-ERROR для обработки ошибок
\ в ваших приложениях

WINAPI: FormatMessageA   KERNEL32.DLL
WINAPI: SetLastError     KERNEL32.DLL

1 CONSTANT WIN_ERROR

..: DECODE-ERROR ( n u -- c-addr u )
     DUP WIN_ERROR =
     IF DROP
        >R 0 1024 PAD 0 
        R> 0 0x1000
        FormatMessageA PAD SWAP
        EXIT
     THEN
;..

: SABORT ( flag addr u -- )
\ Кстати, это слово тоже полезно может быть. У меня были случаи.
  ROT IF ER-U ! ER-A ! -2 THROW ELSE 2DROP THEN
;

: WTHROW ( 0 -- ) \ exception
         ( n -- )
  ?DUP 0= IF
    GetLastError ?DUP
    IF
      WIN_ERROR DECODE-ERROR 
      ANSI>OEM
      SABORT
    THEN
  THEN
;

\ Example
(
' ANSI>OEM TO ANSI><OEM
GetLastError WIN_ERROR   DECODE-ERROR TYPE
0xC00000AAL  FORTH_ERROR DECODE-ERROR TYPE
)