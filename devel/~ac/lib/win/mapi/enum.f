REQUIRE {              ~ac/lib/locals.f
REQUIRE PT_STRING8     ~ac/lib/win/mapi/const.f
REQUIRE IID_IMAPISession ~ac/lib/win/mapi/interfaces.f

: MapiRowProp@ { row pt \ addr nprop prow -- val1 val2 true  | false }
\ вернуть истину и значение свойства, если такое свойство в записи есть
  row CELL+ @ -> nprop row CELL+ CELL+ @ -> addr
  nprop 0 ?DO
    addr I 16 * + -> prow
    prow @ pt =
    IF prow CELL+ CELL+ CELL+ @  prow CELL+ CELL+ @ \ addr u для binary или 0 addr для строки
       UNLOOP TRUE EXIT
    THEN
  LOOP FALSE
;
: MapiRowStr@ { row pt -- val1 val2 true  | false }
  row pt MapiRowProp@
  IF pt 0xFFFF AND PT_STRING8 =
     IF NIP ASCIIZ> THEN TRUE
  ELSE FALSE THEN
;
: MapiRow@ { rs pt val1 val2 -- row }
\ найти в наборе записей запись с заданным значением свойства
  rs
  DUP CELL+ SWAP @ 0 ?DO
    DUP I 12 * +
      ( row ) pt MapiRowProp@
      IF pt 0xFFFF AND PT_STRING8 = 
         IF NIP ASCIIZ> val1 val2 COMPARE 0=
         ELSE val2 = SWAP val1 = AND THEN
         IF I 12 * + UNLOOP EXIT THEN
      THEN
  LOOP DROP 0
;
: MapiProp@ { cobj pr \ np arr val -- x1 x2 }
\ см. также HrGetOneProp
  1 -> np  \ ^ np указатель на массив свойств вида CREATE RootProp 1 , PR_IPM_SUBTREE_ENTRYID ,
  ^ arr ^ val 0 ^ np cobj ::GetProps 
  DUP MAPI_W_ERRORS_RETURNED = IF DROP 0 0 EXIT THEN THROW
  val IF arr CELL+ CELL+ CELL+ @ arr CELL+ CELL+ @ 
         arr @ 0xFFFF AND PT_STRING8 = 
         IF NIP ASCIIZ> THEN
      ELSE 0 0 THEN
;
: MapiProp! { x1 x2 cobj pr \ obj -- }
  cobj -> obj 0 -> cobj \ структура props на стеке возвратов
  pr 0xFFFF AND PT_STRING8 =
  IF x1 -> x2 0 -> x1 THEN
  0 ^ pr 1 obj ::SetProps THROW
;
: MapiForEach { rs xt -- }
\ выполнить xt для каждого элемента набора записей
  rs
  DUP CELL+ SWAP @ 0 ?DO
    DUP I 12 * + xt EXECUTE
  LOOP DROP
;
