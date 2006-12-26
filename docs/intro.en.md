<a id="start"/>

SPF specific
============

<title>SPF specific</title>

<i>A short introduction, for those already familiar with some
Forth-system and ANS'94 standard.</i>

<small>Last update: $Date$</small>

<!-- Translated from intro.ru.md (rev. 1.5) -->

----

##Contents

* [Installed SPF4. And what's next?](#devel)
* [Optimizer](#opt)
* [ANS support](#ans)
* [How to run and include forth code?](#include)
* [REQUIRE](#require)
* [Modules](#module)
* [Case sensitivity](#case)
* [Numbers](#numbers)
* [Structures, records](#struct)
* [Where is FORGET?](#forget)
* [How to clear the stack with one word?](#cls)
* [Debugging facilities](#debug)
* [Comments](#comments)
* [Strings](#string)
* [Creating executable modules](#save)
* [Local and temporary variables](#locals)
* [Using external DLLs](#dll)
* [NOTFOUND](#notfound)
* [Scattered colons](#scatcoln)
* [Multitasking](#task)
* [Vocabularies](#voc)

----
<a id="devel"/>
###[Installed SPF4. And what's next?][start]

The first and the most important - placement of your working files. There is a
subdir `DEVEL` in the SPF directory where all the the developers' code is located
(including yours). Create a subdir there, for example ~john. Now you can refer to 
your files in short form, `~john\prog\myprog.f`. It simplifies mutual access to 
contributed code. The general convention is to place libraries in the subdirectory 
named `lib`, and example programs in `prog`.

The `devel` directory contains the contributed code of other SP-Forth'ers, the
short (very short) list with descriptions is available: 
[SPF_DEVEL](devel.en.html), or you can scan the directory yourself.


----
<a id="opt"/>
###[Optimizer][start]

SPF uses the subroutine threaded code, i.e. the compiled code looks like the
chains of `CALL <word-cfa-address>`. This code can be ran directly, but by
default it is processed with the optimizer to gain a speedup at runtime. It
performs inlining and peephole-optimization. More on ForthWiki (in russian):
"[Optimizing compiler](http://wiki.forth.org.ru/optimizer)".

**NB**: If your program starts behaving in a strange way, try to
temporarily turn off the optimizer using `DIS-OPT` (turn on with `SET-OPT`),
probably (unlikely!) you have encountered a bug in optimizer. If so - cut the
piece of code where the bug occurs and send it to the author.

You can examine results of the word compilation as a native code with 
disassembler:

	REQUIRE SEE lib/ext/disasm.f
	SEE word-in-interest

or get the line-by-line listing

	REQUIRE INCLUDED_L ~mak/listing2.f
	S" file, with the code in interest"  INCLUDED_L
	\ the listing will be placed in the file near to the file included


----
<a id="ans"/>
###[ANS support][start]

Maximum ANS conformity is achieved by including `lib/include/ansi.f`.
Additional words are defined, some of them dummies, etc. Also, a tricky
behaviour of the FILE words is corrected - `OPEN-FILE`, `CREATE-FILE` and
other such words implicitly treat the input string as zero-ended (ignoring the
length parameter), though according to the standard it is an address/counter
pair.

----
<a id="include"/>
###[How to run and include forth code?][start]

* Running the file from the command line is fairly simple, just start SPF with 
the file path as a command line parameter, 

		spf.exe ~john/prog/myprog.f

	Note, that include path can be either absolute or relative to the
[devel](#devel) directory. 

* In SPF console (interpretation mode) just type in the name of the file:

		~john/prog/myprog.f
* For compatibility reasons, it is better to include it in a standard way:

		S" ~vasya/prog/myprog.f" INCLUDED

* But the recommended approach is to use `REQUIRE` word.


----
<a id="require"/>
###[REQUIRE][start]

SPF has a non-standard word `REQUIRE ("word" "file" -- )`, where `word` should
be the one defined in `file`. If this word is already present in the 
system, `REQUIRE` will consider the library already loaded. This prevents from 
loading the same libraries again.
For example:

	REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f
	REQUIRE ForEach-Word ~pinka/lib/words.f
	REQUIRE ENUM ~nn/lib/enum.f



----
<a id="module"/>
###[Modules][start]

SPF has modules, which hide the internal implementation and leave visible the
words of the outer interface.

	MODULE: john-lib
	\ inner words
	EXPORT
    \ interface words, compiled to the outer vocabulary, thus seen from the external world
	DEFINITIONS
	\ inner words again
	EXPORT
	\ you get the idea :)
	;MODULE
You can write `MODULE: john-lib` several times - all the consequent code will
compile to the existing module, not overwriting it. Actually, the word defined
by `MODULE:` is a simple [vocabulary](#voc).


----
<a id="case"/>
###[Case sensitivity][start]

SPF is case-sensitive, i.e. the words `CHAR`, `Char` and `char` are different
words. Switching to case-insensitive mode is as simple as including file
`lib/ext/caseins.f`. 


----
<a id="numbers"/>
###[Numbers][start]

You can input the hexadecimal numbers at any time independently of the current
BASE in the following manner:
 
	0x7FFFFFFF
Float numbers are recognized in form `[+|-][dddd][.][dddd]e[+|-][dddd]` after
including `lib\include\float2.f`.


----
<a id="struct"/>
###[Structures, records][start]

Records are created with the `--` word (the same as `FIELD`). Example:

	0
	CHAR -- flag
	CELL -- field
	10 CELLS -- arr
	CONSTANT struct

The words `flag`, `field` and `arr` will add their offset to the address on the
stack when executed. And the `struct` constant contains the size of the whole
record. Consider:

    struct ALLOCATE THROW TO s \ requested memory from heap for the single struct instance
	1 s flag C!  10 s field ! \ set the struct fields' values
	s arr 10 CELLS DUMP \ output the contents of the array in struct
	s FREE THROW \ free memory

Structures can be inherited:

	0
	CELL -- x
	CELL -- y
	CONSTANT point \ point owns two fields
	
	point
	CELL -- radius
	CONSTANT circle \ circle owns: x, y, radius
	
	point
	CELL -- w
	CELL -- h
	CONSTANT rect \ rect owns: x, y, w, h

----
<a id="forget"/>
###[Where is FORGET?][start]

No `FORGET`. But we have `MARKER ( "name" -- )` (use `lib\include\core-ext.f`).


----
<a id="cls"/>
###[How to clear the stack with one word?][start]

Write `lalala`. Or `bububu`. Error will occur and the stack will be cleared. In fact,
the stack is emptied with `ABORT`, which is called when the interpreter cant
find the word. And the proper way to clear stack is: `S0 @ SP!`


----
<a id="debug"/>
###[Debugging facilities][start]

`STARTLOG` starts the logging of all console output to the `spf.log` file in
the current directory. `ENDLOG`, respectively, stops such behaviour.

More in [devel](devel.en.html)


----
<a id="comments"/>
###[Comments][start]

Comments to the end of line are ` \ `. There are also bracket-comments, which
are multiline. So:

	\ comment till the eol
	( comment
	and here too )
The word `\EOF` comments out everything till the end of file. It is useful to
separate the library code from testing or examples of usage at the end of the same
file.

	word1 word2
	\EOF
	comment till eof


----
<a id="string"/>
###[Strings][start]

Mainly SPF uses strings with counter on the stack - i.e. two values `(addr u)`. 
The string literals are defined with `S"`, which performs slightly different
depending on the current state:

* During interpretation state the string is located in the input parse buffer (`TIB`), 
and so, it is valid only in this line of input.

* During compilation state the string is compiled directly into the word code area.

In order to simplify interaction with Windows API the additional zero byte is
appended to the end of the string.

`S"` defines a so called static string, which is located in the buffer, or in the
code area. If you need dynamic string, the one that uses memory on the heap, 
use `~ac\lib\str4.f`. Example of usage:

	REQUIRE STR@ ~ac/lib/str4.f
	"" VALUE r \ create an empty string
	" SP-Forth " VALUE m
	" - the best!" VALUE w
	m r S+  w r S+
	r STYPE
	> SP-Forth - the best!

Additionally to such handy concatenation, library provides substitution:

	" 2+2={2 2 +}" STYPE
	> 2+2=4

Read full description and more examples in the library itself.

Note, SPF utilizes word prefix `S-` and suffix `-ED`.

`S-` means that the word takes two values denoting a string from the stack (e.g. 
we have `SFIND` and standard `FIND`, `SLITERAL` and `LITERAL`, and so on).

`-ED` in the words `CREATED`, `INCLUDED`, `REQUIRED`, `ALIGNED` means that the
arguments are taken from the stack, contrary to the original words taking
arguments from the input. Consider equivalent examples `CREATE some` and 
`S" some" CREATED`.

----
<a id="save"/>
###[Producing executable modules][start]

`SAVE ( a u -- )` will save the whole system, including all the wordlists
(except temporary ones!) to the executable file, with the path specified
as `a u`. Entry point is set with VALUE `<MAIN>` for the console mode and
VARIABLE `MAINX`  for GUI. The mode itself is defined with either `?CONSOLE`
or `?GUI`. `SPF-INIT?` controls interpretation of the command-line and
spf4.ini auto-including:

	0 TO SPF-INIT?
	' ANSI>OEM TO ANSI><OEM
	TRUE TO ?GUI
	' NOOP TO <MAIN>
	' run MAINX !
	S" gui.exe" SAVE  

or

    ' run TO <MAIN>
	S" console.exe" SAVE


----
<a id="locals"/>
###[Local and temporary variables][start]

Not available in the kernel, but included.

	REQUIRE { lib/ext/locals.f
	
	\ sample usage
    : test { a b | c d }  \ a b get their values from the stack, c and d are zeroes
	  a TO c
	  b TO d
	  c . d . ;
	1 2 test
	>1 2
	> Ok
Full description and more examples available in the library itself.


----
<a id="dll"/>
###[Using external DLLs][start]

Example:

	WINAPI: SevenZip 7-zip32.dll
If you need to automatically use all dll exported functions as forth words,
use either:

	REQUIRE UseDLL ~nn/lib/usedll.f
	UseDLL "DLL name"

or:

	REQUIRE DLL ~ac/lib/ns/dll-xt.f
	DLL NEW: "DLL name" 

----
<a id="notfound"/>
###[NOTFOUND][start]

This word is called from the context vocabulary during the interpretation
cycle when the word being parsed cannot be found. `NOTFOUND ( a u -- )` should
throw an exception if it cant process the passed word. Else INTERPRET
considers the word valid and continues parsing. Default `NOTFOUND`
recognizes numbers, and provides access to the nested vocabularies:

	vocname1:: wordname

A good form to redefine `NOTFOUND` is to call its old xt first, and proceed
with your own code only if it fails with exception. Example:

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
Or:

	 : NOTFOUND ( a u -- )
	   2DUP MY? IF DO-MY EXIT THEN
	   ( a u )
	   NOTFOUND
	   ;


----
<a id="scatcoln"/>
###[Scattered colons][start]

Read the full description of this technique: "[Scattering a Colon
Definition][scatter]" in English. Briefly: new actions can be added to the
word after its compilation.

	: INIT ... do1 ; 
	\ INIT called here will execute do1
	..: INIT do2 ;.. 
	\ here - do2 and do1 will be executed sequentially
	..: INIT do3 ;.. 
	\ equal to : INIT do2 do3 do1 ;
	\ and so forth

You can achieve the same effect with vectors, but this way looks better.

SPF uses scattered colons to define `AT-THREAD-STARTING` and
`AT-PROCESS-STARTING`, which are called when the process and the thread are
started, respectively. For example, `lib\include\float2.f` adds initialization
of the inner variables in `AT-THREAD-STARTING`.

[scatter]: http://www.forth.org.ru/~mlg/ScatColn/ScatteredColonDef.html

----
<a id="task"/>
###[Multitasking][start]

Threads are created with `TASK: ( xt -- task)` and started with
`START ( u task -- tid )`, 
`xt` is an executable token to get control at the thread start with one
parameter on the stack - `u`. The returned value `tid` can be used to stop the
thread from outside with `STOP ( tid -- )`. `PAUSE ( ms -- )` will pause the
thread for the given time.
E.g.:

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

Variables defined with `VARIABLE`, `VALUE` etc will share their values among
the threads. If you need a thread-local variable - define it with 
`USER ("name" -- )` or `USER-VALUE ( "name" -- )`. 
USER-variables are zero-initialized at thread start.


----
<a id="voc"/>
###[Vocabularies][start]

One creates vocabularies with standard word `VOCABULARY ( "name" -- )` 
or `WORDLIST ( -- wid )`. 
To be precise, `WORDLIST` is a more general object - just a list of words.
The word `TEMP-WORDLIST ( -- wid)` will create a temporary wordlist, which
must be freed with `FREE-WORDLIST`. The contents of the temporary wordlist
won't be present in the SAVEd image.
The word `{{ ( "name" -- )` will set `name` as a context vocabulary, and `}}`
will fall back. Consider:

	MODULE: my
	: + * ;
	;MODULE
	{{ my 2 3 + . }}
will print 6, not 5.


[start]: #start

----
----
