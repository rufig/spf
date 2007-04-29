[SP-Forth](readme.ru.html): Дополнительные библиотеки
=====================================================

<title>SP-Forth: Дополнительные библиотеки</title>

<small>$Date$</small>

<!-- $Revision$ -->

*REQUIRE это слово подключающее либу, всё лишнее закомментировано, так что можно использовать этот список как форт код при поключении либ :)*

----

[[Русский](devel.ru.html)] [[Английский](devel.en.html)]

----

[[Сеть](#net)] [[Графика](#graph)] [[Архиваторы](#arc)] [[Связные списки](#list)] [[Записи](#record)] [[Структуры данных](#data)] [[Сортировка и поиск](#sort-n-search)] [[Techniques](#techniques)] [[Отладка](#debug)] [[Случайные числа](#random)] [[Расстановочные таблицы](#hash)] [[Хэш функции](#hash-func)] [[Константы времени компиляции](#compiletime-const)] [[Windows GUI](#WinGUI)] [[Windows COM](#WinCOM)] [[Службы(сервисы) Windows](#services)] [[Дата и время](#datetime)] [[Базы данных](#db)] [[Потоки](#threads)] [[Реестр и INI Windows](#ini-registry)] [[Строки](#str)] [[Файлы](#files)] [[XML](#xml)] [[OOP](#oop)] [[Словари](#vocs)] [[Память](#mem)] [[Разное](#misc)] 

----

<a id="net"/>
### \\ Сеть 
* REQUIRE CreateSocket <a href='../devel/~ac/lib/win/winsock/sockets.f'>~ac/lib/win/winsock/sockets.f</a> \\ базовая поддержка TCP/IP 
* REQUIRE SslInit <a href='../devel/~ac/lib/win/winsock/ssl.f'>~ac/lib/win/winsock/ssl.f</a> \\ базовая поддержка SSL/TLS 
* REQUIRE SslClientSocket <a href='../devel/~ac/lib/win/winsock/sockets_ssl.f'>~ac/lib/win/winsock/sockets_ssl.f</a> \\ SSL/TLS-сервер 
* REQUIRE SocketLine <a href='../devel/~ac/lib/win/winsock/socketline2.f'>~ac/lib/win/winsock/socketline2.f</a> \\ построчное буферизированное чтение сокетов 
* REQUIRE ReadFrom <a href='../devel/~ac/lib/win/winsock/sockname.f'>~ac/lib/win/winsock/sockname.f</a> \\ работа с UDP 
* REQUIRE fsockopen <a href='../devel/~ac/lib/win/winsock/psocket.f'>~ac/lib/win/winsock/psocket.f</a> \\ упрощенная работа с сокетами 
* REQUIRE ForEachIP <a href='../devel/~ac/lib/win/winsock/foreach_ip.f'>~ac/lib/win/winsock/foreach_ip.f</a> \\ выполнение заданного действия для каждого IP хоста 
* REQUIRE SendDnsQuery <a href='../devel/~ac/lib/win/winsock/dns_q.f'>~ac/lib/win/winsock/dns_q.f</a> \\ работа с DNS-серверами 
* REQUIRE PutFileTr <a href='../devel/~ac/lib/win/winsock/transmit.f'>~ac/lib/win/winsock/transmit.f</a> \\ поддержка высокопроизводительной передачи файлов в Windows 
* REQUIRE SnmpInit <a href='../devel/~ac/lib/win/snmp/snmp.f'>~ac/lib/win/snmp/snmp.f</a> \\ поддержка SNMP 
* REQUIRE GET-FILE-VIAPROXY <a href='../devel/~ac/lib/lin/curl/curl.f'>~ac/lib/lin/curl/curl.f</a> \\ cURL-wrapper - поддержка приема/передачи по HTTP/FTP/etc) 
* \\ ~nn/lib/net/ \\ HTTP, POP3, FTP, etc 

<a id="graph"/>
### \\ Графика 
* REQUIRE GLWindow <a href='../devel/~ygrek/lib/joopengl/GLWindow.f'>~ygrek/lib/joopengl/GLWindow.f</a> \\ <a href='http://wiki.forth.org.ru/OpenGL'>OpenGL</a> поверх joop 

<a id="arc"/>
### \\ Архиваторы
* REQUIRE gzip_write <a href='../devel/~ac/lib/win/arc/gzip/zlib.f'>~ac/lib/win/arc/gzip/zlib.f</a> \\ упаковка и распаковка GZip-последовательностей
* REQUIRE zip-pack <a href='../devel/~profit/lib/7zip-dll.f'>~profit/lib/7zip-dll.f</a> \\ упаковка и распаковка в zip/7zip архивы

<a id="list"/>
### \\ Структуры данных - список 
* REQUIRE ListNode <a href='../devel/~day/joop/lib/list.f'>~day/joop/lib/list.f</a> \\ двухсвязный список 
* REQUIRE AddNode <a href='../devel/~ac/lib/list/STR_LIST.f'>~ac/lib/list/STR_LIST.f</a> \\ односвязный список 
* REQUIRE LINK, <a href='../devel/~day/common/link.f'>~day/common/link.f</a> \\ статический список (компилится в кодофайл) 
* REQUIRE firstNode <a href='../devel/~day/lib/staticlist.f'>~day/lib/staticlist.f</a> \\ двухсвязный список, много слов 
* REQUIRE list+s <a href='../devel/~pinka/lib/list_ext.f'>~pinka/lib/list_ext.f</a> \\ односвязный список 
* REQUIRE cons <a href='../devel/~ygrek/lib/list/core.f'>~ygrek/lib/list/core.f</a> \\ список cons pair, базовые слова
* REQUIRE lst( <a href='../devel/~ygrek/lib/list/ext.f'>~ygrek/lib/list/ext.f</a> \\ задание списка в виде lst( 1 % 2 % 3 % )lst
* REQUIRE reduce-this <a href='../devel/~ygrek/lib/list/more.f'>~ygrek/lib/list/more.f</a> \\ дополнительные операции над списком - reduce, equal?, list-remove-dublicates
* REQUIRE write-list <a href='../devel/~ygrek/lib/list/write.f'>~ygrek/lib/list/write.f</a> \\ распечатка списка, включая сериализацию пригодную для последующего EVALUATE
* REQUIRE write-list <a href='../devel/~ygrek/lib/list/all.f'>~ygrek/lib/list/all.f</a> \\ вся либа для cons pair списков

<a id="record"/>
### \\ Структуры данных - запись 
* REQUIRE STRUCT: <a href='../lib/ext/struct.f'>lib/ext/struct.f</a> \\ простые структуры(записи) 
* REQUIRE f: <a href='../devel/~af/lib/struct.f'>~af/lib/struct.f</a> \\ Объявление структур, содержащих элементы-функции 
* REQUIRE f: <a href='../devel/~af/lib/struct-t.f'>~af/lib/struct-t.f</a> \\ Объявление структур, содержащих элементы-функции, во временном словаре 

<a id="data"/>
### \\ Структуры данных - другое 
* REQUIRE Stack <a href='../devel/~day/joop/lib/stack.f'>~day/joop/lib/stack.f</a> \\ стек 
* REQUIRE New-Queue <a href='../devel/~pinka/lib/queue_pr.f'>~pinka/lib/queue_pr.f</a> \\ очередь с приоритетами 
* REQUIRE x.mask <a href='../devel/~mlg/SrcLib/bitfield.f'>~mlg/SrcLib/bitfield.f</a> \\ Битовые структуры
* REQUIRE RATIO <a href='../devel/~pinka/lib/BigMath.f'>~pinka/lib/BigMath.f</a> \\ Рациональные дроби (большие числа)

<a id="sort-n-search"/>
### \\ Сортировка и поиск
* REQUIRE HeapSort <a href='../devel/~mlg/SrcLib/hsort.f'>~mlg/SrcLib/hsort.f</a>  \\ Пирамидальная сортировка
* REQUIRE quick_sort <a href='../devel/~pinka/samples/2003/common/qsort.f'>~pinka/samples/2003/common/qsort.f</a> \\ "Быстрая" сортировка
* REQUIRE binary-search <a href='../devel/~profit/lib/binary-search.f'>~profit/lib/binary-search.f</a> \\ Двоичный поиск

<a id="techniques"/>
### \\ Programming techniques 
* REQUIRE { <a href='../lib/ext/locals.f'>lib/ext/locals.f</a> \\ Локальные переменные 
* REQUIRE LAMBDA{ <a href='../devel/~pinka/lib/lambda.f'>~pinka/lib/lambda.f</a> \\ :NONAME но внутри компилируемого определения 
* REQUIRE (: <a href='../devel/~yz/lib/inline.f'>~yz/lib/inline.f</a> \\ аналог лямбда-конструкций 
* REQUIRE CONT <a href='../devel/~profit/lib/bac4th.f'>~profit/lib/bac4th.f</a> \\ бэктрекинг, описание в <a href='../devel/~mlg/index.html#bacforth'>~mlg/#bacforth</a> 

<a id="debug"/>
### \\ Средства отладки 
* REQUIRE HeapEnum <a href='../devel/~ac/lib/memory/heap_enum2.f'>~ac/lib/memory/heap_enum2.f</a> \\ перечисление выделенных кусков памяти на хипе 
* REQUIRE mem\_stub <a href='../devel/~day/lib/mem_sanity.f'>~day/lib/mem_sanity.f</a> \\ Проверка корректности удаления (с помощью заполнения шаблоном) 
* REQUIRE MemReport <a href='../devel/~day/lib/memreport.f'>~day/lib/memreport.f</a> \\ Отчёт об утечках с распечаткой стека (поддерживает многопоточность) 
* REQUIRE ACCERT( <a href='../lib/ext/debug/accert.f'>lib/ext/debug/accert.f</a> \\ Условная компиляция, удобно для проверок 
* REQUIRE TRACER <a href='../lib/ext/debug/tracer.f'>lib/ext/debug/tracer.f</a> \\ Подробное отслеживание выполнения 
* REQUIRE EXC-DUMP2 <a href='../devel/~pinka/spf/exc-dump.f'>~pinka/spf/exc-dump.f</a> \\ улучшенный дамп отчёта исключений
* REQUIRE TESTCASES <a href='../devel/~ygrek/lib/testcase.f'>~ygrek/lib/testcase.f</a> \\ TESTCASES by ~day
* REQUIRE /TEST <a href='../devel/~profit/lib/testing.f'>~profit/lib/testing.f</a> \\ маркировка тестов в коде основанная на INCLUDED-DEPTH (глубине включения)

<a id="random"/>
### \\ Случайные числа 
* REQUIRE RANDOM <a href='../lib/ext/rnd.f'>lib/ext/rnd.f</a> \\ линейно-конгруэнтный генератор 
* REQUIRE RANDOM <a href='../devel/~day/common/rnd.f'>~day/common/rnd.f</a> \\ линейно-конгруэнтный генератор 
* REQUIRE RANDOM <a href='../devel/~af/lib/random.f'>~af/lib/random.f</a> \\ линейно-конгруэнтный генератор 
* REQUIRE RANDOM <a href='../devel/~nn/lib/ran4.f'>~nn/lib/ran4.f</a> \\ RAN4 
* REQUIRE GENRAND <a href='../devel/~ygrek/lib/neilbawd/mersenne.f'>~ygrek/lib/neilbawd/mersenne.f</a> \\ Mersenne twister - быстрый и качественный генератор случайных чисел с очень большим периодом 

<a id="hash"/>
### \\ Хэш-таблицы 
* REQUIRE new-hash <a href='../devel/~pinka/lib/hash-table.f'>~pinka/lib/hash-table.f</a> 
* REQUIRE ListAllocate <a href='../devel/~af/lib/simple_hash.f'>~af/lib/simple_hash.f</a> 
* REQUIRE HASH-TABLE <a href='../devel/~yz/lib/hash.f'>~yz/lib/hash.f</a> 

( Сравнение быстродействия в <a href='../devel/~pinka/samples/2003/test-hash/'>~pinka/samples/2003/test-hash/</a>)

* REQUIRE HASH <a href='../devel/~day/common/hash.f'>~day/common/hash.f</a> \\ функция вычисления хэша 

<a id="hash-func"/>
### \\ Хэш-функции (криптографические) 
* REQUIRE MD5 <a href='../devel/~clf/md5.f'>~clf/md5.f</a> 
* REQUIRE MD5 <a href='../devel/~clf/md5-ts.f'>~clf/md5-ts.f</a> \\ thread safe 
* REQUIRE SHAbuffer <a href='../devel/~nn/lib/security/SHA256.f'>~nn/lib/security/SHA256.f</a> 
* REQUIRE MD5 <a href='../lib/alg/md5-jz.f'>lib/alg/md5-jz.f</a> 

<a id="compiletime-const"/>
### \\ Константы времени компиляции 
* REQUIRE LOAD-CONSTANTS <a href='../devel/~yz/lib/const.f'>~yz/lib/const.f</a> \\ подключение констант - слово W: ищет константу 
* REQUIRE ADD-CONST-VOC <a href='../devel/~day/wincons/wc.f'>~day/wincons/wc.f</a> \\ подключение констант - переопределяет NOTFOUND 
* REQUIRE BEGIN-CONST <a href='../devel/~day/wincons/compile.f'>~day/wincons/compile.f</a> \\ компилятор *.const файлов 
* \\ <a href='../devel/~day/wincons/h2f.f'>~day/wincons/h2f.f</a> \\ генератор констант Форта из сишных *.h файлов 
* \\ <a href='../devel/~yz/cons/'>~yz/cons/</a> \\ скомпилированные константы sql, commctrl, windows 
* \\ <a href='../devel/~ygrek/lib/data/'>~ygrek/lib/data/</a> \\ farplugin, opengl 

<a id="WinGUI"/>
### \\ Windows GUI 
* REQUIRE WINDOWS... <a href='../devel/~yz/lib/winlib.f'>~yz/lib/winlib.f</a> \\ WinLib - библиотека интерфейса Windows. Умеет растягивать формы и контролы в ней. Задание вида окна без указания точных координат, с помощью размещения в сетке - ноу-хау! Хорошая <a href='http://www.forth.org.ru/~yz/winlib.html'>документация</a>. 
* REQUIRE FrameWindow <a href='../devel/~day/joop/win/'>~day/joop/win/framewindow.f</a> \\ оконная библиотека поверх joop 
* \\ <a href='../devel/~ac/lib/win/window/'>~ac/lib/win/window/</a> \\ простая и небольшая реализация 

<a id="WinCOM"/>
### \\ Windows COM 
* REQUIRE ComInit <a href='../devel/~ac/lib/win/com/com.f'>~ac/lib/win/com/com.f</a> \\ базовая поддержка COM 
* REQUIRE Extends <a href='../devel/~ac/lib/win/com/com_server.f'>~ac/lib/win/com/com_server.f</a> \\ COM-сервер 

<a id="services"/>
### \\ Системные сервисы 
* REQUIRE CreateService <a href='../devel/~ac/lib/win/service/service.f'>~ac/lib/win/service/service.f</a> \\ сервисы в NT 
* REQUIRE InstallService95 <a href='../devel/~ac/lib/win/service/service95.f'>~ac/lib/win/service/service95.f</a> \\ "сервисы" в Win9x/ME 

<a id="datetime"/>
### \\ Дата и время 
* REQUIRE DateTime# <a href='../devel/~ac/lib/win/date/date-int.f'>~ac/lib/win/date/date-int.f</a> \\ дата/время в различных форматах 
* REQUIRE UNIXDATE <a href='../devel/~ac/lib/win/date/unixdate.f'>~ac/lib/win/date/unixdate.f</a> \\ поддержка Unixdate 
* REQUIRE FileDateTime# <a href='../devel/~ac/lib/win/file/filetime.f'>~ac/lib/win/file/filetime.f</a> \\ дата/время в файловой системе 
* REQUIRE parse-date? <a href='../devel/~ygrek/lib/spec/sdate.f'>~ygrek/lib/spec/sdate.f</a> \\ Разбор даты в виде S" Tue, 19 Dec 2006 19:55:16 +0300"
* REQUIRE parse-num-unixdate <a href='../devel/~ygrek/lib/spec/sdate2.f'>~ygrek/lib/spec/sdate2.f</a> \\ Разбор даты в виде S" 2007-01-27T17:40:36+03:00"
* REQUIRE DateTime>Num <a href='../devel/~ygrek/lib/spec/unixdate.f'>~ygrek/lib/spec/unixdate.f</a> \\ unix timestamp в дату и наоборот

<a id="db"/>
### \\ Базы данных 
* REQUIRE StartSQL <a href='../devel/~yz/lib/odbc.f'>~yz/lib/odbc.f</a> \\ работа с типизированными данными 
* REQUIRE StartSQL <a href='../devel/~ac/lib/win/odbc/'>~ac/lib/win/odbc/odbc.f</a> \\ ODBC, работа с данными из базы как со строками 
* REQUIRE ExecSQLTxt <a href='../devel/~pinka/lib/win/odbc/odbc-txt.f'>~pinka/lib/win/odbc/odbc-txt.f</a> \\ поддержка DELETE и UPDATE в случае использования Text File Driver 
* REQUIRE db3_open <a href='../devel/~ac/lib/lin/sql/sqlite3.f'>~ac/lib/lin/sql/sqlite3.f</a> \\ SQLite 
* REQUIRE MyQuery <a href='../devel/~day/lib/mysql.f'>~day/lib/mysql.f</a> \\ MySQL wrapper 

<a id="threads"/>
### \\ Процессы, потоки, права доступа etc
* \\ <a href='../devel/~ac/lib/win/process/'>~ac/lib/win/process/</a> 
* REQUIRE GetProcessACL <a href='../devel/~ac/lib/win/access/nt_access.f'>~ac/lib/win/access/nt_access.f</a> \\ права доступа 
* REQUIRE IsapiRunExtension <a href='../devel/~ac/lib/win/isapi/isapi.f'>~ac/lib/win/isapi/isapi.f</a> \\ поддержка ISAPI-совместимых расширений 
* REQUIRE CREATE-CP <a href='../devel/~ac/lib/win/thread/pool.f'>~ac/lib/win/thread/pool.f</a> \\ поддержка пула потоков в Win200x 
* REQUIRE CREATE-MUTEX <a href='../lib/win/mutex.f'>lib/win/mutex.f</a> \ Мутексы
* REQUIRE ENTER-CS <a href='../devel/~pinka/lib/multi/critical.f'>~pinka/lib/multi/critical.f</a> \ Critical sections
* REQUIRE WaitAll <a href='../devel/~pinka/lib/multi/synchr.f'>~pinka/lib/multi/synchr.f</a> \ Синхронизация потоков - "ожидание одного", "ожидание всех"

<a id="ini-registry"/>
### \\ Реестр и ini Windows 
* REQUIRE RG_CreateKey <a href='../devel/~ac/lib/win/registry2.f'>~ac/lib/win/registry2.f</a> 
* REQUIRE IniFile@ <a href='../devel/~ac/lib/win/ini.f'>~ac/lib/win/ini.f</a> 

<a id="str"/>
### \\ Строки 
* REQUIRE STR@ <a href='../devel/~ac/lib/str5.f'>~ac/lib/str5.f</a> \\ динамические строки 
* REQUIRE BNF <a href='../devel/~ac/lib/transl/BNF.f'>~ac/lib/transl/BNF.f</a> \\ основные типы данных BNF 
* REQUIRE CHECK-SET <a href='../devel/~day/common/sbnf.f'>~day/common/sbnf.f</a> \\ простой BNF парсер 
* REQUIRE WildCMP-U <a href='../devel/~pinka/lib/mask.f'>~pinka/lib/mask.f</a> \\ сравнение строки и маски с метасимволами * и ? 
* REQUIRE ULIKE <a href='../devel/~pinka/lib/like.f'>~pinka/lib/like.f</a> \\ сравнение строки и маски с метасимволами * и ? 
* REQUIRE re_start <a href='../devel/~nn/lib/re.f'>~nn/lib/re.f</a> \\ regexp'ы 
* REQUIRE PcreMatch <a href='../devel/~ac/lib/string/regexp.f'>~ac/lib/string/regexp.f</a> \\ PCRE wrapper 
* REQUIRE BregexpMatch <a href='../devel/~ac/lib/string/bregexp/bregexp.f'>~ac/lib/string/bregexp/bregexp.f</a> \\ bregexp.dll wrapper 
* REQUIRE debase64 <a href='../devel/~ac/lib/string/conv.f'>~ac/lib/string/conv.f</a> \\ base64, win-koi, urlencode и др. 
* REQUIRE UPPERCASE <a href='../devel/~ac/lib/string/uppercase.f'>~ac/lib/string/uppercase.f</a> \\ перевод в верхний регистр 
* REQUIRE COMPARE-U <a href='../devel/~ac/lib/string/compare-u.f'>~ac/lib/string/compare-u.f</a> \\ нечувствительное к регистру сравнение 
* REQUIRE GetParam <a href='../devel/~ac/lib/string/get_params.f'>~ac/lib/string/get_params.f</a> \\ разбор строки URL-параметров 
* REQUIRE SPLIT- <a href='../devel/~pinka/samples/2005/lib/split.f'>~pinka/samples/2005/lib/split.f</a> \\ разбиение строки по ключу, замена "на месте"
* REQUIRE replace-str- <a href='../devel/~pinka/samples/2005/lib/replace-str.f'>~pinka/samples/2005/lib/replace-str.f</a> \\ замена в строке
* REQUIRE FINE-HEAD <a href='../devel/~pinka/samples/2005/lib/split-white.f'>~pinka/samples/2005/lib/split-white.f</a> \\ удаление пробелов с краю строки
* REQUIRE TYPE>STR <a href='../devel/~ygrek/lib/typestr.f'>~ygrek/lib/typestr.f</a> \\ перенаправление всего TYPE вывода в строку

<a id="files"/>
### \\ Файлы 
* REQUIRE OPEN-FILE-SHARED-DELETE <a href='../devel/~ac/lib/win/file/share-delete.f'>~ac/lib/win/file/share-delete.f</a> \\ открытие файла с "мягким" совместным доступом 
* REQUIRE LAY-PATH <a href='../devel/~pinka/samples/2005/lib/lay-path.f'>~pinka/samples/2005/lib/lay-path.f</a> \\ создание каталогов пути 
* REQUIRE ATTACH <a href='../devel/~pinka/samples/2005/lib/append-file.f'>~pinka/samples/2005/lib/append-file.f</a> \\ безопасная запись в файл
* REQUIRE SPEAK-WITH <a href='../devel/~pinka/samples/2005/ext/tank.f'>~pinka/samples/2005/ext/tank.f</a> \\ управление выходным потокм, выполнение xt с перенаправлением вывода в файл 

<a id="xml"/>
### \\ XML
* REQUIRE XML\_Evaluate <a href='../devel/~ac/lib/lin/xml/expat.f'>~ac/lib/lin/xml/expat.f</a> \\ поддержка XML через libexpat
* REQUIRE XML\_READ\_DOC <a href='../devel/~ac/lib/lin/xml/xml.f'>~ac/lib/lin/xml/xml.f</a> \\ поддержка XML через LibXml2 
* REQUIRE XSLT <a href='../devel/~ac/lib/lin/xml/xslt.f'>~ac/lib/lin/xml/xslt.f</a> \\ поддержка XSLT через LibXslt 

<a id="oop"/>
### \\ ООП расширения 
* REQUIRE CLASS: <a href='../devel/~day/joop/oop.f'>~day/joop/oop.f</a> \\ just oop с кучей примеров 
* REQUIRE CLASS: <a href='../devel/~af/mc/microclass.f'>~af/mc/microclass.f</a> \\ microclass 
* REQUIRE CLASS: <a href='../devel/~day/mc/microclass.f'>~day/mc/microclass.f</a> \\ microclass 
* REQUIRE CLASS <a href='../devel/~day/hype3/hype3.f'>~day/hype3/hype3.f</a> \\ Hype 3, включая <a href='../devel/~day/hype3/reference.pdf'>документацию</a>

<a id="vocs"/>
### \\ Словари
* REQUIRE InVoc{ <a href='../devel/~ac/lib/transl/vocab.f'>~ac/lib/transl/vocab.f</a> \\ сокращение записи манипуляции словарями (аналог MODULE:) 
* REQUIRE ForEach <a href='../devel/~ac/lib/ns/iterators.f'>~ac/lib/ns/iterators.f</a> \\ итераторы в контекстных словарях 
* REQUIRE ForEach-Word <a href='../devel/~pinka/lib/Words.f'>~pinka/lib/Words.f</a> \\ ForEach-Word 
* REQUIRE QuickSWL-Support <a href='../devel/~pinka/spf/quick-swl2.f'>~pinka/spf/quick-swl2.f</a> \\ Быстрый поиск по словарю (за счёт хэширования) 
* REQUIRE DLOPEN <a href='../devel/~ac/lib/ns/dlopen.f'>~ac/lib/ns/dlopen.f</a> \\ совместимый с Unix-версией SPF способ загрузки WindowsDLL/UnixSO 
* \\ <a href='../devel/~ac/lib/ns/'>~ac/lib/ns/</a> \\ отображение внешних древовидных структур на форт-словарь 

<a id="mem"/>
### \\ Память 
* REQUIRE STACK\_MEM <a href='../devel/~ac/lib/memory/mem_stack.f'>~ac/lib/memory/mem_stack.f</a> \\ "Стековое" управление памятью 
* REQUIRE LowMemory? <a href='../devel/~ac/lib/memory/low_memory.f'>~ac/lib/memory/low_memory.f</a> \\ Отслеживание чрезмерного потребления памяти 
* REQUIRE PAllocSupport <a href='../devel/~af/lib/pallocate.f'>~af/lib/pallocate.f</a> \\ Выделение памяти в адресном пространстве процесса (общее для потоков) 
* REQUIRE LOCALLOC <a href='../devel/~mak/lalloc.f'>~mak/lalloc.f</a> \\ выделение локального массива (на стеке возвратов) 
* REQUIRE ALLOCATE2 <a href='../devel/~pinka/spf/mem2.f'>~pinka/spf/mem2.f</a> \\ переключение работы с хипом потока и глобальным 
* REQUIRE LoadDelphiMM <a href='../devel/~ss/lib/borlndmm.f'>~ss/lib/borlndmm.f</a> \\ подключение менеджера памяти от Borland 
* REQUIRE INIT-TASK-VALUES <a href='../devel/~ss/lib/task-values.f'>~ss/lib/task-values.f</a> \\ Глобальные переменные потока 
* REQUIRE PROTECT-RETURN-STACK <a href='../devel/~ss/ext/stack-quard.f'>~ss/ext/stack-quard.f</a> \\ Защита стека возвратов от затирания стеком данных 
* REQUIRE GMEM <a href='../devel/~yz/lib/gmem.f'>~yz/lib/gmem.f</a> \\ Глобальная память разделяемая между потоками

<a id="misc"/>
### \\ Разное
* REQUIRE CONST <a href='../devel/~micro/lib/const/const.f'>~micro/lib/const/const.f</a> \\ перечисление констант 
* REQUIRE ENUM <a href='../devel/~ygrek/lib/enum.f'>~ygrek/lib/enum.f</a> \\ перечисление подобных слов 
* REQUIRE enqueueNOTFOUND <a href='../devel/~pinka/samples/2006/core/trans/nf-ext.f'>~pinka/samples/2006/core/trans/nf-ext.f</a> \\ добавление в список трансляторов (NOTFOUND)
