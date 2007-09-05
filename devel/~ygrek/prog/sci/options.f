
: ok-cancel
   GRID
   Z" Ok" ['] dialog-ok ok-button  |
   Z" Cancel" cancel-button  -xspan |
   GRID;
;

MODULE: F.Options 

\ 300 VALUE width

: my-grid
   GRID
     \ Z" Options" label |
     \ ===
     ok-cancel |
   GRID;
;

PROC: my-dlg ( -- )

    Z" Options" MODAL...

    my-grid SHOW

    ...MODAL
PROC;

;MODULE
