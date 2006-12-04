\ $Id$

HEX
: R>     ['] C-R>    INLINE, ;   IMMEDIATE
: >R     ['] C->R    INLINE, ;   IMMEDIATE
: RDROP  ['] C-RDROP INLINE, ;   IMMEDIATE

: ?DUP   STATE @
                 IF  HERE TO :-SET
                      ['] C-?DUP  INLINE,
                     HERE TO :-SET \ нужно как в THEN
                 ELSE ?DUP
                 THEN ;   IMMEDIATE

: EXECUTE STATE @ IF
                  ['] C-EXECUTE INLINE,
                  ELSE EXECUTE
                  THEN ; IMMEDIATE
                                    
DECIMAL