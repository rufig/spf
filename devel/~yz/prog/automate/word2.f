\ Ю. Жиловец, http://www.forth.org.ru/~yz
\ Пример использования библиотеки Automate в режиме интерпретации

REQUIRE [[ ~yz/lib/automate.f

0 VALUE word
0 VALUE content

" Hello\n" ASCIIZ str

ComInit DROP

  " Word.Application" ?CreateObject
  .( ?CreateObject= ) . CR
  TO word
  word [[ Visible =  TRUE ]]
  word [[ Documents Add ]] release
  word [[ ActiveDocument Content ]] TO content
  content [[ InsertAfter ( " Я чувствую," ) ]]
  500 PAUSE
  content [[ InsertParagraphAfter ]]
  content [[ { S" InsertAfter" } ( " Как мной управляют" ) ]]
  500 PAUSE
  content [[ InsertParagraphAfter ]]
  content [[ InsertAfter ( " мистические силы..." ) ]]
  500 PAUSE
  content [[ Font Size = 20 ]]
  800 PAUSE
  word [[ ActiveDocument SaveAs ( " c:/мистические силы.doc" ) * ]]
  content release
  word [[ Quit ]]
  word release

ComDestroy
BYE
