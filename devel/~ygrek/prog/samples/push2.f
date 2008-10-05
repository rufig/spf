\ $Id$
\ 
\ X/Motif example -- http://www.cs.cf.ac.uk/Dave/X_lecture/node5.html

USE libXm.so.3
USE libXt.so.6
USE libX11.so.6

0 CONSTANT NULL

VARIABLE top_wid
VARIABLE button
VARIABLE app

VARIABLE argv
VARIABLE argc

:NONAME 
  ." Don't Push Me!!" CR 
  0 
; 3 CELLS CALLBACK: pushed_fn

: main
    \ initialize Xt and create top widget
    (( app S" Push" DROP 0 0 argc argv 0 0 )) XtVaAppInitialize top_wid !

    \ create button
    (( top_wid @ S" Push_me" DROP NULL 0 )) XmCreatePushButton button !

    \ tell Xt to manage button
    (( button @ )) XtManageChild DROP
   
    \ attach callback to widget
    (( button @ S" activateCallback" DROP ['] pushed_fn NULL )) XtAddCallback DROP
    
    \ display widget hierarchy
    (( top_wid @ )) XtRealizeWidget DROP

    \ enter processing loop
    (( app @ )) XtAppMainLoop DROP
;

main
