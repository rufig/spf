\ К конкурсу решения задач на форте (http://fforum.winglion.ru/viewtopic.php?p=7587#7587) 

\ Замена табуляторов на пробелы-2 
\ Первый пример (см. после слова /TEST ) -- просто строка 
\ Второй -- требует наличия текстового файла in.txt с текстом 


\ Для запуска нужен дистрибутив SPF: 
\ http://sourceforge.net/project/showfiles.php?group_id=17919 

\ И апрельское обновление: 
\ http://sourceforge.net/project/shownotes.php?release_id=497972&group_id=17919 

REQUIRE /TEST ~profit/lib/testing.f 
REQUIRE состояние ~profit/lib/chartable.f 
REQUIRE (: ~yz/lib/inline.f 
REQUIRE FILE ~ac/lib/str5.f 
REQUIRE TYPE>STR ~ygrek/lib/typestr.f 

MODULE: tabsspaces2 

буффер накопленный-текст \ туда сливаем куски текста 

VARIABLE ширина-табулятора 

EXPORT 

состояние убрать-табуляторы 
на-входе:  отсюда начать-копить ; \ делаем отметку 

все:  копить-дальше ; 

перевод-строки: 
накопленный-текст 2@ TYPE CR 
убрать-табуляторы ; 

9 asc: 
накопленный-текст запомнить 
накопленный-текст 2@ TYPE 
накопленный-текст длина ширина-табулятора @ TUCK MOD - SPACES 
убрать-табуляторы ; 

строка-кончилась: накопленный-текст запомнить  накопленный-текст 2@ TYPE ;


: tabs>spaces ( addr1 u1 n -- addr2 u2 ) 
ширина-табулятора ! 

1 TO размер-символа SWAP поставить-курсор 
(: убрать-табуляторы -символов-обработать ;) TYPE>STR STR@ ; 

;MODULE 


/TEST 
" sds"
STR@ 7 tabs>spaces TYPE

CR CR 

S" in.txt" FILE 7 tabs>spaces TYPE