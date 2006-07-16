\ FARLIB 0.0

\ $Id$

: ThisItem -id@ Items. get ;
AUS TFarDialogItem ThisItem

: send-to-dialog ( param2 param1 Msg hDlg -- result) FARAPI. SendDlgMessage @ API-CALL ;
: send ( param2 param1 msg win -- result) -hdlg@ send-to-dialog ;
\ Посылаем сообщение диалогу содержащему элемент с param1=id этого контрола
: ctlsend ( param2 ctl message -- ) SWAP DUP -id@ -ROT -parent@ send ;

\ : send0 ( win message -- n/ )  SWAP 0 0 2SWAP send ;
\ : send1 ( param1 win message -- n/ ) >R 0 -ROT R> SWAP send ;
\ : send2 ( param2 win message -- n/ ) 0 -ROT SWAP send ;

\ : param! ( param hdlg -- ) >R 0 W: dm_setdlgdata R> send-to-dialog DROP ;
\ : param@ ( hdlg -- param) >R 0 0 W: dm_getdlgdata R> send-to-dialog ;

: >ASCIIZ ( addr u -- z ) OVER + 0 SWAP C! ;

0 VALUE ?run

: run: ( xt1 xt2 -- ) 
   CREATE , , 
   DOES> ?run IF CELL+ THEN @ EXECUTE ; 

: load: ( xt -- )
  CREATE , 
  DOES> ?run IF ABORT" No runtime" THEN @ EXECUTE ;

:NONAME 0 SWAP W: dm_gettextlength ctlsend ;
:NONAME ThisItem. Data ZLEN ;
run: -text# ( ctl -- n )

:NONAME W: dm_settextptr ctlsend DROP ;
:NONAME ThisItem. Data ZMOVE ;
run: set-text ( z ctl -- )

:NONAME OVER >R W: dm_gettextptr ctlsend R> + 0 SWAP C! ;
:NONAME ThisItem. Data SWAP ZMOVE ;
run: get-text ( z ctl -- )

:NONAME ThisItem. ItemType @ ; load: get-type
:NONAME ThisItem. ItemType ! ; load: set-type

:NONAME ThisItem. X1 @ ; load: get-x1 ( ctl -- x1 )
:NONAME ThisItem. X2 @ ; load: get-x2 ( ctl -- x2 )
:NONAME ThisItem. Y1 @ ; load: get-y1 ( ctl -- y1 )
:NONAME ThisItem. Y2 @ ; load: get-y2 ( ctl -- y2 )
:NONAME ThisItem. X1 ! ; load: set-x1 ( x1 ctl -- )
:NONAME ThisItem. X2 ! ; load: set-x2 ( x2 ctl -- )
:NONAME ThisItem. Y1 ! ; load: set-y1 ( y1 ctl -- )
:NONAME ThisItem. Y2 ! ; load: set-y2 ( y2 ctl -- )


