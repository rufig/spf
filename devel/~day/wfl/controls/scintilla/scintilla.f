
S" ~day\wfl\controls\scintilla\scintilla.const" ADD-CONST-VOC

VARIABLE scintillaDll

..: AT-PROCESS-STARTING scintillaDll 0! ;..

CChildWindow SUBCLASS CScintillaEdit

init:
   scintillaDll @ 0=
   IF
     S" scilexer.dll" DROP LoadLibraryA
     DUP 0= ABORT" Put Scilexer.dll into the program directory"
     scintillaDll !
   THEN

   WS_EX_CLIENTEDGE SUPER exStyle OR!
;

: createClass S" Scintilla" DROP ;

: loadFile ( addr u -- f )
    2DUP FILE-EXIST 
    IF
       LOAD-FILE DROP DUP
       0 SCI_SETTEXT SUPER sendMessage
       SWAP FREE THROW
    ELSE 0
    THEN
;

: E:
    CREATE ,
    DOES> @ 0 0 ROT SUPER sendMessage DROP
;


SCI_CUT    E: cut
SCI_COPY   E: copy
SCI_PASTE  E: paste
SCI_CLEAR  E: clear
SCI_UNDO   E: undo
SCI_REDO   E: redo
SCI_CLEAR  E: clear
SCI_SELECTALL E: selectAll
SCI_CLEARALL E: clearAll
SCI_SETSAVEPOINT E: setSavePoint

: pasteText ( addr u pos )
    NIP SCI_INSERTTEXT SUPER sendMessage DROP
;

: getModify ( -- f )
    0 0 SCI_GETMODIFY SUPER sendMessage
;

: setLineNumbers
    \ set line numbers margin
    S" 9999" DROP STYLE_LINENUMBER SCI_TEXTWIDTH SUPER sendMessage
    SC_MARGIN_NUMBER  SCI_SETMARGINWIDTHN SUPER sendMessage DROP
;

;CLASS

( Adding funcationality of coloring FORTH code and so on )
CScintillaEdit SUBCLASS CScintillaForthEdit

: setForthLexer
    0 SCLEX_FORTH SWAP SCI_SETLEXER SUPER sendMessage DROP
;
;CLASS