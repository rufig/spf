<a id="start"/>

[SPF](readme.en.html) specific
==============================

<title>SPF specific</title>

<i>A short introduction, for those already familiar with some
Forth-system and ANS'94 standard.</i>

<small>Last update: $Date$</small>

<!-- Translation is in sync with intro.ru.md rev. 1.39 -->

----

[[Russian](intro.ru.html)] [[English](intro.en.html)]

----

##Contents

* [Installed SPF4. And what's next?](#devel)
* [How to run and include forth code?](#include)
* [REQUIRE](#require)
* [INCLUDED search path](#included-path)
* [Modules](#module)
* [Case sensitivity](#case)
* [Numbers](#numbers)
* [Float numbers](#float)
* [Structures, records](#struct)
* [Where is FORGET?](#forget)
* [Where is NOT?](#not)
* [Where is DEFER?](#defer)
* [How to clear the stack with one word?](#cls)
* [Comments](#comments)
* [Strings](#string)
* [Multitasking](#task)
* [Vocabularies](#voc)
* [Local and temporary variables](#locals)
* [Creating executable modules](#save)
* [Using external DLLs](#dll)
* [Debugging facilities](#debug)
* [Optimizer](#opt)
* [ANS support](#ans)
* [NOTFOUND](#notfound)
* [Scattered colons](#scatcoln)
* [Search scope](#doublecolon)
* [Exceptions](#catch)

----
<a id="devel"/>
###[Installed SPF4. And what's next?](#devel)

The first and the most important - placement of your working files. There is a
subdir `DEVEL` in the SPF directory where all the the developers' code is located
(including yours). Create a subdir there, for example ~john. Now you can refer to 
your files in short form, `~john/prog/myprog.f`. It simplifies mutual access to 
contributed code. The general convention is to place libraries in the subdirectory 
named `lib`, and example programs in `prog`.

The `devel` directory contains the contributed code of other SP-Forth'ers, the
short (very short) list with descriptions is available: 
[SPF_DEVEL](devel.en.html), or you can scan the directory yourself.

There is also a fancy GUI frontend for SPF. It is located in
`samples/win/spfwc`. Just run the compile.bat script and copy the resulting
binary `spf4wc.exe` to the root installation folder (near to `spf4.exe`).

----
<a id="include"/>
###[How to run and include forth code?](#include)

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
###[REQUIRE](#require)

SPF has a non-standard word `REQUIRE ("word" "file" -- )`, where `word` is
some word defined in the library `file`. If `word` is present in the 
context vocabulary, `REQUIRE` will consider the library already loaded. 
This prevents from loading the same libraries again. At contrary, if `REQUIRE`
fails to find `word` - the library is included as always (via `INCLUDED`).
For example:

	REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f
	REQUIRE ForEach-Word ~pinka/lib/words.f
	REQUIRE ENUM ~nn/lib/enum.f

**NB:** Always select the most unique word from the included library as the
first argument for `REQUIRE`.


----
<a id="included-path"/>
###[INCLUDED search path](#included-path)

`S" file.f" INCLUDED` will search following locations in specified order 

* the short name `file.f` (i.e. in the current directory)
* `PATH_TO_SPF.EXE/devel/file.f` (thus allowing to use other spf developers' code), 
* `PATH_TO_SPF.EXE/file.f` (thus including standard libraries and other files from SPF distribution). 

If you need to specify more paths (for example to use some forth code shared between
several forth systems, or whatever - any code that is not in the spf
files subtree and cannot be addressed relatively from your current
file), then you can either redefine `FIND-FULLNAME` (which is `VECT`) or use
external lib - `~ygrek/spf/included.f`. All you need is to write in
spf4.ini

	~ygrek/spf/included.f
	with: my_path/
	S" my path with spaces/" with

and all the files will be searched in `my_path` in addition to the
earlier described algorithm (`my_path` can be either absolute or relative
spf.exe). 


----
<a id="module"/>
###[Modules](#module)

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
###[Case sensitivity](#case)

SPF is case-sensitive, i.e. the words `CHAR`, `Char` and `char` are different
words. Switching to case-insensitive mode is as simple as including file
`lib/ext/caseins.f`. 

Switching case-insensitivity on and off is possible with `CASE-INS` variable :

	REQUIRE CASE-INS lib/ext/caseins.f
	2 dup * .
	CASE-INS OFF \ make SPF case sensitive as before
	2 DUP * .
	CASE-INS ON  \ enable case insensitivity
	2 dup * .


----
<a id="numbers"/>
###[Numbers](#numbers)

You can input hexadecimal numbers at any time independently of the current
BASE in the following manner:
 
	0x7FFFFFFF
The number is treated as double (i.e. represented with 2 cells on the stack) 
if it has dot at the end :

	9999999999. 1. D+ D.

----
<a id="float"/>
###[Float numbers](#float)

Float numbers are recognized in form `[+|-][dddd][.][dddd]e[+|-][dddd]` after
including `lib/include/float2.f`. So the necessary attribute of the float number
is the exponent symbol - `e`.

Float wordset is implemented as defined by ANS-94 :

	REQUIRE F. lib/include/float2.f
	0.1e 0.2e F+ F.
	FVARIABLE a
	FPI a F!
	a F@ F.

The words `D>F ( D: d -- F: f )` and `F>D ( F: f -- D: d )` transfer double integer
values from data to float stack and reverse. The fractional part of float number is 
truncated in this case. Similar words for single values are available :

	10 DS>F 3 DS>F F+ F>DS .

Float stack is implemented using the hardware x87 stack, hence the inherited 
features (circular stack with maximum capacity of 8 elements).


----
<a id="struct"/>
###[Structures, records](#struct)

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
###[Where is FORGET?](#forget)

No `FORGET`. But we have `MARKER ( "name" -- )` (use `lib/include/core-ext.f`).


----
<a id="not"/>
###[Where is NOT?](#not)

The word `NOT` (logical negation) is not implemented. It can be added with 
`~profit/lib/logic.f` extension. Companion words `>=` (more or equal) and 
`<=` (less or equal) are also defined there.

 
----
<a id="defer"/>
###[Where DEFER?](#defer)

Deferred words in SPF are created with `VECT ( "word" -- )` (as 'VECTor'). 
`TO ( xt "word" -- )` assigns action to the deferred word.

If you really have to use `DEFER` and `IS`, you can include `lib/include/defer.f`.

The deferred xt cell can be placed in thread USER-space with `USER-VECT ( "word" -- )`.
Note, the deferred word created with `USER-VECT` will be initialized with zero, as all
other [USER](#task) allocated values (`USER`, `USER-VALUE`). Zero is not a valid xt and it will
trigger an exception at runtime if executed. So it is solely your responsibility to initialize
deferred word (for example using [AT-THREAD-STARTING](#scatcoln)).


----
<a id="cls"/>
###[How to clear the stack with one word?](#cls)

Write `lalala`. Or `bububu`. Error will occur and the stack will be cleared. In fact,
the stack is emptied with `ABORT`, which is called when the interpreter cant
find the word. And the proper way to clear stack is: `S0 @ SP!`

----
<a id="comments"/>
###[Comments](#comments)

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
Additionally `SPF/Linux` understands [`#!`][shebang] comment. Make your forth source file executable
and put the following line at the top
 
    #! absolute_path_to_spf_binary
and you will be able to execute this file without specifying spf path at the command line.
Shell interpeter will run spf and pass the location of source file as command-line parameter.
SPF interpreter itself will treat the first line as a comment.
 
[shebang]: http://en.wikipedia.org/wiki/Shebang_(Unix)

----
<a id="string"/>
###[Strings](#string)

Mainly SPF uses strings with counter on the stack - i.e. two values `(addr u)`. 
The string literals are defined with `S"`, which performs slightly different
depending on the current state:

* During interpretation state the string is located in the input parse buffer (`TIB`), 
and so, it is valid only in this line of input.

* During compilation state the string is compiled directly into the word code area.

**NB**: In order to simplify interaction with Windows API the additional zero byte is
compiled directly after the symbols of the string (it is not represented in counter).

`S"` defines a so called static string, which is located in the buffer, or in the
code area. If you need dynamic string, the one that uses memory on the heap, 
use `~ac/lib/str5.f`. Example of usage:

	REQUIRE STR@ ~ac/lib/str5.f
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

Note, SPF kernel adopts the following naming convention for word prefix `S-` 
and suffix `-ED`.

`S-` means that the word takes two values denoting a string from the stack (e.g. 
we have `SFIND` and standard `FIND`, `SLITERAL` and `LITERAL`, and so on).

`-ED` in the words `CREATED`, `INCLUDED`, `REQUIRED`, `ALIGNED` means that the
arguments are taken from the stack, contrary to the original words taking
arguments from the input stream (or global variable as in `ALIGN` and `ALIGNED`). 
Consider equivalent examples `CREATE some` and `S" some" CREATED`.

----
<a id="task"/>
###[Multitasking](#task)

Threads are created with `TASK: ( xt "name" -- )` and started with
`START ( u task -- tid )`, 
`xt` is an executable token to get control at the thread start with one
parameter on the stack - `u`. The returned value `tid` can be used to stop the
thread from outside with `STOP ( tid -- )`. `SUSPEND ( tid -- )` and
`RESUME ( tid -- )` will pause the requested thread, and resume its execution 
(this words should be executed from the context of another thread than the one 
being paused or resumed)

`PAUSE ( ms -- )` will pause the current thread for the given time (in milliseconds).

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
all threads. If you need a thread-local variable - define it with 
`USER ("name" -- )` or `USER-VALUE ( "name" -- )`. 
USER-variables are zero-initialized at thread start.


----
<a id="voc"/>
###[Vocabularies](#voc)

One creates vocabularies with standard word `VOCABULARY ( "name" -- )` 
or `WORDLIST ( -- wid )`. 
To be precise, `WORDLIST` is a more general object - just a list of words.
The word `TEMP-WORDLIST ( -- wid )` will create a temporary wordlist, which
must be freed with `FREE-WORDLIST`. The contents of the temporary wordlist
won't be present in the SAVEd image.
The word `{{ ( "name" -- )` will set `name` as a context vocabulary, and `}}`
will fall back. Consider:

	MODULE: my
	: + * ;
	;MODULE
	{{ my 2 3 + . }}
will print 6, not 5.

----
<a id="locals"/>
###[Local and temporary variables](#locals)

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
See full description and more examples in the library `lib/ext/locals.f`.

`lib/ext/locals.f` introduces syntax incompatible with ANS-94. ANS-compatible
local variables are implemented in `~af/lib/locals-ans.f`:

	REQUIRE LOCALS| ~af/lib/locals-ans.f
	
	: plus  LOCALS| a b |
	a b + TO a
	a b * ;
	2 3 plus .
	>10
	> Ok

----
<a id="save"/>
###[Producing executable modules](#save)

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
<a id="dll"/>
###[Using external DLLs](#dll)

*FIXME:* rewrite, more examples

Import functions with stdcall calling convention (e.g. Win32 API) as follows :

	WINAPI: SevenZip 7-zip32.dll
Functions with cdecl calling convention (e.g. from msvcrt.dll) or with
variable number of arguments :

	REQUIRE CAPI: ~af/lib/c/capi.f
    2 CAPI: strstr msvcrt.dll

If you want to import automatically all DLL functions as forth words,
use (for stdcall) : 

	REQUIRE UseDLL ~nn/lib/usedll.f
	UseDLL "DLL name"
or:

	REQUIRE DLL ~ac/lib/ns/dll-xt.f
	DLL NEW: "DLL name" 
For cdecl :

	REQUIRE USES_C ~af/lib/c/capi-func.f
	USES_C "DLL name"
or:

	REQUIRE SO ~ac/lib/ns/so-xt.f
	SO NEW: "DLL name"

**SPF/linux**

Low-level words `DLOPEN` `DLSYM` `symbol-addr` `symbol-call`

Usage. By default `libc` `libdl` and `libpthread` are loaded. Load other shared objects with:

    USE so-file-name

Invoking dynamic function

    (( H-STDOUT S" hello world!" )) write DROP
Nota bene, parameters are passed from left to right, `DROP` removes return value after the call.
If there are some parameters on the stack already:

    H-STDOUT 1 <( S" hello world!" )) write DROP
i.e. the number before `<(` shows how much parameters are already on the stack ("out of brackets").

Core implementation of `(( ))` doesn't allow nested invocations. Use `~ygrek/lib/linux/ffi.f` to
overcome this limitation.

`~ac/lib/ns/so-xt.f` works in `spf/linux` (identically to Windows version!).

----
<a id="debug"/>
###[Debugging facilities](#debug)

`STARTLOG` starts logging all console output (`TYPE`, `.`, etc) 
to the `spf.log` file in the current directory. `ENDLOG`, respectively, 
stops such behaviour.

[More in devel](devel.en.html#debug)

----
<a id="opt"/>
###[Optimizer](#opt)

SPF uses the subroutine threaded code, i.e. the compiled code looks like the
chains of `CALL <word-cfa-address>`. This code can be ran directly, but by
default it is processed with the optimizer to gain a speedup at runtime. It
performs inlining and peephole-optimization. More on ForthWiki (in russian):
"[Optimizing compiler](http://wiki.forth.org.ru/optimizer)".

**Tuning optimizer** *(default values are ok in the vast majority of cases, most
probably you dont need these options!)*

* `DIS-OPT` disables macrooptimization
* `SET-OPT` enables macrooptimization (it is on by default)
* `0 TO MM_SIZE` disables inlining (remember that inlining of `DO` `LOOP` and
  some other words is performed by the spf kernel itself and thus is not affected with this option)  
* `TRUE TO ?C-JMP` enables recursion tail-call optimization (experimental,
  disabled by default, may not work in some cases)
* `FALSE TO VECT-INLINE?` disables direct compilation of vector calls

**NB**: If your program starts behaving in a strange way, try to
temporarily turn off the optimizer using `DIS-OPT`, probably (very unlikely!) you
have encountered a bug in optimizer. If so - locate the piece of code where the
bug occurs and file a bugreport please.

You can examine results of the word compilation as a native code with 
disassembler:

	REQUIRE SEE lib/ext/disasm.f
	SEE word-in-interest

or get the line-by-line listing (forth code with the corresponding asm code)

	REQUIRE INCLUDED_L ~mak/listing2.f
	S" file, with the code in interest"  INCLUDED_L
	\ the listing will be placed in the file near to the file included

**Optimization effect: conditionals**

Consider the following usual piece of code `10 > IF ... THEN` -- push literal on the stack, compare two
top stack elements, store the result back on the stack and then conditionally jump using the top of the stack as a
flag. Optimizer will turn this into just the pair of machine commands:

	lib/ext/disasm.f
	:NONAME DUP 10 > IF 1 . THEN ; REST

Result:

	cmp eax, # A
	jle @@1
	...
	@@1:

The same applies for other typical code sequences : `2DUP = IF ... THEN` and similar:

	lib/ext/disasm.f
	:NONAME 2DUP = IF 1 . THEN ; REST

Result:

	cmp eax, 0 [ebp]
	jne @@1
	...
	@@1:

Logical operations are also optimized (`0=` is used as logical negation here, thus 
`0< 0=` means "more or equal to zero"):

	lib/ext/disasm.f
	:NONAME DUP 0< 0= IF 1 . THEN ; REST

Result:

	or eax, eax
	jl @@1
	...
	@@1:

**Optimization effect: words created with `CREATE`, `VARIABLE`, `VALUE`, `USER`**

When compiling variables or constants, instead of simply calling a DOES-action of the
word being compiled, the specialized procedure (which knows the internal representation of such
words) inlines the corresponding code. E.g.:

	lib/ext/disasm.f
	10 CONSTANT c
	:NONAME c ; REST
	
	10 VALUE vl
	:NONAME vl ; REST
	
	VARIABLE vr
	:NONAME vr @ ; REST

Result:

	mov     -4 [ebp] , eax
	mov     eax , # A
	lea     ebp , -4 [ebp}
	ret
	
	mov     -4 [ebp] , eax
	mov     eax , 572410  ( vl+5  )
	lea     ebp , -4 [ebp]
	ret
	
	mov     -4 [ebp] , eax
	mov     eax , 57243C  ( vr+5  )
	lea     ebp , -4 [ebp]
	ret


----
<a id="ans"/>
###[ANS support](#ans)

Maximum ANS conformity is achieved by including `lib/include/ansi.f`.
Additional words are defined, some of them dummies, etc. 

Also, a non-standard optimization of FILE wordset is fixed - `OPEN-FILE`,
`CREATE-FILE` and other implicitly treat the input string as zero-ended (ignoring the
length parameter). `lib/include/ansi-file.f` will add an extra zero byte in
such case, after copying the file name to the dynamic buffer, which remains
allocated for future use. You don't really need such behaviour when
defining file names with string literal `S"` or string libraries
`~ac/lib/str*.f`, as they ensure there is an extra zero byte. Though it can be
helpful for using non-SPF libraries.

----
<a id="callback"/>
###[Callbacks](#callback)

`CALLBACK: ( "name" xt bytes -- )` takes the `xt` of word to decorate as a callback
and the number of __bytes__ which will be used for the stack parameters during invocation.
You solely own the responsibility for matching calling conventions (cdecl,stdcall).
Cdecl calling convention (default for C/C++) assumes that you leave all input parameters intact
(e.g. duplicate before using). Stdcall expects `xt` to eat all paramaters from the stack. Also, bear
in mind that callback should always return one additional CELL -- result value, even if the code
calling this callback declares it as void (it is the feature of `CALLBACK:`).
Example :

Callback is declared as follows (C++) :

    typedef void (*TestCallback)(char*,int);
Forth code defines callback

    :NONAME ( n str -- )
      2DUP \ duplicate all params (cause cdecl)
      ASCIIZ> CR TYPE \ string
      CR . \ number
      0 \ return value
    ; 2 CELLS \ 2 parameters - 8 bytes
    CALLBACK: Test \ new word Test is a callback


----
<a id="notfound"/>
###[NOTFOUND](#notfound)

This word is called from the context vocabulary during the interpretation
cycle when the word being parsed cannot be found. `NOTFOUND ( a u -- )` should
throw an exception if it cant process the passed word. Else INTERPRET
considers the word valid and continues parsing. Default `NOTFOUND`
recognizes numbers and provides access to the [nested vocabularies](#doublecolon).

A good form to redefine `NOTFOUND` is to call its old xt first, and proceed
with your own code only if previous one fails with exception. Example:

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

`~pinka/samples/2006/core/trans/nf-ext.f` simplifies adding custom xt to the `NOTFOUND` chain.


----
<a id="scatcoln"/>
###[Scattered colons](#scatcoln)

Read the full description of this technique: "[Scattering a Colon
Definition][scatter]" in English. Briefly: new actions can be added to the
word after its compilation. The word `...` prepares space for the future
extending, `..:` and `;..` link the code as an extension.

	: INIT ... orig ; 
	\ INIT called here will execute orig
	..: INIT extend1 ;.. 
	\ here - extend1 and orig will be executed sequentially
	..: INIT extend2 ;.. 
	\ equal to : INIT extend1 extend2 orig ;
	\ and so forth

You can achieve the same effect with vectors, but this way looks better.

SPF uses scattered colons to define `AT-THREAD-STARTING` and
`AT-PROCESS-STARTING`, which are called when the process and the thread are
started, respectively. For example, `lib/include/float2.f` adds initialization
of the inner variables in `AT-THREAD-STARTING`.

[scatter]: http://www.forth.org.ru/~mlg/ScatColn/ScatteredColonDef.html

----
<a id="doublecolon"/>
###[Search scope](#doublecolon)

As expected the search scope is generally controlled by `CONTEXT`, but sometimes there is a
need to explicitely specify vocabulary for searching particular word. In such cases special
syntax `Wordlist::word` is used. Example:

	MODULE: someWords
	: TYPE 2DROP ;
	;MODULE
	
	ALSO someWords \ adding someWords vocabulary to context
	S" foo" TYPE \ nothing happens - TYPE from someWords was used
	S" bar" FORTH::TYPE \ explicit usage of "ordinary" TYPE from the main vocabulary

When performing actions on words via `'` (get xt by name), `POSTPONE`
(compile), `TO` (secondary word action) the search scope is defined as follows:

    Wordlist::' word
    Wordlist::POSTPONE word
    etc 

because such words do parse the input stream on their own and `word` is not handled by `INTERPRET` 
and corresponding `NOTFOUND`.


----
<a id="catch"/>
###[Exceptions](#catch)

Exceptions handling in SPF is performed according to ANS-94 with `THROW` and `CATCH`.

`THROW ( n -- )` raises an exception with numeric code `n` (except `n` is zero), 
i.e. execution of the current and all parent words is aborted until the exception is caught.

`CATCH ( i*x xt -- i*x n | 0 )` executes `xt` and catches all exceptions raised within `xt`. 
Result is zero in case there were no exceptions, else exception code is returned (that same `n` 
that was passed as argument to `THROW` which raised this exception, or the system error code)
and stack depth is set equal to the one before `xt` was executed (but the data on the stack may be
corrupted if `xt` was writing stack at this depth).

All exceptions can be divided in two groups - system (memory access vioaltion, division by zero, etc)
and native (`THROW` word with non-zero argument). All exceptions are caught identically, but 
system ones do print additional exception report.

Many words return `ior` (input/output result code), e.g. file operations (`CREATE-FILE`, 
`OPEN-FILE`, `READ-FILE`, `WRITE-FILE`, `CLOSE-FILE` etc) and memory operations (`ALLOCATE`, 
`FREE`, `RESIZE`). This `ior` is equal to error code (in case there was one) and can be `THROW`n directly.

    : file S" rewdsadwerdfstrg" R/O OPEN-FILE THROW ; \ try to open non-existing file
    : divide 
        ['] / CATCH  \ catch exception from division
        IF ." Dont divide by " . DROP  \ there was an exception - two numbers on the stack
        ELSE ." Result : " . \ result of successful division
        THEN CR ; 
    : test 
       10 2 divide \ everything ok
       1 0 divide  \ system exception - SPF report and our message from the divide word
       ['] file CATCH IF ." Caught exception" CR THEN \ catch native exception
       \ there is no need to always throw ior, it can be analyzed in place
       S" dsderewfdstrtr" R/O OPEN-FILE IF ." bad file" ELSE ." Good file" THEN CR ;
    test

All error codes, passed to `THROW` and left on stack after `CATCH`,
are interpreted according to `spf.err` file, from the `lib` directory. Text messages printed
in report are taken from this file.

----
