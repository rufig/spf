\ (c) Dmitry Yakimov aka DAY 20.03.2000
\ Простой напоминатель того, что уже поздно.
\ Рекомендуется вставить в автозагрузку

REQUIRE TIME&DATE lib\include\facil.f

WINAPI: MessageBoxA USER32.DLL
HEX
 00001000 CONSTANT MB_SYSTEMMODAL
DECIMAL 
 
\ Считаем сколько тиков нам осталось до 22:00
\ Обычное время когда мне стоит выключить компьютер

22 CONSTANT Hours
00 CONSTANT Minutes
 5 CONSTANT Пауза  \ в минутах
        
: ShowMessage ( addr u -- )
   DROP >R MB_SYSTEMMODAL S" Вам сообщение :)" DROP R>  0 MessageBoxA DROP
;

: Напомнить
   S" Лучше встать завтра пораньше!"
   ShowMessage
;

: OneMore
   S" С выключением компьютера жизнь не заканчивается :)"
   ShowMessage
;

: НужныеТики
    0 Minutes Hours
    60 * + 60 * +
;

: ТекущиеТики ( -- sec )
    TIME&DATE 2DROP DROP
    60 * + 60 * +
;

VARIABLE Kind

: Remind
   BEGIN
     Пауза 60000 * Sleep
     НужныеТики ТекущиеТики - 
     DUP 0 < IF Kind @
                IF OneMore Kind 0!
                ELSE Напомнить Kind 1+!
                THEN
             THEN
   AGAIN
;

   HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE
   TRUE  TO ?GUI
    FALSE TO ?CONSOLE
     ' Remind MAINX !
        S" reminder.exe" SAVE
         BYE

