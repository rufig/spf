\ $Id$
\
\ Построение dot диаграмм
\
\ Для преобразования полученной dot диаграммы в картинку
\ потребуется GraphViz http://www.graphviz.org/

MODULE: DOT-MODULE

0 VALUE H-DOTOUT

EXPORT

: DOT-TYPE ( a u -- ) H-DOTOUT WRITE-FILE THROW ;
: DOT-CR ( -- )  S" " H-DOTOUT WRITE-LINE THROW ;
: DOT-EMIT ( c -- ) SP@ 1 H-DOTOUT WRITE-FILE THROW DROP ;

\ квотирование
: SAFE-DOT-TYPE ( a u -- )
   2DUP S" :" SEARCH NIP NIP 
   IF 
     [CHAR] " DOT-EMIT 
     DOT-TYPE 
     [CHAR] " DOT-EMIT 
   ELSE 
     DOT-TYPE 
   THEN ;

: DOT-FILLCOLOR ( color u -- )
   DOT-CR S" node [fillcolor=" DOT-TYPE DOT-TYPE S" ];" DOT-TYPE ;
    
\ связь от обьекта с именем a u к обьекту с именем a2 u2
: DOT-LINK ( a u a2 u2 -- )
   DOT-CR
   2SWAP
   SAFE-DOT-TYPE
   S"  -> " DOT-TYPE
   SAFE-DOT-TYPE
   S" ;" DOT-TYPE ;

\ Начать dot диаграмму. Сохранить в файл a u
: dot{ ( a u -- )
   R/W CREATE-FILE THROW TO H-DOTOUT
   S" digraph {" DOT-TYPE ;

\ Закончить dot диаграмму
: }dot 
    DOT-CR
    S" }" DOT-TYPE 
    H-DOTOUT CLOSE-FILE THROW ;

;MODULE
