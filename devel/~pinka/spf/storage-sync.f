\ Nov.2008

REQUIRE FORTH-STORAGE   ~pinka/spf/storage.f
REQUIRE CREATE-CS       ~pinka/lib/multi/Critical.f

CREATE-CS _CS-FORTH-STORAGE \ для последовательного доступа к базовому хранилищу

: (WITHIN-FORTH-STORAGE-EXCLUSIVE) ( xt -- )
  FORTH-STORAGE MOUNT EXECUTE
;
: WITHIN-FORTH-STORAGE-EXCLUSIVE ( i*x  xt --  j*x ) \ эм.. не слишком ли длинное имя ;)
  _CS-FORTH-STORAGE ENTER-CS
  DISMOUNT >R 
  ['] (WITHIN-FORTH-STORAGE-EXCLUSIVE) CATCH ( ior )
  R> MOUNT
  _CS-FORTH-STORAGE LEAVE-CS
  ( ior ) THROW
;

(  FORTH-STORAGE -- это базовое хранилище, аналогично тому,
 как FORTH-WORDLIST -- основной список слов.
 Чтобы откладывать код в базовое хранилище из дочерних потоков,
 требуется после сборки освободить главный поток от владения
 базовым хранилищем фразой DISMOUNT DROP
)
