REQUIRE :: ~yz/lib/automation.f

0 VALUE word
0 VALUE content

: mystic-powers-of-word

COM-init DROP

  " Word.Application" ?create-object 
  IF ." Ќе могу запустить Microsoft Word" BYE THEN
  TO word

  TRUE _bool word :: Visible !
  arg() word :: Documents Add
  word :: ActiveDocument Content @
  DROP TO content
  arg( " я чувствую," _str )arg content :: InsertAfter
  500 PAUSE
  arg() content :: InsertParagraphAfter
  arg( "  ак мной управл€ют" _str )arg content :: InsertAfter
  500 PAUSE
  arg() content :: InsertParagraphAfter
  arg( " мистические силы..." _str )arg content :: InsertAfter
  500 PAUSE
  20 _int content :: Font Size !
  800 PAUSE
  arg( " c:/мистические силы.doc" _str )arg word :: ActiveDocument SaveAs
  arg() word :: Quit

KEY DROP

content release
word release

COM-destroy ;

mystic-powers-of-word

BYE
