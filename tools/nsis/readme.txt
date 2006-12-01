Инструкция по сборке дистрибутива SPF
=====================================

Последнее обновление: $Date$

## Что надо:

* свежую рабочую копию CVS репозитория. Без лишних файлов.
* jpf375c.exe
* spf4_notitle который не выводит стандартного заголовка в stdout. Например так
        spf4.exe ' NOOP MAINX ! S" spf4_notitle.exe" SAVE BYE
* NSIS <http://nsis.sourceforge.net>
* upx (не обязательно) <http://upx.sourceforge.net>
* python <http://www.python.org>
* GNU make <http://mingw.org/download.shtml> <http://www.gnu.org/software/make/>
* WinRAR <http://www.rarlabs.com>

## Для чего нужен python?

Для точго чтобы конвертнуть доку из markdown в html.
Markdown это простая разметка(подобно Wiki) текстовых файлов.
Этот файл в частности набран с разметкой markdown. Для конвертации
используются специальные скрипты - оригинальный написан на Перле, есть также
реализации на Python, Lua, PHP etc. В Makefile используется python'ий скрипт.
Так уж исторически сложилось.

Официальный сайт markdown - <http://daringfireball.net/projects/markdown>
Ссылки на альтернативные реализации - <http://en.wikipedia.org/wiki/Markdown>

## Что делать:

1. Скопировать jpf375c.exe в корневой каталог рабочей копии.
2. Скопировать html и сопутствующие файлы с http://www.forth.org.ru/~yz
   (например wget'ом) и положить в devel/~yz
3. Файл src/version.spf отредактировать из 4XX000 в 4XX999
3. Перейти в каталог tools/nsis.
4. Проверить (отредактировать) параметры в Makefile, не забыть увеличить spf_ver_minor
5. Дать команду make
6. Изменённый version.spf (должен содержать 4YY000, где YY=XX+1) и Makefile закоммитить на CVS
7. Выложить полученные RAR и EXE дистрибутивы на SF.net

Всё.
