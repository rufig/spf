(
Из *.h файлов делает файл с константами форта.
Только немного ручками править потом придется :>

)


\ Первое слово #define затем некое слово, затем цифра
: PARSE#
  BEGIN
    BEGIN
      NextWord DUP
    WHILE
      S" #define" COMPARE
      0= IF
           NextWord
           NextWord ?DUP
           IF
             ." #define "
             2SWAP TYPE BL EMIT TYPE 
             0 PARSE TYPE SPACE CR
           ELSE
             2DROP DROP
           THEN
           0 PARSE 2DROP
         THEN
    REPEAT 2DROP
    REFILL 0=
  UNTIL 
;


: h2f
  S" winsock.h" R/O OPEN-FILE THROW DUP TO H-STDIN
  TO SOURCE-ID
  S" winsock.f" W/O CREATE-FILE THROW TO H-STDOUT
  PARSE#
  H-STDIN CLOSE-FILE THROW
  H-STDOUT CLOSE-FILE THROW
  BYE
;

h2f