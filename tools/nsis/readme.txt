Инструкция по сборке дистрибутива SPF
=====================================

Последнее обновление: $Date$

## Что надо:

* свежую чистую рабочую копию CVS репозитория. Без лишних файлов.
* jpf375c.exe
* GNU make <http://mingw.org/download.shtml> <http://www.gnu.org/software/make/>
* WinRAR <http://www.rarlabs.com>

Для сборки полного дистра также :

* NSIS <http://nsis.sourceforge.net>
* upx (не обязательно) <http://upx.sourceforge.net>
* perl

## Для чего нужен perl?

Для того чтобы конвертнуть доку из markdown в html.
Markdown это простая разметка(подобно Wiki) текстовых файлов.
Этот файл в частности набран в разметке markdown. Для конвертации
используется perl-скрипт.

Официальный сайт markdown - <http://daringfireball.net/projects/markdown>

## Для сборки снапшота devel

1. Скопировать jpf375c.exe в корневой каталог рабочей копии.
2. В каталоге src выполнить compile.bat
3. Перейти в каталог tools/nsis.
4. Проверить(отредактировать) пути к makensis и winrar в Makefile
5. Дать команду make devel-snap

Всё.

## Для сборки инсталлятора

1. Скопировать jpf375c.exe в корневой каталог рабочей копии.
2. Скопировать содержимое spf4root в корневой каталог рабочей копии.
3. Скопировать html и сопутствующие файлы с http://www.forth.org.ru/~yz
   (например wget'ом) и положить в devel/~yz
4. Увеличить (если требуется) SPF-KERNEL-VERSION в 
   src/spf.f
   src/win/res/spf.manifest
   src/win/res/spf.rc
   и удалить src/VERSION.SPF если есть (не должно быть!)
5. В каталоге src выполнить compile.bat
6. Перейти в каталог tools/nsis.
7. Проверить(отредактировать) пути к makensis и winrar в Makefile
8. Дать команду make
9. Изменённые файлы в src закоммитить на CVS

Всё.
