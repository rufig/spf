\ Dec.2006, ruvim@forth.org.ru

( Работа с хранилищем имеет метафорой работу с логическими дисками, или FS,
  их монтирование и демонтирование.

  Станок, инструментарий для доступа к хранилищу
  составляет лексикон слов, откладывающих код и данные,
  как то ALLOT, ',', 'C,', 'LIT,', '2LIT,' 'SLIT,' и т.п.
  Этот станок работает с пристыкованным к нему хранилищем.
  Пристыковка делается командой MOUNT [ h -- ],
  отстыковка -- командой DISMOUNT  [ -- h ], /или, лучше UNMOUNT ?/
  приведение сырого блока памяти к виду хранилища -- командой FORMAT [ addr u -- h ].
  Слово MOUNT перед пристыковкой само освобождает станок отстыковкой,
  если он был занят.

  Реализованный ниже вариант поддерживает доопределение и расширение
  через механизм разбросанного [прерывистого] определения
  [Scattering a Colon Definition].
)


( Модуль предполагает доступность слов-переменных DP и STORAGE
  к которым и привязывается.
)

: AT-MOUNTING    ( -- ) ... ;
: AT-DISMOUNTING ( -- ) ... ;
: AT-FORMATING   ( -- ) ... ;
\ когда инициируются данные события,
\ целевое хранилище еще|уже является текущим.


\ DataType( h-storage = a-addr[+ storage-header ] )
\ DataTypeLayout( storage-header = addr.here  x.reserved  x.pushed[h-storage|0]  addr.border )


: STORAGE-ID ( -- h-storage|0 )
  STORAGE @
;
: (DISMOUNT) ( -- h-storage addr.here|0  ||  -- 0 0 )
  STORAGE @  DP @
;
: (MOUNT) ( h-storage addr.here|0 --  ||  0 0 -- )
  DP !  STORAGE !
;

: (FORMAT) ( a-addr1[+ u1*byte] u1 -- a-addr1[h-storage] )
  DUP 64 CELLS U< ABORT" storage too small to format"
  OVER 4 CELLS 2DUP ERASE
  OVER + SWAP !           \ <!-- 0, dp   -->
                          \ <!-- 1, ext-cell -->
                          \ <!-- 2, dstack -->
  OVER + OVER 3 CELLS + ! \ <!-- 3, bound -->
;
: FORMAT ( a-addr1[+ u1*byte] u1 -- a-addr1[h-storage] )
  (DISMOUNT) 2>R
  (FORMAT) DUP @ (MOUNT)  AT-FORMATING   (DISMOUNT)  ( a-addr1 addr.here )
  OVER !   ( a-addr1[h-storage] )
  2R> (MOUNT)
;
: DISMOUNT ( -- h-storage|0 )
  STORAGE @ DUP IF
    DP @ 255 U> IF AT-DISMOUNTING  (DISMOUNT) SWAP ! THEN
    DP 0! STORAGE 0!
  THEN
;
: MOUNT ( h-storage|0 -- )
  DUP STORAGE-ID = IF DROP EXIT THEN
  DISMOUNT DROP
  DUP IF DUP @  (MOUNT)  AT-MOUNTING  EXIT THEN DROP
;
: MOUNT-RO ( h-storage|0 -- ) \ mounts for read-only
\ it skips AT-MOUNTING and then AT-DISMOUNTING for given storage
  DISMOUNT DROP
  DUP IF 0 (MOUNT) EXIT THEN DROP
;
: PUSH-MOUNT ( h-storage -- ) \ применять к одному хранилищу не более чем единыжды
  DISMOUNT OVER CELL+ CELL+ !
  MOUNT
;
: POP-MOUNT ( -- h-storate )
  DISMOUNT DUP CELL+ CELL+ @ MOUNT
;
: UNUSED ( -- u ) \ 94 CORE EXT
  STORAGE-ID DUP IF 3 CELLS + @   DP @ - THEN
;
: STORAGE-REST ( -- addr[+ u1*byte] u1 ) \ free space
  DP @ UNUSED
;
: STORAGE-CONTENT ( -- a-addr[+ u1*byte] u1 ) \ busy space
  STORAGE-ID DP @ OVER -
;
: CODESPACE-CONTENT ( -- a-addr[+ u1*byte] u1 )
  STORAGE-CONTENT
;
: FLUSH-STORAGE ( -- )
  DISMOUNT MOUNT
;
: STORAGE-EXTRA ( -- a-addr[+ x.reserved] ) \ для расширений; переопределяется каждым следующим расширением.
  STORAGE-ID CELL+
;
