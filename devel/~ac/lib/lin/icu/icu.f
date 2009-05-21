\ Еще одна библиотека для i18n, из IBM, см. http://site.icu-project.org/
\ Требуются icu*.dll или .so, см. http://icu-project.org/download/4.2.html#ICU4C
\ Очень много полезных возможностей (конвертация, поиск, сравнение, regexp,
\ сравнение и форматирование дат, idn, и т.п.), но колоссальный размер dll...
\ Для функций конвертации - как минимум icuuc42.dll и icudt42.dll (17Мб в сумме!)

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f

ALSO SO NEW: icuuc42.dll
ALSO SO NEW: libicuuc.so.42

\ API конвертации http://icu-project.org/apiref/icu4c/ucnv_8h.html

: ICCONV { a u cpfa cpfu cpta cptu \ ior oa ou -- oa ou }
  u 4 * CELL+ DUP -> ou ALLOCATE THROW -> oa

  ^ ior u a ou oa cpfa cpta 7 ucnv_convert
  oa SWAP
;
PREVIOUS
PREVIOUS

\EOF
\ тест
S" тестtest" S" cp1251" S" UTF-8" ICCONV
S" UTF-8" S" cp1251" ICCONV ANSI>OEM TYPE CR

\ проверка совместимости с ICONV
REQUIRE ICONV ~ac/lib/lin/iconv/iconv.f 
S" тестtest" S" cp1251" S" UTF-8" ICCONV
S" UTF-8" S" cp1251" ICONV ANSI>OEM TYPE CR
