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


: STORAGE-ID ( -- h )
  STORAGE @
;
: (DISMOUNT) ( -- h dp )
  STORAGE @  DP @
;
: (MOUNT) ( h dp -- )
  DP !  STORAGE !
;
: (FORMAT) ( addr u -- h )
  DUP 64 CELLS U< ABORT" storage too small to format"
  OVER 4 CELLS 2DUP ERASE
  OVER + SWAP !           \ <!-- 0, dp   -->
                          \ <!-- 1, ext-cell -->
                          \ <!-- 2, dstack -->
  OVER + OVER 3 CELLS + ! \ <!-- 3, bound -->
;
: FORMAT ( addr u -- h )
  (DISMOUNT) 2>R
  (FORMAT) DUP @ (MOUNT)  AT-FORMATING   (DISMOUNT) OVER ! ( h )
  2R> (MOUNT)
;
: DISMOUNT ( -- h )
  STORAGE @ DUP IF AT-DISMOUNTING  (DISMOUNT) SWAP !   DP 0! STORAGE 0! THEN
;
: MOUNT ( h -- )
  DUP STORAGE-ID = IF DROP EXIT THEN
  DISMOUNT DROP
  DUP IF DUP @  (MOUNT)  AT-MOUNTING  EXIT THEN DROP
;
: PUSH-MOUNT ( h -- ) \ применять к одному хранилищу не более чем единыжды
  DISMOUNT OVER CELL+ CELL+ !
  MOUNT
;
: POP-MOUNT ( -- h )
  DISMOUNT DUP CELL+ CELL+ @ MOUNT
;
: UNUSED ( -- u ) \ 94 CORE EXT
  STORAGE-ID DUP IF 3 CELLS + @   DP @ - THEN
;
: STORAGE-REST ( -- a u ) \ free space
  DP @ UNUSED
;
: STORAGE-CONTENT ( -- a u ) \ busy space
  STORAGE-ID DP @ OVER -
;
: CODESPACE-CONTENT ( -- a u )
  STORAGE-CONTENT
;
: FLUSH-STORAGE ( -- )
  DISMOUNT MOUNT
;
: STORAGE-EXTRA ( -- a ) \ для расширений; переопределяется каждым следующим расширением.
  STORAGE-ID CELL+
;