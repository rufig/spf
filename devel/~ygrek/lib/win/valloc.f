\ $Id$
\
\ Резервирование памяти с последующим выделением кусками по мере надобности
\ Память после каждого коммита идёт одним цельным куском не сдвигаясь
\ Минимальное выделение = размер страницы, наверное 4Кб, точнее - см. GetSystemInfo
\
\ Использование :
\   сначала RESERVE (память не выделяется)
\   потом COMMIT'ы по мере надобности
\   потом RELEASE
\
\  Обращение к невыделенному (пусть и зарезервированному) куску вызовет AV
\
\  Конечно же общее кол-во зарезервированной памяти не может превышать 2Гб, 
\  исчерпание адресного пространства
\
\  http://msdn2.microsoft.com/en-us/library/aa366887.aspx
\

REQUIRE #define ~af/lib/c/define.f

: #define
   >IN @ >R
   PARSE-NAME SFIND IF RDROP DROP 0 PARSE 2DROP EXIT ELSE 2DROP THEN
   R> >IN !
   #define ;

#define PAGE_NOACCESS          0x01     
#define PAGE_READONLY          0x02     
#define PAGE_READWRITE         0x04     
#define PAGE_WRITECOPY         0x08     
#define PAGE_EXECUTE           0x10     
#define PAGE_EXECUTE_READ      0x20     
#define PAGE_EXECUTE_READWRITE 0x40     
#define PAGE_EXECUTE_WRITECOPY 0x80     
#define PAGE_GUARD            0x100     
#define PAGE_NOCACHE          0x200     
#define PAGE_WRITECOMBINE     0x400     

#define MEM_COMMIT           0x1000     
#define MEM_RESERVE          0x2000     
#define MEM_DECOMMIT         0x4000     
#define MEM_RELEASE          0x8000     
#define MEM_FREE            0x10000     
#define MEM_PRIVATE         0x20000     
#define MEM_MAPPED          0x40000     
#define MEM_RESET           0x80000     
#define MEM_TOP_DOWN       0x100000     
#define MEM_4MB_PAGES    0x80000000

REQUIRE [IF] lib/include/tools.f

[UNDEFINED] VirtualAlloc [IF]
WINAPI: VirtualAlloc KERNEL32.DLL
[THEN]
[UNDEFINED] VirtualFree [IF]
WINAPI: VirtualFree KERNEL32.DLL
[THEN]

\ Зарезервировать кусок памяти размером u байт
\ Память при этом ещё не выделяется, но становится недоступной для последующих ALLOCATE и RESERVE 
: MEM-RESERVE ( u -- addr ior )
   >R PAGE_NOACCESS MEM_RESERVE R> 0 VirtualAlloc DUP ERR ;

\ Выделить u байт начиная с адреса addr (который вернул RESERVE !)
\ Можно делать COMMIT поверх уже выделенных кусков
: MEM-COMMIT ( addr u -- ior )
   PAGE_EXECUTE_READWRITE MEM_COMMIT 2SWAP SWAP VirtualAlloc ERR ;

\ Освободить память и снять резервирование (addr - тот который вернул RESERVE)
: MEM-RELEASE ( addr -- ior )
   MEM_RELEASE 0 ROT VirtualFree ERR ;

\EOF

: MB 1024 * 1024 * ;

1000 MB RESERVE THROW ( addr )

DUP 10 MB COMMIT THROW
DUP 10 MB 1 FILL

DUP 20 MB COMMIT THROW
DUP 10 MB + 10 - 100 DUMP

( addr ) RELEASE THROW

       