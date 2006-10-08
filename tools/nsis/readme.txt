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
* markdown
* GNU make <http://mingw.org/download.shtml> <http://www.gnu.org/software/make/>

## Что такое markdown?

Markdown это простая разметка(подобно Wiki) текстовых файлов для конвертации в
HTML. Этот файл в частности набран с разметкой markdown. Для конвертации
используются специальные скрипты - оригинальный написан на Перле, есть также
реализации на Python, Lua, PHP etc. Требования к выбранному markdown -
запускаться из коммандной строки в виде
        markdown input.md
Выдавая html разметку (без заголовков) на stdout. Например у меня это .bat файл
в PATH со следующим содержимым
        python D:\WORK\markdown\markdown-1-5.py %*

Официальный сайт - <http://daringfireball.net/projects/markdown>
Ссылки на альтернативные реализации - <http://en.wikipedia.org/wiki/Markdown>

## Что делать:

1. Скопировать jpf375c.exe в корневой каталог рабочей копии.
2. Перейти в каталог tools/nsis.
3. Проверить (отредактировать) параметры в Makefile
4. Запустить make

Всё.
