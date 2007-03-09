\ Пакетный графический редактор 1.00
\ 20.10.2002

REQUIRE "      ~yz/lib/common.f
REQUIRE >>     ~yz/lib/data.f
REQUIRE {      lib/ext/locals.f
REQUIRE (*     ~yz/lib/wincons.f
REQUIRE <(     ~yz/lib/format.f
REQUIRE CAPI:  ~af/lib/c/capi.f

" GED 1.00" ASCIIZ program-name

VECT final-exit

: err ( z -- ) .ASCIIZ CR ; 

: error ( z -- )
  ?DUP 0= IF EXIT THEN
  err
  ERR-STRING C@ IF
    ERR-STRING COUNT 2DUP + @ ROT ROT
    0 ERR-STRING C!
  ELSE
    >IN @ SOURCE
  THEN
  TYPE
  CURFILE @ ?DUP IF FREE DROP CURFILE 0! THEN
  final-exit ;

: ?error ( ? z --) SWAP IF error ELSE DROP THEN ;

WINAPI: wvsprintfA USER32.DLL

:NONAME ( arglist fmt module -- )
 .ASCIIZ ." : "
 HERE wvsprintfA DROP
 HERE error
; WNDPROC: tifferror
\ ---------------------------------------------------------------

0 VALUE ширина
0 VALUE высота
0 VALUE tiff
0 VALUE c-dc
0 VALUE c-bmp
0 VALUE m-dc
0 VALUE m-bmp
0 VALUE y-dc
0 VALUE y-bmp
0 VALUE k-dc
0 VALUE k-bmp

VARIABLE c-pic
VARIABLE m-pic
VARIABLE y-pic
VARIABLE k-pic

\ Эти сишные функции не чистят за собой стек
2 CAPI: TIFFOpen		libtiff.dll
1 CAPI: TIFFSetErrorHandler	libtiff.dll
3 CAPI: TIFFGetField 		libtiff.dll
4 CAPI: TIFFSetField		libtiff.dll
1 CAPI: TIFFClose		libtiff.dll
4 CAPI: TIFFWriteScanline       libtiff.dll
4 CAPI: TIFFReadScanline        libtiff.dll

: tiff@ { tag \ temp -- n }
  ^ temp tag tiff TIFFGetField DROP temp ;
: tiff2! ( n2 n tag -- )
  tiff TIFFSetField DROP ;
: tiff! ( n tag -- )
  0 -ROT tiff2! ;

\ ---------------------------------------------------------------

WINAPI: CreateCompatibleDC  GDI32.DLL
WINAPI: DeleteDC	    GDI32.DLL
WINAPI: DeleteObject        GDI32.DLL
WINAPI: CreateDIBSection    GDI32.DLL
WINAPI: SelectObject        GDI32.DLL
WINAPI: CreateBitmap        GDI32.DLL
WINAPI: SetBkMode           GDI32.DLL

: new-pic { \ dc bmp pic -- pic bmp dc}
  0 CreateCompatibleDC TO dc
  \ создаем картинку
  HERE init->>
  10 CELLS >>
  ширина >>
  высота NEGATE >>
  1 W>>
  8 W>>
  W: bi_rgb >>
  0 >> 11180 >> 11180 >>
  0 >> 0 >>
  \ заполняем серую палитру: 0,0,0 потом 1,1,1 и т.д.
  256 0 DO
    I C>> I C>> I C>> 0 C>>
  LOOP
  0 0 ^ pic W: dib_rgb_colors HERE dc CreateDIBSection TO bmp
  bmp dc SelectObject DROP
  W: transparent dc SetBkMode DROP
  pic ширина высота * ERASE
  pic bmp dc ;

\ ----------------------------------------

0 VALUE c-fill
0 VALUE m-fill
0 VALUE y-fill
0 VALUE k-fill
0 VALUE c-stroke
0 VALUE m-stroke
0 VALUE y-stroke
0 VALUE k-stroke

: белая ( -- r g b) 255 255 255 ;
: черная ( -- r g b) 0 0 0 ;
: желтая ( -- r g b) 255 255 0 ;
: пурпурная ( -- r g b) 255 0 255 ;
: голубая ( -- r g b) 0 255 255 ;
: красная ( -- r g b) 255 0 0 ;
: зеленая ( -- r g b) 0 255 0 ;
: синяя ( -- r g b) 0 0 255 ;
: серая ( n -- r g b) 255 SWAP - DUP DUP ;
: серая10 ( -- r g b ) 10 серая ;
: серая15 ( -- r g b ) 15 серая ;

: rgb>cmyk { r g b \ c m y k -- c m y k }
\ Алгоритм от Борланда
\  C := 255 - R; M := 255 - G;   Y := 255 - B; 
\  if C < M then  K := C else K := M; 
\  if Y < K then  K := Y; 
\  if k > 0 then begin  c := c - k; m := m - k;  y := y - k; end; 
  255 r - TO c  255 g - TO m  255 b - TO y
  c m MIN y MIN TO k
  c k -  m k -  y k - k ;

: >cref ( col -- cref ) DUP 8 LSHIFT OVER 16 LSHIFT OR OR ;
: cref> ( cref -- col ) 0xFF AND ;

\ пересчитывает миллиметры в пиксели
: мм ( n -- n2 ) 3000 254 */ ;

\ пересчитывает типографские пункты в пиксели
: пт ( n -- n2 ) 300 72 */ ;

\ ---------------------------------------------

VARIABLE pen-style  W: ps_solid pen-style !

: linestyle CREATE , DOES> @ pen-style ! ;

W: ps_null       linestyle []
W: ps_solid      linestyle [-]
W: ps_dash       linestyle [--]
W: ps_dashdot    linestyle [.-]
W: ps_dashdotdot linestyle [..-]
W: ps_dot        linestyle [.]

WINAPI: CreatePen  GDI32.DLL

: newpen ( color dc -- )
  >R >cref 1 pen-style @ CreatePen R> SelectObject DeleteObject DROP ;

: Обводка ( r g b -- )
  rgb>cmyk TO k-stroke TO y-stroke TO m-stroke TO c-stroke
  c-stroke c-dc newpen
  m-stroke m-dc newpen
  y-stroke y-dc newpen
  k-stroke k-dc newpen ;

\ --------------------------------------------

VARIABLE brush-style W: bs_solid brush-style !

: fillstyle CREATE , DOES> @ brush-style ! ;
: hatchstyle ( hs -- ) 8 LSHIFT W: bs_hatched OR fillstyle ;

W: bs_solid  fillstyle [o]
W: bs_hollow fillstyle [_]

W: hs_bdiagonal    hatchstyle [/]
W: hs_fdiagonal    hatchstyle [\]
W: hs_horizontal   hatchstyle [=]
W: hs_vertical     hatchstyle [|]
W: hs_cross        hatchstyle [+]
W: hs_diagcross    hatchstyle [X]

WINAPI: CreateBrushIndirect  GDI32.DLL
WINAPI: SetTextColor         GDI32.DLL

: newbrush { color dc \ [ 3 CELLS ] logbrush -- }
  logbrush init->>
  brush-style @ 0xFF AND >>
  color >cref >>
  brush-style @ 8 RSHIFT >>
  logbrush CreateBrushIndirect dc SelectObject DeleteObject DROP
  color >cref dc SetTextColor DROP ;

: Заливка ( r g b -- )
  rgb>cmyk TO k-fill TO y-fill TO m-fill TO c-fill
  c-fill c-dc newbrush
  m-fill m-dc newbrush
  y-fill y-dc newbrush
  k-fill k-dc newbrush ;

\ ----------------------------------------------------

VARIABLE arg1
VARIABLE arg2
VARIABLE arg3
VARIABLE arg4
VARIABLE arg5
VARIABLE arg6
VARIABLE arg7
VARIABLE arg8
VARIABLE cdc
VARIABLE fill
VARIABLE stroke

: 4args arg4 ! arg3 ! arg2 ! arg1 ! ;
: 4args@ arg4 @ arg3 @ arg2 @ arg1 @ ;

: separate ( proc -- )
  >R
  c-dc cdc !  c-fill fill !  c-stroke stroke ! R@ EXECUTE
  m-dc cdc !  m-fill fill !  m-stroke stroke ! R@ EXECUTE
  y-dc cdc !  y-fill fill !  y-stroke stroke ! R@ EXECUTE
  k-dc cdc !  k-fill fill !  k-stroke stroke ! R@ EXECUTE
  RDROP ;

WINAPI: SetPixel GDI32.DLL
: setpixel fill @ >cref arg1 @ arg2 @ cdc @ SetPixel DROP ;
: Точка ( x y -- )
  arg2 ! arg1 ! ['] setpixel separate ;

WINAPI: MoveToEx  GDI32.DLL
WINAPI: LineTo    GDI32.DLL
: line   0 arg2 @ arg1 @ cdc @ MoveToEx DROP
  arg4 @ arg3 @ cdc @ LineTo DROP ; 
: Линия ( x1 y1 x2 y2 -- )
  4args ['] line separate ;

WINAPI: Rectangle  GDI32.DLL
: rectangle  4args@ cdc @ Rectangle DROP ;
: Прямоугольник ( x1 y1 x2 y2 -- )
  4args ['] rectangle separate ;

\ : Скругленный-прямоугольник ;

WINAPI: Ellipse  GDI32.DLL
: ellipse  4args@ cdc @ Ellipse DROP ;
: Эллипс ( x1 y1 x2 y2 -- ) 4args ['] ellipse separate ;

WINAPI: PolyBezier  GDI32.DLL
: curve { \ [ 8 CELLS ] pt -- }
  pt init->>
  arg1 @ >> arg2 @ >>
  arg3 @ >> arg4 @ >>
  arg5 @ >> arg6 @ >>
  arg7 @ >> arg8 @ >>
  4 pt cdc @ PolyBezier DROP ;
: Кривая ( x1 y1  x2 y2  x3 y3  x4 y4 -- )
  arg8 ! arg7 ! arg6 ! arg5 ! arg4 ! arg3 ! arg2 ! arg1 !
  ['] curve separate ; 

\ -------------------------------

: OR! ( n a -- ) SWAP OVER @ OR SWAP ! ;

VARIABLE font-attr   font-attr 0!
: жирный  1 font-attr OR! ;
: курсив 2 font-attr OR! ;
: подчеркнутый  4 font-attr OR! ;
: перечеркнутый 8 font-attr OR! ;

WINAPI: CreateFontA  GDI32.DLL

: create-font ( zname size -- font )
  >R (* default_pitch ff_dontcare *) W: default_quality
  W: clip_default_precis W: out_default_precis W: ansi_charset
  font-attr @ 8 AND  font-attr @ 4 AND  font-attr @ 2 AND 
  font-attr @ 1 AND IF 700 ELSE 400 THEN
  0 0 0 R> CreateFontA 
  font-attr 0! ;
  
: new-fonts  ( font -- )
  DUP c-dc SelectObject DeleteObject DROP
  DUP m-dc SelectObject DeleteObject DROP
  DUP y-dc SelectObject DeleteObject DROP
      k-dc SelectObject DeleteObject DROP ;

: Шрифт ( z size -- ) пт NEGATE create-font new-fonts ;

WINAPI: TextOutA  GDI32.DLL
WINAPI: SetTextAlign  GDI32.DLL
: text
  arg4 @ W: ta_baseline OR cdc @ SetTextAlign DROP
  arg1 @ ZLEN arg1 @ arg3 @ arg2 @ cdc @ TextOutA DROP ;
: Слева ( z x y -- )     W: ta_left   4args ['] text separate ;
: Справа ( z x y -- )    W: ta_right  4args ['] text separate ;
: По-центру ( z x y -- ) W: ta_center 4args ['] text separate ;

WINAPI: GetTextExtentPoint32A GDI32.DLL
: Размер-надписи ( z  -- w h )
  HERE SWAP ASCIIZ> SWAP k-dc GetTextExtentPoint32A
  HERE @ HERE CELL+ @ ;

\ ---------------------------------------
: Создать ( width height -- )
  TO высота TO ширина  
  new-pic TO c-dc TO c-bmp c-pic !
  new-pic TO m-dc TO m-bmp m-pic !
  new-pic TO y-dc TO y-bmp y-pic !
  new-pic TO k-dc TO k-bmp k-pic !
  черная Обводка  черная Заливка ;

: set-fields
  program-name 305 tiff!  \ software
  ширина 256 tiff!        \ imagewidth
  высота 257 tiff!        \ imageheight
  5 259 tiff!		  \ compression: lzw
  8 258 tiff!		  \ bits/sample
  1 284 tiff!             \ planarconfig: contig
  2 296 tiff!             \ resunits: inches
  \  x resolution: поскольку библиотека в этом месте хочет float,
  \ заставить ее работать я не смог. Поэтому
  0 0 282 tiff2!      \ выставляем внутренние флажки, что это значение присутствует
  0x43960000 tiff 26 CELLS! \ и записываем 300.00 во внутреннюю структуру
  \ Слава открытым исходным текстам!
  0 0 283 tiff2!        \ тот же фокус с yresolution
  0x43960000 tiff 27 CELLS! ;

: load-err ( z -- ) >R <( R> " Не могу загрузить файл: ~Z" )> error ;

: tifftype ( -- type)
  258 tiff@ 8 <> IF " биты/канал<>8" load-err FALSE EXIT THEN
  284 tiff@ 1 <> IF " изображение разбито на плоскости" load-err FALSE EXIT THEN
  262 tiff@ ;

VARIABLE samples
VARIABLE extrasamples
0 VALUE buf
0 VALUE last-width
0 VALUE last-height

\ Прозрачность понимается в стиле Фотошопа:
\ используется первый дополнительный канал (тип unspecified)
\ в котором 0 - 100% перекрытие, 255 - полная прозрачность

0 == gray
1 == cmyk

: grayscale ( a -- ) C@ C>> ;
: gray-updown ( a -- ) C@ 255 SWAP - C>> ;
: rgb2cmyk ( a -- )
  DUP C@ SWAP 1+ DUP C@ SWAP 1+ C@ rgb>cmyk ( c m y k)
  2SWAP SWAP C>> C>> SWAP C>> C>> ;
: justcmyk ( a -- ) DUP C@ C>> 1+ DUP C@ C>> 1+ DUP C@ C>> 1+ C@ C>> ;
: alpha ( a -- ) samples @ + C@ 255 SWAP - C>> ;

: read-channels { n proc \ proc2 -- buf type alpha }
  n samples !
  277 tiff@ samples @ - extrasamples !
  256 tiff@ TO last-width
  257 tiff@ TO last-height
  last-width last-height *
  samples @ DUP 3 = IF DROP 4 THEN
  extrasamples @ 1 MIN + *
  GETMEM DUP TO buf init->>
  extrasamples @ IF ['] alpha ELSE ['] DROP THEN TO proc2
  last-height 0 ?DO
    0 I HERE tiff TIFFReadScanline DROP
    last-width 0 ?DO
      I samples @ extrasamples @ + * HERE + DUP proc EXECUTE proc2 EXECUTE
    LOOP
  LOOP
  buf
  samples @ 1 = IF gray ELSE cmyk THEN
  extrasamples @
  last-width last-height ;

: load-tiff ( filename -- buf type alpha width height )
  " r" SWAP TIFFOpen TO tiff
  tiff 0= IF EXIT THEN
  tifftype ?DUP 0= IF EXIT THEN
  CASE
    0 OF 1 ['] grayscale   read-channels ENDOF
    1 OF 1 ['] gray-updown read-channels ENDOF
    2 OF 3 ['] rgb2cmyk    read-channels ENDOF
    5 OF 4 ['] justcmyk    read-channels ENDOF
  DROP " неизвестный тип изображения" load-err
  ENDCASE
  tiff TIFFClose DROP ;

\ ------------------------------------

\ Формат объекта:
0
CELL -- :buf
CELL -- :type
CELL -- :alpha
CELL -- :w
CELL -- :h
== obj#

: Прочитать ( filename obj -- )
  >R load-tiff
  R@ :h !
  R@ :w !
  R@ :alpha !
  R@ :type !
  R> :buf ! ;

: object ( ->bl; -- a ) CREATE HERE 0 , 4 CELLS ALLOT ;

: Объект ( ->bl; z -- ) object Прочитать ;

: Размеры ( o -- w h) DUP :w @ SWAP :h @ ;

: k> ( from to-off -- )
  >R C@ R> k-pic @ + C! ;

: a> ( c alpha to -- )
\ cover*mask/255 + cunder*(mask-255)/255
  >R DUP >R ( c a ) 255 */ R> 255 SWAP - R@ C@ SWAP 255 */ + R> C! ;

: ka> ( from to-off -- )
  >R DUP C@ SWAP 1+ C@ R> k-pic @ + a> ;  

: cmyk> ( from to-off -- ) >R
     DUP C@ R@ c-pic @ + C!
  1+ DUP C@ R@ m-pic @ + C!
  1+ DUP C@ R@ y-pic @ + C!
  1+     C@ R> k-pic @ + C! ;

: cmyka> ( from to-off -- ) 
  OVER 4 + C@ 255 SWAP - >R >R
     DUP C@ 2R@ c-pic @ + a>
  1+ DUP C@ 2R@ m-pic @ + a>
  1+ DUP C@ 2R@ y-pic @ + a>
  1+     C@ 2R> k-pic @ + a> ;

: put-part { o ox oy ow oh x y bytes putproc \ owidth buf -- }
  ox 0 MAX TO ox
  oy 0 MAX TO oy
  o :w @ DUP TO owidth  ox - ow MIN TO ow
  o :h @ oy - oh MIN TO oh
  x 0 MAX TO x
  y 0 MAX TO y
  ширина x - ow MIN TO ow
  высота y - oh MIN TO oh
  o :buf @ TO buf
  oh 0 ?DO
    ow 0 ?DO
      oy J + owidth * ox + I + bytes * buf +
      y J + ширина * x + I +
      putproc EXECUTE
    LOOP 
  LOOP ;

: Наложить-часть ( o ox oy owidth oheight x y -- )
  6 PICK DUP :type @ gray = IF
    :alpha @ IF 2 ['] ka> ELSE 1 ['] k> THEN
  ELSE
    :alpha @ IF 5 ['] cmyka> ELSE 4 ['] cmyk> THEN
  THEN
  put-part ;

: Наложить ( o x y -- )
  2>R 0 OVER 0 SWAP DUP :w @ SWAP :h @ 2R> Наложить-часть ;

: Загрузить { filename \ [ obj# CELLS ] o -- }
  filename o Прочитать
  o :w @ o :h @ Создать
  o 0 0 Наложить
  o :buf @ FREEMEM ;

: Из-файла ( z -- )
  ASCIIZ> INCLUDED ;

\ ----------------------------------

: Сохранить { filename \ ptr -- }
  " w" filename TIFFOpen TO tiff
  tiff 0= IF EXIT THEN
  set-fields
  4 277 tiff!		  \ samples/pixel
  255 0 336 tiff! DROP	  \ dot range
  5 262 tiff!		  \ photometric: separated
  1 332 tiff!		  \ inkset: cmyk
  ширина 4 * GETMEM TO buf
  0 TO ptr
  высота 0 ?DO
    buf init->>
    ширина 0 ?DO
      c-pic @ ptr + C@ C>>
      m-pic @ ptr + C@ C>>
      y-pic @ ptr + C@ C>>
      k-pic @ ptr + C@ C>>
      ^ ptr 1+!
    LOOP
    0 I buf tiff TIFFWriteScanline DROP
  LOOP
  buf FREEMEM
  tiff TIFFClose DROP ;

: Сохранить-ч/б { filename -- }
  " w" filename TIFFOpen TO tiff
  tiff 0= IF EXIT THEN
  set-fields
  1 277 tiff!		  \ samples/pixel
  0 262 tiff!		  \ photometric: min-is-black
  высота 0 ?DO
    0 I ширина I * k-pic @ + tiff TIFFWriteScanline DROP
  LOOP
  tiff TIFFClose DROP ;

\ -----------------------------------
:NONAME ( -- )
  c-dc DeleteDC DROP
  m-dc DeleteDC DROP
  y-dc DeleteDC DROP
  k-dc DeleteDC DROP
  c-bmp DeleteObject DROP
  m-bmp DeleteObject DROP
  y-bmp DeleteObject DROP
  k-bmp DeleteObject DROP
  BYE ; TO final-exit

\ ---------------------------------------------------------------

: ?next ( "name" или name<BL> -- a # / 0)
  PeekChar c: " = IF c: " ELSE BL THEN WORD
  DUP C@ 0= IF DROP 0 EXIT THEN
  COUNT OVER C@ c: " = IF 2 - SWAP 1+ SWAP THEN ( убрал кавычки, если есть) ;

: RUN
  -1 TO SOURCE-ID
  GetCommandLineA ASCIIZ> SOURCE!
  ?next 2DROP  \ убрали имя файла
  ?next 
  ?DUP 0= IF
   ." GED 1.00 -- Пакетный графический редактор" CR
   ." Ю. Жиловец, 2002 (http://www.forth.org.ru/~yz)" CR
  BYE
  THEN
  ['] tifferror TIFFSetErrorHandler DROP
  ( a # ) ['] INCLUDED CATCH
  ?DUP IF
    CASE
      2 3 <OF< " Входной файл не найден" err 0 ENDOF
      -2003 OF " Неизвестное слово"  ENDOF
      0xC0000005 OF " Нарушение общей защиты" ENDOF
    >R <( R> DUP " Ошибка ~N (0x~06H)" )>
    END-CASE
    error
  THEN
  final-exit ;

0 TO SPF-INIT?
' ANSI>OEM TO ANSI><OEM
\ TRUE TO ?GUI
' RUN MAINX !
S" ged.exe" SAVE  
BYE
