<a id="start"/>

SPF peculiarities
=================

<title>SPF peculiarities</title>

<i>A short introduction, for those already familiar with some
Forth-system and ANS'94 standard.</i>

<small>Last update: $Date$</small>

<!-- Translated from intro.md (rev. 1.13) -->

----

##Contents

* [Installed SPF4. And whats next?](#devel)
* [Optimizer](#opt)
* [ANS support](#ans)
* [How to run and include forth code?](#include)
* [REQUIRE](#require)
* [Modules](#module)
* [Case sensitivity](#case)
* [Inputing numbers](#numbers)
* [Structures, records](#struct)
* [Where is FORGET?](#forget)
* [How to clear the stack with one word?](#cls)
* [Debugging facilities](#debug)
* [Comments](#comments)
* [Strings](#string)
* [Creating executable modules](#save)
* [Local and temporary variables](#locals)
* [Using extrnal DLLs](#dll)
* [NOTFOUND](#notfound)
* [Scattered colons](#scatcoln)
* [Multitasking](#task)
* [Vocabularies](#voc)

----
<a id="devel"/>
###[Installed SPF4. And whats next?][start]

The first and the most important thing - placement of your working files. In
the SPF directory there is a subdir DEVEL for the developers' code (including
yours). Create a subdir there, for example ~john. Now you can refer to your files
in short form, `~john\prog\myprog.f`. Thus, the mutual access to contributed
code is simplified. The general adopted convention is to place libraries in
the subdirectory named lib, and example programs in prog.

The devel directory contains the contributed code of other SP-Forth'ers, the
short(very short) list is available online:
<http://wiki.forth.org.ru/SPF_DEVEL>, or you can scan the directory yourself.


----
<a id="opt"/>
###[Optimizer][start]

SPF uses the subroutine threaded code, i.e. the compiled code looks like the
chains of `CALL <word-cfa-address>`. This code can be ran directly, but by
default it is processed with the optimizer to gain a speedup at runtime. It
performs inlining and peephole-optimization. More on ForthWiki (in russian):
"[Optimizing compiler](http://wiki.forth.org.ru/optimizer)".

**NB**: If suddenly your program fails to compile or behaves strangely, try to
temporarily turn off the optimizer using `DIS-OPT` (turn on with `SET-OPT`),
maybe (unlikely!) it is a bug in the optimizer. If so - cut the piece of code
where it occurs and send to the author.

You can observer the result of the word compilation as a native code with a
disassembler:

	REQUIRE SEE lib/ext/disasm.f
	SEE word-in-interest

or get the line-by-line listing

	REQUIRE INCLUDED_L ~mak/listing2.f
	S" file, with the code in interest"  INCLUDED_L
	\ the listing will be places in the file near to the file included


----
<a id="ans"/>
###[ANS support][start]

Maximum ANS conformity is achieved by including `lib/include/ansi.f`.
Additional words are defined, some of them dummies, etc. Also, a tricky
behaviour of the FILE words is corrected - `OPEN-FILE`, `CREATE-FILE` and
other such words implicitly treat the input string as zero-ended (ignoring the
length parameter), though according to the standard it is a string buffer with
the counter on the stack.

----
<a id="include"/>
###[How to run and include forth code?][start]

Running the file from the command line is fairly simple, just provide it's path as
a parameter for SPF, 

	spf.exe ~john/prog/myprog.f
Note, that include path can be either absolute or relative to the
[devel](#devel) directory. 

In SPF console (interpretation mode) just type in the name of the file:

	~john/prog/myprog.f
For the compatibility reasons, it is better to include it in a standard way:

	S" ~vasya/prog/myprog.f" INCLUDED

But the recommended approach is to use `REQUIRE` word.


----
<a id="require"/>
###[REQUIRE][start]

SPF has a non-standard word `REQUIRE ("word" "file" -- )`, where `word` should
be the one defined in `file`. If this word is already present in the 
system, `REQUIRE` will consider the library already loaded. In this way, the
duplicated loading of libraries is avoided.
For example:

	REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f
	REQUIRE ForEach-Word ~pinka/lib/words.f
	REQUIRE ENUM ~nn/lib/enum.f



----
<a id="module"/>
###[Modules][start]

В SPF есть модули, которые позволяют скрывать некоторые внутренние слова
библиотек выводя наружу только слова для взаимодействия.

	MODULE: vasya-lib
	\ внутренние слова
	EXPORT
	\ слова взаимодействия, видные снаружи, компилируются во внешний словарь.
	DEFINITIONS
	\ опять внутренние слова
	EXPORT
	\ ну вы поняли :)
	;MODULE
Код `MODULE: vasya-lib` можно писать много раз - последующие вызовы будут
докомпилировать слова в тот же модуль. На самом деле слово определённое через
`MODULE:` это обычный [словарь](#voc).


----
<a id="case"/>
###[Case sensitivity][start]

SPF регистрозависим, то есть в этом режиме для него слова `CHAR` , `Char` и `char` -
три разных слова. Этот режим можно выключить подключением файла
`lib/ext/caseins.f`.



----
<a id="numbers"/>
###[Inputing numbers][start]

SPF позволяет вводить шестнадцатиричные числа вне зависимости от текущей системы
счисления (значения переменной `BASE`) так:
 
	0x7FFFFFFF
Вещественные числа можно вводить в формате `[+|-][dddd][.][dddd]e[+|-][dddd]`
подключив либу `lib\include\float2.f`.


----
<a id="struct"/>
###[Structures, records][start]

Структуры в SPF создаются через слово `--` (оно же `FIELD`). Пример:

	0
	CHAR -- flag
	CELL -- field
	10 CELLS -- arr
	CONSTANT struct

Слова `flag`, `field` и `arr` будут прибавлять к адресу своё смещение 
относительно начала структуры. А в `struct` записан общий размер
всей структуры. То есть, можно:

	struct ALLOCATE THROW TO s \ взяли память из кучи под один экземпляр struct
	1 s flag С!  10 s field ! \ записали значения в поля структуры
	s arr 10 CELLS DUMP \ вывели содержимое массива в структуре
	s FREE THROW \ сняли экземпляр struct

Структуры можно наследовать:

	0
	CELL -- x
	CELL -- y
	CONSTANT point \ у point два поля
	
	point
	CELL -- radius
	CONSTANT circle \ у circle три поля: x, y, radius
	
	point
	CELL -- w
	CELL -- h
	CONSTANT rect \ у rect четыре поля: x, y, w, h

----
<a id="forget"/>
###[Where is FORGET?][start]

`FORGET` нет. Но есть `MARKER ( "name" -- )` (в `lib\include\core-ext.f` или в `~clf/marker.f`).



----
<a id="cls"/>
###[How to clear the stack with one word?][start]

Наберите `lalala`. Или `bububu`. Или `лялятополя`. Возникнет ошибка и стек сбросится.
На самом деле стек сбросит слово `ABORT`, которое будет вызвано если интерпретатор
не найдёт введённое слово. Ну а на самом-самом деле - это делается так: `S0 @ SP!`

__В FAQ__


----
<a id="debug"/>
###[Debugging facilities][start]

Слово `STARTLOG` включает запись всего консольного вывода в лог-файл
`spf.log` в текущей папке. `ENDLOG` соответственно выключает такое поведение.


__Подробнее!__


----
<a id="comments"/>
###[Comments][start]

В SPF есть комментарий до конца строки ` \ `. Есть и обычные, скобочные, комментарии,
которые к тому же ещё и многострочные. То есть:

	\ комментарий до конца строки
	( комментарий
	и даже в несколько строк )
Есть слово `\EOF` которое делает комментарием всё идущее после него в файле. Таким
образом удобно отделять примеры использования библиотеки от самой библиотеки.

	word1 word2
	\EOF
	комментарий до конца файла



----
<a id="string"/>
###[Strings][start]

В SPF в основном используются строки со счётчиком на стеке - т.е. два значения
`(addr u)`. Для записи строковых литералов (строковых констант) используется
слово `S"`, которое в зависимости от текущего режима выполняет несколько разные
действия:

* В режиме интерпретации строка находится во временном текстовом буфере разбора (`TIB`),
и соответственно, работает только в пределах одной строки.

* В режиме компиляции строка вкомпилируется непосредственно в шитый код определяемого слова.

Для удобства работы с WinAPI в конец строк добавляется дополнительный, завершающий
нулевой байт.

Слово `S"` создаёт т. н. статическую строку, она находится или в буфере, или в словарной
структуре SPF. Для работы со динамическими строками, которые резервируются в "куче" и снимаются
оттуда есть библиотека `~ac\lib\str4.f`. Пример её использования:

	REQUIRE STR@ ~ac/lib/str4.f
	"" VALUE r \ создаём пустую строку
	" мама, мама, " VALUE m
	" что я буду делать?" VALUE w
	m r S+  w r S+
	r STYPE
	> мама, мама, что я буду делать?

Кроме конкатенации строк можно использовать и подстановку (в том числе и других строк):

	" 2+2={2 2 +}" STYPE
	> 2+2=4

Исчерпывающее описание и более подробные примеры см. в самой библиотеке.

Надо также заметить что в SPF поддерживается префикс слов `S-` и окончание `-ED`.

`S-` означает что слово работает со строками со счётчиком (например есть
`SFIND` и есть стандартный `FIND`, есть `SLITERAL` и `LITERAL`).

`-ED` есть в словах `CREATED`, `INCLUDED`, `REQUIRED`, `ALIGNED`. Он обозначает что это
слово, в отличии от своего "корня", будет ожидать параметров со стека, а не брать его из
входного потока (или из глобальной переменной, как в случае с `ALIGN` и `ALIGNED`).

Например, стандартный `CREATE` берёт свой параметр из входного потока, тогда как `CREATED`
явно забирает параметр со стека данных в виде начала строки и её длины.

----
<a id="save"/>
###[Producing executable modules][start]

Слово `SAVE ( a u -- )` сохраняет всю форт-систему, включая все словарные
структуры (кроме временных!) в исполняемый модуль путь к которому задаётся
строкой `a u`. Точка входа определяется value-переменной `<MAIN>` для
консольного режима и переменной `MAINX` для GUI. Режим определяется
value-переменными `?CONSOLE` и `?GUI`. `SPF-INIT?` контроллирует интерпретацию
коммандной строки и подключение spf4.ini:

	0 TO SPF-INIT?
	' ANSI>OEM TO ANSI><OEM
	TRUE TO ?GUI
	' NOOP TO <MAIN>
	' run MAINX !
	S" gui.exe" SAVE  

или

    ' run TO <MAIN>
	S" console.exe" SAVE


----
<a id="locals"/>
###[Local and temporary variables][start]

Не входят в ядро, но подключаются:

	REQUIRE { lib/ext/locals.f
	
	\ пример простого использования
	: test { a b | c d }  \ a b инициализируюся со стека, c и d нулями
	  a -> c
	  b TO d
	  c . d . ;
	1 2 test
	>1 2
	> Ok
Подробное описание и примеры использования смотрите в самой библиотеке.



----
<a id="dll"/>
###[Using external DLLs][start]

Пример:

	WINAPI: SevenZip 7-zip32.dll
Если нужно подключить все функции из dll-файла то можно использовать
либо:

	REQUIRE UseDLL ~nn/lib/usedll.f
	UseDLL "имя_библиотеки"

или:

	REQUIRE DLL ~ac/lib/ns/dll-xt.f
	DLL NEW: "имя_библиотеки" 

----
<a id="notfound"/>
###[NOTFOUND][start]

Если во время цикла `INTERPRET` не будет
найдено очередное слово из входного потока - в текущем словаре ищется и
вызывается слово `NOTFOUND ( a u -- )`. Если `NOTFOUND` не обрабатывает данное
слово - он должен вывалиться с исключением. Иначе считается, что слово
воспринято и трансляция продолжается. По умолчанию через `NOTFOUND` реализовано
распознавание чисел, и доступ к вложенным словарям в виде:

	vocname1:: wordname

Правило хорошего тона - при переопределении `NOTFOUND` сначала вызвать его
старый вариант, и если он не отвалится по исключению - выполнять свои
действия. Пример:

	 : MY? ( a u -- ? ) S" !!" SEARCH >R 2DROP R> ;
	 : DO-MY ( a u -- ) ." My NOTFOUND: " TYPE CR ;

	 : NOTFOUND ( a u -- )
	   2DUP 2>R ['] NOTFOUND CATCH 
	   IF
	     2DROP
	     2R@ MY? IF 2R@ DO-MY ELSE -2003 THROW THEN
	   THEN
	   RDROP RDROP
	   ;
Или так:

	 : NOTFOUND ( a u -- )
	   2DUP MY? IF DO-MY EXIT THEN
	   ( a u )
	   NOTFOUND
	   ;


----
<a id="scatcoln"/>
###[Scattered colons][start]

Расширяемые слова (описание техники: "[Scattering a Colon Definition][scatter]", на английском языке). 
Позволяют уже после определения слова добавлять в него новые действия.

	: INIT ... do1 ; 
	\ если вызвать INIT здесь то выполнится do1
	..: INIT do2 ;.. 
	\ если здесь - то do1 и do2 именно в таком порядке
	..: INIT do3 ;.. 
	\ и так далее

Подобного эффекта можно добиться и с помощью векторов, но так намного удобнее.

Через scattered colons в SPF реализованы слова `AT-THREAD-STARTING` и
`AT-PROCESS-STARTING`, которые вызываются при старте потока и при старте
процесса соответственно. Например библиотека `lib\include\float2.f` добавляет в
`AT-THREAD-STARTING` действия по инициализации внутренних переменных.

[scatter]: http://www.forth.org.ru/~mlg/ScatColn/ScatteredColonDef.html

----
<a id="task"/>
###[Multitasking][start]

Потоки создаются словом `TASK: ( xt -- task)` и запускаются словом 
`START ( u task -- tid )`, 
`xt` это исполнимый токен который получит управление при старте потока и
на стеке будет пользовательский параметр `u`. Возвращаемое значение `tid`
используется для остановки потока снаружи словом `STOP ( tid -- )`.
Приостановить поток на заданное время можно словом `PAUSE ( ms -- )`.
Пример:

	REQUIRE { lib/ext/locals.f

	:NONAME { u \ -- }
	   BEGIN
	   u .
	   u 10 * 100 + PAUSE
	  AGAIN
	; TASK: thread
	
	: go
	  10 0 DO I thread START LOOP
	  2000 PAUSE
	  ( tid1 tid2 ... tid10 )
	  10 0 DO STOP LOOP
	;

	go

Обычные переменные (`VARIABLE`, `VALUE`) будут разделять своё значение между
потоками. Если же переменная должна быть локальной для потока - следует
определять её словом `USER ( "name" -- )` или `USER-VALUE ( "name" -- )`.
USER-переменные при старте потока инициализируются нулём.


----
<a id="voc"/>
###[Vocabularies][start]

Словари создаются либо стандартным `VOCABULARY ( "name" -- )` 
либо словом `WORDLIST ( -- wid )`. 
Точнее, `WORDLIST` это более общее понятие - просто список слов. Есть
также слово `TEMP-WORDLIST ( -- wid)` создающее временный словарь, который по
окончании работы надо освободить из памяти словом `FREE-WORDLIST`, содержимое
временного словаря не попадёт в образ системы при использовании слова `SAVE`.
Слово `{{ ( "name" -- )` сделает словарь name контекстным, а слово `}}` вернёт как
было. Пример:

	MODULE: my
	: + * ;
	;MODULE
	{{ my 2 3 + . }}
напечатает 6, а не 5.


[start]: #start

----
----

<title>Особенности SPF</title>