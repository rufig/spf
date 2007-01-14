$Id$

Докуменатция к SPF devel
========================

Предлагаю размещать в docs/code, при этом группировать не по авторам, а по
тематике библиотек. Возможно стоит отображать это группирвоание структурой каталогов.
Возможно docbook файлы стоит складывать в подкаталог в tools чтобы они не
попадали в дистр, а только уже сгенерированная документация.

Что надо
========

GNU make <http://mingw.org/download.shtml> <http://www.gnu.org/software/make/>
libxml2, iconv, libxslt <http://www.zlatkovic.com/pub/libxml/>
docbook-xsl <http://sourceforge.net/project/showfiles.php?group_id=21935&package_id=16608>
docbook-xml <http://www.oasis-open.org/docbook/xml/4.5/docbook-xml-4.5.zip>
            или <http://www.oasis-open.org/docbook/xml/4.4/docbook-xml-4.4.zip>

xsltproc make и spf должны запускаться по имени (без указания пути).

Процесс
=======

Предположим создаём документацию для ~pinka/lib/hash-table.f

Цепочка преобразований выглядит так :

1. исходный код на форте с помощью xmlhelp.f перегоняется в xml
     spf xmlhelp.f S" hash-table.xml" START-XMLHELP S" ~pinka/lib/hash-table.f" INCLUDED FINISH-XMLHELP BYE

2. Полученный xml с помощью xsltproc.exe и xmlhelp2docbook.xsl перегоняется в docbook
     xsltproc xmlhelp2docbook.xsl hash-table.xml > hash-table.docbook

2a. Добавляем description, написанный руками (берётся из файла hash-table.more, если его нет - нормально)
     spf describe.f S" hash-table.docbook" DESCRIBE BYE

3. И окончательно с помощью docbook-xsl скриптов получаем html
     make hash-table.html

В каталоге лежат батники упрощающие этот процесс.

Из большинства исходников автоматическим образом документации получается очень
мало, поэтому есть два варианта
- если вы автор данной либы - добавить в неё комментариев чтобы получить доку автоматом
- иначе полученный docbook использовать как шаблон и набивать текст руками

На CVS следует коммитить _только_ файлы docbook.

Каталоги XML
============

Для того чтобы иметь возможность ссылаться на файлы xsl, dtd не зависимо от
структуры каталогов на конкретной машине введено понятие XML каталогов. В
принципе и без этого будет работать если лень заморачиваться.
Но по-хорошему надо создать переменную окружения XML_CATALOG_FILES
И присвоить ей пути к файлу-каталогу docbook-xsl, схем DTD для
docbook, и к самодельному файлу для xsl, перечисляя через пробел
У меня эти пути -
file:///D:/WORK/docbook/docbook-xsl-1.71.1/catalog.xml
file:///D:/WORK/docbook/docbook-xml-4.4/catalog.xml
file:///D:/WORK/docbook/xslcatalog.xml

Последний файл я создавал сам, он выглядит так

<?xml version="1.0"?>
<!DOCTYPE catalog
   PUBLIC "-//OASIS/DTD Entity Resolution XML Catalog V1.0//EN"
   "http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd">

<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
    <uri
        name="html/docbook.xsl"
        uri="file:///D:/WORK/docbook/docbook-xsl-1.71.1/html/docbook.xsl"/>
    <uri
        name="htmlhelp/htmlhelp.xsl"
        uri="file:///D:/WORK/docbook/docbook-xsl-1.71.1/htmlhelp/htmlhelp.xsl"/>
</catalog>


Если будут проблемы - определить переменную XML_DEBUG_CATALOG для отладки
