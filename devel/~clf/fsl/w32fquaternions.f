( Quaternions 1.1 by Pierre Abbat
  Win32Forth test code
  This code is specific to Win32Forth and presents the same
  icosahedron test graphically. )

NEEDS FSL_Util
TRUE TO TEST-CODE?
SYNONYM PI FPI
INCLUDE QUATERNIONS

SYNONYM F1 F1.0
F1 FNEGATE FCONSTANT F-1
5E0 FSQRT F1 F- F2/ FCONSTANT /PHI ( 0.618034 )
/PHI FNEGATE FCONSTANT -/PHI
SYNONYM F0 F0.0
( The twelve corners of an icosahedron inscribed in the side-2 cube are
  1 1/phi 0, with the coordinates rotated and arbitrarily sign-changed. 
)

: C0   F1 /PHI F0 ;
: C1   F-1 /PHI F0 ;
: C2   F-1 -/PHI F0 ;
: C3   F1 -/PHI F0 ;
: C4   /PHI F0 F1 ;
: C5   /PHI F0 F-1 ;
: C6   -/PHI F0 F-1 ;
: C7   -/PHI F0 F1 ;
: C8   F0 F1 /PHI ;
: C9   F0 F-1 /PHI ;
: C10   F0 F-1 -/PHI ;
: C11   F0 F1 -/PHI ;

\ Looking at the icosahedron from +X, with Y increasing to the right and Z up
\                                    7
\                    ............         ............
\                 ...            ...   ...            ...
\                .                 __7__                 .
\               .              ___/  |  \___              .
\              .      14   ___/      |      \___   13      .
\              .          /       9  |  8       \          .
\             .         _9-----------4-----------8_         .
\             .      __/ |  \_  15  / \  12  _/  | \__      .
\             .   __/    |    \_   /   \   _/    |    \__   .
\             .  /       |      \ /  4  \ /      |       \  .
\ ------------2--     2  |  3    3-------0    0  |  1     --1------------
\             .  \__     |     _/ \  5  / \_     |     __/  .
\             .     \__  |   _/    \   /    \_   |  __/     .
\             .        \_| _/   16  \ /  19   \_ | /        .
\             .          10----------5-----------11         .
\              .          \___    10 | 11    ___/          .
\              .      17      \___   |   ___/      18      .
\               .                 \__|__/                 .
\                .                   6                   .
\                 ...            ...   ...            ...
\                    ............         ............
\                                    6
\ 2FLIP flips around the line between corners 0 and 3,
\ 3TWIST counterclockwise around face 12, and
\ 5TWIST counterclockwise around corner 0.

: new-hatch-color ( colorref -<name>- ) \ make a hatched color
                HatchColorObject                \ define a new object
                NewColor: NewObject ;           \ and initialize it

20 4 CELLS array face{
( The cells are a color and the XT's of the three corners. )
 63   0   0 RGB new-hatch-color Color0
127   0   0 RGB new-hatch-color Color1
191   0   0 RGB new-hatch-color Color2
255   0   0 RGB new-hatch-color Color3
  0  63   0 RGB new-hatch-color Color4
  0 127   0 RGB new-hatch-color Color5
  0 191   0 RGB new-hatch-color Color6
  0 255   0 RGB new-hatch-color Color7
  0   0  63 RGB new-hatch-color Color8
  0   0 127 RGB new-hatch-color Color9
  0   0 191 RGB new-hatch-color Color10
  0   0 255 RGB new-hatch-color Color11
255 255 255 RGB new-color Color12
255 255  63 RGB new-color Color13
 63 255  63 RGB new-color Color14
 63 255 255 RGB new-color Color15
 63  63 255 RGB new-color Color16
 63  63  63 RGB new-color Color17
255  63  63 RGB new-color Color18
255  63 255 RGB new-color Color19

marker discard
: !face ( corner3 corner2 corner1 colorobj addr )
  TUCK ! CELL+ TUCK ! CELL+ TUCK ! CELL+ ! ;

' C0  ' C8  ' C11  Color0  face{  0 } !face
' C1  ' C11 ' C8   Color1  face{  1 } !face
' C2  ' C9  ' C10  Color2  face{  2 } !face
' C3  ' C10 ' C9   Color3  face{  3 } !face
' C4  ' C0  ' C3   Color4  face{  4 } !face
' C5  ' C3  ' C0   Color5  face{  5 } !face
' C6  ' C1  ' C2   Color6  face{  6 } !face
' C7  ' C2  ' C1   Color7  face{  7 } !face
' C8  ' C4  ' C7   Color8  face{  8 } !face
' C9  ' C7  ' C4   Color9  face{  9 } !face
' C10 ' C5  ' C6   Color10 face{ 10 } !face
' C11 ' C6  ' C5   Color11 face{ 11 } !face
' C0  ' C4  ' C8   Color12 face{ 12 } !face
' C1  ' C8  ' C7   Color13 face{ 13 } !face
' C2  ' C7  ' C9   Color14 face{ 14 } !face
' C3  ' C9  ' C4   Color15 face{ 15 } !face
' C3  ' C5  ' C10  Color16 face{ 16 } !face
' C2  ' C10 ' C6   Color17 face{ 17 } !face
' C1  ' C6  ' C11  Color18 face{ 18 } !face
' C0  ' C11 ' C5   Color19 face{ 19 } !face

discard

3 DOUBLE ARRAY corner{ ( the corners of a face after rotating the 
icosahedron )

: XY- ( x1 y1 x2 y2 - x3 y3 )
  ROT SWAP - -ROT - SWAP ;

: FacingViewer ( - ? )
( Returns true if the face in corner{ is facing the viewer.
  All faces are defined counterclockwise. If a face
  projects clockwise, it is hidden. )
  corner{ 0 } 2@ corner{ 1 } 2@ XY-
  corner{ 1 } 2@ corner{ 2 } 2@ XY-
  -ROT * -ROT * < ;

ColorObject Farbe

3 3 FLOAT MATRIX ViewAngle{{
ViewAngle{{ Q 1 0 0.1 -0.1 NORMALIZE }}QUAT>MATRIX
( This adds a bit of perspective, so that you are not looking straight
  along the X-axis. Thus 10 faces are visible. )

:Object IcosaWindow <Super Window
int CenterX
int CenterY
int Scale

: SetSide ( n )
( Turns side according to orient{{ and ViewAngle{{, then
  puts the Y and Z coordinates in corner{ and the color in dc. )
  face{ swap }
  LCount BrushColor: dc
  3 0 DO
    DUP I CELLS+ @ EXECUTE ( get the corner )
    orient{{ }}mat*vec ViewAngle{{ }}mat*vec
    FROT FDROP FSWAP ( discard X, which is the viewing direction )
    Scale S>F F* F>S CenterX + Scale S>F F* F>S CenterY SWAP - SWAP 
corner{ I } 2!
  LOOP DROP ;

:m WindowTitle:
  Z" IcosaTest" ;m

:m On_Size:
  Width 2/ to CenterX
  Height 2/ to CenterY
  CenterX CenterY MIN 4 5 */ to Scale ;m

:m On_Paint:
  20 0 DO
  I SetSide FacingViewer IF
    3 corner{ rel>abs GetHandle: dc Call Polygon ?win-error
    THEN
  LOOP ;m

:m On_Done:
  On_Done: super
  MEXIT ;m

;Object

: PaintIcosa ( f: q - q )
  orient{{ }}QUAT>MATRIX
  orient{{ }}MATRIX>QUAT ( to make sure that }}MATRIX>QUAT works )
  Paint: IcosaWindow ;

: IcosaTest
  ." This is a test of roundoff error in quaternion multiplication" CR
  ." by rotating an icosahedron." CR
  ." Hit any of 2, 3, 5, or Q"
  Q 1 0 0 0
  Start: IcosaWindow
  PaintIcosa
  BEGIN
    KEY CASE
      [CHAR] 2 OF   2FLIP PaintIcosa ENDOF
      [CHAR] 3 OF  3TWIST PaintIcosa ENDOF
      [CHAR] 5 OF  5TWIST PaintIcosa ENDOF
      [CHAR] Q OF   MEXIT Close: IcosaWindow ENDOF
    ENDCASE
    CR QDUP Q.
    QDUP NORM F0=
  UNTIL QDROP ;
