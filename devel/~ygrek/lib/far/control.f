\ FARLIB 0.0

\ $Id$

\ Полностью копия с WinLib by ~yz 
\ http://www.forth.org.ru/~yz/lib/winctl.f

REQUIRE Items ~ygrek/lib/far/dialog.f

\ ------------------------------
\ Полезные процедуры

\ свойства общие для всех элементов диалога
0 table control
  item -id		\ идентификатор элемента
  item -type	getset	\ типа элемента DI_*
  item -flags 	       	\ флаги контрола
  item -x1	getset
  item -x2	getset
  item -y1	getset
  item -y2	getset
  item -focus		\ флаг - установить фокус на этот элемент
  item -defbutton	\ флаг - сделать кнопкой по умолчанию
  item -extra 		\ зависит от типа элемента
  item -text	getset	\ максимальный размер строки - 512 символов. 
  item -data		\ Data
  item -userdata        \ пользовательские данные
  item -align 	 	\ выравнивание текста
  item -locked          \ нельзя менять размеры
  item -parent		\ хэндл диалога в котором размещается этот элемент
  \ специализированные слова
  item -calcsize        \ слово вычисления размеров окна
  item -ctlshow         \ слово показа элемента
  item -ctlhide         \ слово отключения показа элемента
  item -ctladdpart      \ добавление внутренних частей к окну
endtable

FALSE VALUE ?focus \ флаг - был ли среди элементов уже элемент с фокусом 
                   \ (для того чтобы отбросить все последующие)
FALSE VALUE ?defbutton \ аналогично для кнопки по умолчанию

REQUIRE set-text ~ygrek/lib/far/details.f

' get-text ' set-text -text control setitem
' get-type ' set-type -type control setitem
' get-x1 ' set-x1 -x1 control setitem
' get-x2 ' set-x2 -x2 control setitem
' get-y1 ' set-y1 -y1 control setitem
' get-y2 ' set-y2 -y2 control setitem

: ctl-destroy DROP ;

(
: ctlsetposition { left top right bottom ctl \ [ 2 4 * ] smallrect -- }
    smallrect init->>
    left W>>
    top W>>
    right W>>
    bottom W>>
    smallrect ctl W: dm_setitemposition ctlsend 0= ABORT" Bad ID" ;
 )
: ctlresize { x y ctl \ -- }
    ACCERT3( CR ." ctlresize " ctl -id@ . x . y . )
    ctl -x1@ x + ctl -x2!
    ctl -y1@ y + ctl -y2! ;

: ctlmove { x y ctl \ -- }
    ACCERT3( CR ." ctlmove " ctl -id@ . x . y . )
    ctl -x1@ x + ctl -x1!
    ctl -x2@ x + ctl -x2!
    ctl -y1@ y + ctl -y1!
    ctl -y2@ y + ctl -y2! ;

: ctl-size { ctl \ -- x y }
   ACCERT3( CR ." ctl-size " ctl -id@ . )
   ctl -x2@ ctl -x1@ - ACCERT3( DUP . )
   ctl -y2@ ctl -y1@ - ACCERT3( DUP . )
   ;


: set-parent 
   DROP EXIT
   { \ ctl Item -- }
   TEMPAUS TFarDialogItem Item
   ctl -flags@ Item. Flags !
   ctl -extra@ Item. Selected !
   ?focus 0= IF ctl -focus@ DUP Item. Focus ! TO ?focus THEN
   ?defbutton 0= IF ctl -defbutton@ DUP Item. DefaultButton ! TO ?defbutton THEN
 ;

USER-VALUE this

\ -----------------------------------
\ Элементы управления

: create-control ( table DI_TYPE -- ctl/0 )
  SWAP new-table TO this
  ItemsNumber this -id!
  this -type!
  " default" this -text!
  current-window this -parent!
  ItemsNumber 1+ TO ItemsNumber
  this ;

: size-of-text ( ctl -- x y ) -text# 1 ;

\ --------------------------------
\ Статические элементы

0 == left
1 == center
2 == right

control table buttonlike
  item -xpad		\ горизонтальное расстояние от текста до края
  item -ypad		\ вертикальное расстояние от текста до края
\  item -state	getset
endtable

: +pads { x y ctl -- x1 y1 }
  ctl -xpad@ 2* x +  ctl -ypad@ 2* y + ;

: resize-if-unlocked ( xsize ysize win -- )
  DUP -locked@ IF DROP 2DROP ELSE ctlresize THEN ;

: adjust-size { ctl -- }
  ctl size-of-text  ctl +pads  ctl resize-if-unlocked ;

:NONAME { z ctl -- }
  z ctl set-text
  ctl adjust-size 
; -text buttonlike storeset

: label ( z -- ctl)
  buttonlike W: DI_TEXT create-control >R
  R@ -text!
  R> ;

: groupbox ( z -- ctl )
  control W: DI_SINGLEBOX create-control >R
  R@ -text! 
  R> ;

\ -----------------------------
\ Кнопки

: button ( z -- ctl)
  buttonlike W: DI_BUTTON create-control >R
  2 R@ -xpad!
  R@ -text!
  R> ;

\ -----------------------------
\ Поля ввода

: edit ( z -- ctl )
  control W: DI_EDIT create-control >R
  R@ -text!
  R> ;

: fixedit 
   control W: DI_FIXEDIT create-control >R
   R@ -text!
   R> ;

\ : limit-edit ( n ctl -- ) W: dm_setmaxtextlength ctlsend 0= IF ABORT" limit-edit error" THEN ;

\ -----------------------------
\ Размещение объектов

: place ( x y ctl -- ) ctlmove ;

: another-place place ;

: resize ctlresize ;

\ Быстрая инициализация текущего объекта
\ (/ -font f  -color blue  -bgcolor white  /)

\ Более хитрые вещи:
\ (/ -name value-var  -size 100 200 /)

-1 == -size

: (/  (( ;
: /) ( ... -- )
  )) 2DUP < IF
  DO
    I @ CASE
    -size OF 
      I CELL- @ I 2 CELLS - @ this ctlresize
      3 ( параметра)
    ENDOF
      I CELL- @ SWAP this setproc
      2 ( параметра)
    END-CASE
  CELLS NEGATE +LOOP
  ELSE
    2DROP
  THEN remove-stack-block
;

: -name ( ->bl; -- ) POSTPONE this [COMPILE] TO ; IMMEDIATE

: ctlshow DROP ;
: ctlhide DROP ;

: max-win-size DROP 80 25 ;

REQUIRE GRID ~ygrek/~yz/lib/wingrid.f

: -boxed ( -- ) "" groupbox  cur-grid @ :gbox ! ;

:NONAME -left -top  1 -xmargin  1 -ymargin  0 -width  0 -height ; TO defaultbind

WARNING @
WARNING 0!

: NEWDIALOG
    FALSE TO ?run
    0 TO ItemsNumber
    NEWDIALOG ;

: RUNDIALOG
   winmain resize-window-grid
   winmain -grid@ winmain -grid!
   TRUE TO ?run
   RUNDIALOG ;

WARNING !


