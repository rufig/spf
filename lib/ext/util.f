\ Вспомогательные слова для работы спф как форт системы для
\ Win32


: TryOpenFile ( addr u mode -- u ior | handle 0 )
 \ Либо абсолютный путь, либо добавить module path либо в /devel
    >R
    2DUP R@ OPEN-FILE-SHARED
    IF DROP 2DUP
       +ModuleDirName
       R@ OPEN-FILE-SHARED
       IF DROP +LibraryDirName
          R@ OPEN-FILE-SHARED
       ELSE NIP NIP 0
       THEN
    ELSE NIP NIP 0
    THEN R> DROP
;