\ тупая медленная реализация
\ только для английских букв
\ :)
\ но быстрее, чем вызов WINAPI

: UPPERCASE ( addr1 u1 -- )
  0 ?DO
     DUP I + C@ DUP 96 >
     OVER 123 < AND
     IF 32 - OVER I + C!
     ELSE DROP THEN
  LOOP DROP
;