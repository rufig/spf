\ $Id$
\ 
\ X/Motif example -- http://www.cs.cf.ac.uk/Dave/X_lecture/node5.html

REQUIRE SO ~ac/lib/ns/so-xt.f

\ important: link Xm before Xt
\ http://www.faqs.org/faqs/motif-faq/part9/section-29.html
ALSO SO NEW: libXm.so.3
ALSO SO NEW: libXt.so.6
ALSO SO NEW: libX11.so.6

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
    NULL NULL argv argc 0 NULL S" Push" DROP app 8 XtVaAppInitialize top_wid !

    \ create button
    0 NULL S" Push_me" DROP top_wid @ 4 XmCreatePushButton button !

    \ tell Xt to manage button
    button @ 1 XtManageChild DROP
   
    \ attach callback to widget
    NULL ['] pushed_fn S" activateCallback" DROP button @ 4 XtAddCallback DROP
    
    \ display widget hierarchy
    top_wid @ 1 XtRealizeWidget DROP

    \ enter processing loop
    app @ 1 XtAppMainLoop DROP
;

main
