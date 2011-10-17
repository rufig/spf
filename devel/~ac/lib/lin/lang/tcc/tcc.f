\ LIBTCC - Си-компилятор TinyCC в виде DLL-библиотеки размером около 100Кб 
\ (как Форт :), можно использовать из Форта.

\ http://bellard.org/tcc/tcc-doc.html#SEC22

WARNING @ WARNING 0!
REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f
WARNING !

ALSO SO NEW: libtcc.dll
\ ALSO SO NEW: libtcc.so

0 CONSTANT TCC_OUTPUT_MEMORY   \ output will be ran in memory (no output file) (default)
1 CONSTANT TCC_OUTPUT_EXE      \ executable file
2 CONSTANT TCC_OUTPUT_DLL      \ dynamic library
3 CONSTANT TCC_OUTPUT_OBJ      \ object file

:NONAME
  2DUP +
  ." FORTH code does hard work here :)" CR
;
2 CELLS CALLBACK: add

: TEST { addr u \ s f -- }
  0 tcc_new -> s
  s 0= IF ." Could not create tcc state." CR EXIT THEN
  TCC_OUTPUT_MEMORY s 2 tcc_set_output_type DROP
  addr s 2 tcc_compile_string IF ." Compile error." CR EXIT THEN

  \ это вместо #include <stdio.h>, возьмем printf из msvcrt
  S" msvcrt.dll" DLOPEN S" printf" ROT DLSYM S" printf" DROP s 3 tcc_add_symbol DROP

  \ подключим Форт-функцию внутрь Си-программы
  ['] add S" add" DROP s 3 tcc_add_symbol DROP

  \ здесь собственно привязка внешних символов
  s 1 tcc_relocate IF ." Relocate error." CR EXIT THEN

  S" foo" DROP ^ f s 3 tcc_get_symbol IF ." Get symbol error." CR EXIT THEN

  33 f API-CALL . DROP
;

: <__  S" {" ;

" int fib(int n)
{<__}
    if (n <= 2)
        return 1;
    else
        return fib(n-1) + fib(n-2);
}

int foo(int n)
{<__}
    printf({''}Hello World!\n{''});
    printf({''}fib(%d) = %d\n{''}, n, fib(n));
    printf({''}add(%d, %d) = %d\n{''}, n, 2 * n, add(n, 2 * n));
    return 0;
}"
   STR@ TEST
