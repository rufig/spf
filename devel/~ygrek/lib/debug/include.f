\ $Id$
\ 
\ Show all included source files (in order)

:NONAME
  2DROP
  CR
  INCLUDE-DEPTH @ 2 * SPACES
  CURFILE @ ASCIIZ> 2DUP TYPE
  (INCLUDED1) 
; 
TO (INCLUDED)
