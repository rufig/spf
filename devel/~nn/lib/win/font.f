REQUIRE OBJECT:  ~nn/class/class.f
\ REQUIRE CreateWindowExA ~nn/lib/win/wfunc.f



\ pvar: <handle
\ pvar: <lpszFace
\ pvar: <height
\ pvar: <width
\ pvar: <italic
\ pvar: <weight
 
CLASS: Font

        CELL FIELD handle
        CELL FIELD height
        CELL FIELD width
        CELL FIELD lpszFace
        CELL FIELD weight
        CELL FIELD italic


        
CONSTR: init
\    5 width !
    14 height !
    FW_DONTCARE weight !
    S" MS Sans Serif" DROP lpszFace !
;


( Параметры CreateFont
  int nHeight,             // logical height of font
  int nWidth,              // logical average character width
  int nEscapement,         // angle of escapement
  int nOrientation,        // base-line orientation angle
  int fnWeight,            // font weight
  DWORD fdwItalic,         // italic attribute flag
  DWORD fdwUnderline,      // underline attribute flag
  DWORD fdwStrikeOut,      // strikeout attribute flag
  DWORD fdwCharSet,        // character set identifier
  DWORD fdwOutputPrecision,  // output precision
  DWORD fdwClipPrecision,  // clipping precision
  DWORD fdwQuality,        // output quality
  DWORD fdwPitchAndFamily,  // pitch and family
  LPCTSTR lpszFace         // pointer to typeface name string )

M: Create
     lpszFace @
     FF_DONTCARE  DEFAULT_PITCH  OR
     PROOF_QUALITY
     CLIP_DEFAULT_PRECIS
     OUT_DEFAULT_PRECIS
     DEFAULT_CHARSET
     FALSE FALSE
     italic @
     weight @
     0 0
     width @
     height @
     CreateFontA DUP 0= ABORT" Font failed to create" 
     handle !
;     


DESTR: free 
    handle @ IF handle @ DeleteObject DROP THEN
\    own :free
;

;CLASS
