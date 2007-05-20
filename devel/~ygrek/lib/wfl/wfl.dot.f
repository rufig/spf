\ Диаграмма классов wfl
\ На выходе dot-файл для GraphViz
\ "C:\Program Files\ATT\Graphviz\bin\dot.exe" -Tpng wfl.dot -owfl.dot.png
\ Соответствующую картинка - http://forth.org.ru/~ygrek/files/wfl.png

REQUIRE dot{ ~ygrek/lib/dot.f
REQUIRE PEEK-NAME ~ygrek/lib/parse.f

REQUIRE WL-MODULES ~day/lib/includemodule.f
NEEDS ~day/hype3/hype3.f

\ собирает инфу о связях между классами
: SUBCLASS
   DUP HYPE::.nfa @ COUNT PEEK-NAME DOT-LINK

   SUBCLASS ;

S" wfl.dot" dot{

 DOT-CR S" node [style=filled,color=black];" DOT-TYPE

 S" green" DOT-FILLCOLOR
 NEEDS ~day/wfl/wfl.f
 S" yellow" DOT-FILLCOLOR
 NEEDS ~ygrek/lib/wfl/opengl/GLWindow.f
 S" grey" DOT-FILLCOLOR
 NEEDS ~day/wfl/controls/urllabel.f
 S" grey" DOT-FILLCOLOR
 NEEDS ~day/wfl/controls/splitter.f
 S" grey" DOT-FILLCOLOR
 NEEDS ~day/wfl/controls/scintilla/scintilla.f
}dot

CR .( DONE)
