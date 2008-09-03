: (VOCS) ( wid -- )
  VOC-NAME. SPACE 1+
;
: VOCS ( -- )
  0 ['] (VOCS) ENUM-VOCS-FORTH
  CR ." Vocs: " . CR
;
