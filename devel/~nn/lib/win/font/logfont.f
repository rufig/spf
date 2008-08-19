
\   typedef struct tagLOGFONT { 
0
CELL -- lfHeight \ LONG lfHeight; 
CELL -- lfWidth  \ LONG lfWidth; 
CELL -- lfEscapement \ LONG lfEscapement; 
CELL -- lfOrientation \ LONG lfOrientation; 
CELL -- lfWeight \ LONG lfWeight; 
CELL -- lfItalic \ BYTE lfItalic; 
CELL -- lfUnderline \ BYTE lfUnderline; 
CELL -- lfStrikeOut \ BYTE lfStrikeOut; 
CELL -- lfCharSet \ BYTE lfCharSet; 
CELL -- lfOutPrecision \ BYTE lfOutPrecision; 
CELL -- lfClipPrecision \ BYTE lfClipPrecision; 
CELL -- lfQuality \ BYTE lfQuality; 
CELL -- lfPitchAndFamily \ BYTE lfPitchAndFamily; 
CELL -- lfFaceName \ TCHAR lfFaceName[LF_FACESIZE]; 
\ } LOGFONT, *PLOGFONT; 
CONSTANT /LOGFONT
