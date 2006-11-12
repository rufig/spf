( Нам необходимо решить задачу передачи сообщений windows объектам Hype.

* Thunk это короткая подпрограмма-заглушка - переходник.
* Thunk нам понадобится для передачи Windows сообщений экземплярам Hype2.
* Thunk это исполнимый код который строится динамически в динамической памяти
* Каждому экземпляру будет соответствовать один thunk.
* Вместо wnd proc windows будет передавать управление thunk'у

Порядок выполнения при передаче Windows сообщения wnd proc:

Windows -> thunk -> hype object instance

алгоритм thunk:

1.  Создать стек форта и переместить параметры wndproc на стек форта
2.  Найти и вызвать форт слово
3.  Корректно уйти в Windows


thunk не может быть статическим, потому что на каждый экземпляр необходим
свой thunk. )


USER DynP

: DHERE DynP @ ;
: DALLOT DynP +! ;

: CompileBranch ( addr-call code -- )
     DHERE SWAP
     OVER C!
     1+ TUCK CELL+ -
     SWAP !
     5 DALLOT
;

: CompileCall ( addr-call addr -- )
     0xE8 CompileBranch 
;

: CompileJmp ( addr-call addr -- )
     0xE9 CompileBranch
;

: CompileRet 
     0xC3 DHERE C! 
     1 DALLOT
;


\ компилируем DUP, mov eax, ##
: CompileLiteral ( n )
    0x89FC6D8D DHERE ! 4 DALLOT
    0x45 DHERE W! 2 DALLOT
    0xB8 DHERE C! 1 DALLOT
    DHERE ! CELL DALLOT
;

: LIT+ 
    11 +
;

: CALL+ 5 + ;

\ Чтобы не создавать каждый раз при входе в wndproc хип
 \ А также чтобы долгоживущие объекты можно было создавать в обработчике
  \ сообщений Windows будем в обработчиках использовать хип потока где объект
   \ создавался


CLASS CWinBaseClass

\ Always the first field
  CELL PROPERTY threadUserData

;CLASS

WINAPI: HeapValidate     KERNEL32.DLL

: SendFromThunk ( lpar wpar msg hwnd obj n )
\ We can't fetch threadUserData without TlsIndex set, so lets apply a small hack
     OVER CELL+ @ ( threadUserData@ hack! ) TlsIndex!

     <SET-EXC-HANDLER>

     S0 @ >R
     SP@  + CELL+ S0 !

     ^ message

     R> S0 !
;

: ObjExtern ( xt1 n obj -- xt2 )
     DHERE
     SWAP CompileLiteral \ obj
     SWAP CompileLiteral  \ n
     SWAP CompileCall
     CompileRet
;


\ If HEAP_CREATE_ENABLE_EXECUTE is not specified and an application 
 \ attempts to run code from a protected page, the application receives 
  \ an exception

VARIABLE WFL-THUNK-HEAP

: INIT-WFL
  \ create executable heap for thunks
  0 4096 0x00040000 ( HEAP_CREATE_ENABLE_EXECUTE)
  HeapCreate WFL-THUNK-HEAP !
  InitCommonControls
;

..: AT-PROCESS-STARTING INIT-WFL ;..
INIT-WFL

: AllocExec ( n -- a-addr ior )
    CELL+ 0 WFL-THUNK-HEAP @ HeapAlloc
    DUP IF R@ OVER ! CELL+ 0 ELSE -300 THEN
;

: FreeExec ( a-addr -- ior )
    CELL- 0 WFL-THUNK-HEAP @ HeapFree ERR
;

WINAPI: FlushInstructionCache KERNEL32.DLL

: DynamicObjectWndProc ( obj -- xt-addr start-addr )
     64 AllocExec THROW DUP DynP ! >R
     ['] SendFromThunk SWAP
     4 CELLS
     CELL+ ( obj parameter )
     SWAP ObjExtern ( xt2 )
     DHERE SWAP
     ['] _WNDPROC-CODE CompileCall
     DHERE ! CELL DALLOT
     R>

     DUP 64 SWAP
     GetCurrentProcess FlushInstructionCache -WIN-THROW
;
