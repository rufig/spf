REQUIRE create-object ~yz/lib/automation.f

0 VALUE shell
0 VALUE folder
0 VALUE item

: Z.R ( z n -- )
  OVER .ansiz SWAP ZLEN - 0 MAX SPACES ;

: show-desktop

 COM-init DROP

 " Shell.Application" create-object 
 IF " Не могу запустить объект Shell.Application" .ansiz BYE THEN
 TO shell

 arg( 17 _int )arg shell :: NameSpace > 
 DROP TO folder

 arg() folder :: Items >
 DROP

 " Объект" 20 Z.R  " Имя" 25 Z.R  " Размер" 12 Z.R " Свободно" 12 Z.R CR
 69 0 DO c: - EMIT LOOP CR
 FOREACH
   OBJ-I DROP TO item
   arg( item _obj 1 _int )arg folder :: GetDetailsOf >
   DROP DUP 20 Z.R FREEMEM 
   arg( item _obj 0 _int )arg folder :: GetDetailsOf >
   DROP DUP 25 Z.R FREEMEM 
   arg( item _obj 2 _int )arg folder :: GetDetailsOf >
   DROP DUP 12 Z.R FREEMEM 
   arg( item _obj 3 _int )arg folder :: GetDetailsOf >
   DROP DUP 12 Z.R FREEMEM 
   CR
   item release
 NEXT

KEY DROP

folder release
shell release

COM-destroy ;

show-desktop

BYE
