Инструкция по сборке дистрибутива SPF
=====================================

Последнее обновление: $Date$

## Что надо:

* свежую чистую рабочую копию CVS репозитория. Без лишних файлов.
* jpf375c.exe
* spf4_notitle который не выводит стандартного заголовка в stdout. Например так
        spf4.exe ' NOOP MAINX ! S" spf4_notitle.exe" SAVE BYE
* NSIS <http://nsis.sourceforge.net>
* upx (не обязательно) <http://upx.sourceforge.net>
* GNU make <http://mingw.org/download.shtml> <http://www.gnu.org/software/make/>
* WinRAR <http://www.rarlabs.com>
* perl

## Для чего нужен perl?

Для того чтобы конвертнуть доку из markdown в html.
Markdown это простая разметка(подобно Wiki) текстовых файлов.
Этот файл в частности набран с разметкой markdown. Для конвертации
используется perl-скрипт.

Официальный сайт markdown - <http://daringfireball.net/projects/markdown>

## Что делать:

1. Скопировать jpf375c.exe в корневой каталог рабочей копии.
2. Скопировать html и сопутствующие файлы с http://www.forth.org.ru/~yz
   (например wget'ом) и положить в devel/~yz
3. Перейти в каталог tools/nsis.
4. Проверить (отредактировать) параметры в Makefile, не забыть увеличить spf_ver_minor
5. Дать команду make
6. Изменённый Makefile закоммитить на CVS

Всё.
