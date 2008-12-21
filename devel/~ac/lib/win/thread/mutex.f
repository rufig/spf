REQUIRE STR@         ~ac/lib/str5.f
REQUIRE CreateEveryoneACL ~ac/lib/win/access/nt_access.f 
REQUIRE CREATE-MUTEX  lib/win/mutex.f
REQUIRE WinNT?        ~ac/lib/win/winver.f

\ операции с мутексами (~pig)
\ создать мутекс
\ name - имя мутекса
\ mut - адрес переменой для хранения хэндла
: CREATE-MUTEX-EX ( S" name" mut -- )
  DUP @						\ хэндл уже хранится?
  IF DROP 2DROP EXIT THEN			\ повторно не создавать
  -ROT " {s}" STR@ FALSE CREATE-MUTEX THROW	\ создать мутекс
  OVER !					\ запомнить хэндл
  WinNT?					\ если Windows NT, требуется добавить прав
  IF
    CreateEveryoneACL ?DUP			\ создать ACL для группы Everyone
    IF
      NIP " ACL: {n}" STYPE CR			\ не получилось - поругаться в основной лог
    ELSE
      OVER @ SetObjectACL DROP			\ задать права доступа к мутексу
    THEN
  THEN
  DROP						\ ссылка больше не нужна
;
\ синхронизация посредством мутекса
\ xt - токен синхронизируемого слова
\ mut - адрес переменной, где хранится (или не хранится) хэндл мутекса
: SYNC-MUTEX ( xt mut -- )
  @ DUP >R					\ мутекс имеется?
  IF -1 R@ WAIT THROW DROP THEN			\ да - захватить
  CATCH						\ выполнить заказанные действия
  R> ?DUP					\ мутекс имеется?
  IF RELEASE-MUTEX DROP THEN			\ да - освободить
  THROW						\ передать ошибку дальше
;
