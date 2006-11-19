
: ok-cancel
   GRID
   " Ok" ['] dialog-ok ok-button  |
   " Cancel" cancel-button  -xspan |
   GRID;
;

MODULE: F.Options 

\ 300 VALUE width

: my-grid
   GRID
     \ " Options" label |
     \ ===
     ok-cancel |
   GRID;
;

PROC: my-dlg ( -- )

    " Options" MODAL...

    my-grid SHOW

    ...MODAL
PROC;

;MODULE
