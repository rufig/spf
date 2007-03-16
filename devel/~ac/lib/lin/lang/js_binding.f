( ~ac: 21.01.2005, изменени€ под SO - 28.08.2005 

  $Id$

  ѕрив€зка JavaScript через SpiderMonkey - JS-движок из Mozilla.
  “екущие версии dll дл€ JS1.7 брать из FireFox2.

  http://www.mozilla.org/js/spidermonkey/apidoc/jsguide.html
  http://egachine.berlios.de/embedding-sm-best-practice/ar01s05.html
  http://www.mozilla.org/js/spidermonkey/apidoc/gen/api-JSClass.html
  http://www.mozilla.org/js/spidermonkey/apidoc/gen/api-JS_EvaluateScript.html
  http://lxr.mozilla.org/mozilla/source/js/src/jsapi.h
  http://lxr.mozilla.org/seamonkey/source/js/src/jsxml.c
  http://www.sdjournal.org/en/attachments/SF_02-2005_EN_Spider.pdf
)

REQUIRE DL            ~ac/lib/ns/so-xt.f

ALSO SO NEW: js3250.dll

\ #define JSVAL_OBJECT            0x0     /* untagged reference to object */
\ #define JSVAL_INT               0x1     /* tagged 31-bit integer value */
\ #define JSVAL_DOUBLE            0x2     /* tagged reference to double */
\ #define JSVAL_STRING            0x4     /* tagged reference to string */
\ #define JSVAL_BOOLEAN           0x6     /* tagged boolean value */

\ js_InitXMLClasses JS_HAS_XML_SUPPORT JSOPTION_XML=JS_BIT(6)

USER rt
USER cx
USER global

: JsInit
  8  1024 * 1024 * 1 JS_Init DUP rt ! 0= IF ABORT THEN
  8192 rt @ 2 JS_NewContext DUP cx ! 0= IF ABORT THEN
  cx @ 1 JS_GetOptions 64 ( JSOPTION_XML) OR cx @ 2 JS_SetOptions DROP \ работает в DeerPark
  0 0 0 cx @ 4 JS_NewObject DUP global ! 0= IF ABORT THEN
  global @ cx @ 2 JS_InitStandardClasses 1 <> IF ABORT THEN
  S" 1.7" DROP 1 JS_StringToVersion cx @ 2 JS_SetVersion 0 <> IF ABORT THEN \ без этого не работают генераторы let/yield
;
: JsVal> ( jval -- val type )
  DUP 1 AND 1 = IF 1 RSHIFT 1 EXIT THEN   \ val 1 int
  DUP 7 AND 
  DUP 2 = IF EXIT THEN                    \ ref 2 double
  DUP 4 = IF EXIT THEN                    \ ref 4 string
  DUP 6 = IF SWAP 14 = SWAP EXIT THEN     \ val 6 bool
;
: JsEval
  0 >R 
  RP@ ROT ROT 0 0 2SWAP SWAP 
  global @ cx @ 7 JS_EvaluateScript 1 <> IF RDROP ABORT THEN
  R> JsVal>
;
\ PAD 0 0 S" 5+5" SWAP global @ cx @ JS_EvaluateScript NIP NIP NIP NIP NIP NIP NIP . PAD @ .
: UASCIIZ> ( addr -- addr u ) \ вариант ASCIIZ> дл€ Unicode
  0 OVER
  BEGIN
    DUP W@ 0<>
  WHILE
    2+ SWAP 1+ SWAP
  REPEAT DROP 2*
;
: J.
  DUP 1 = IF DROP ." int:" . EXIT THEN 
  DUP 6 = IF DROP ." bool:" . EXIT THEN 
  DUP 4 = IF DROP @ UASCIIZ> ." string:" TYPE EXIT THEN
  DROP ." ref:" DUP . @ .
;
: JE 2DUP TYPE ."  --> " JsEval J. CR ;

:NONAME ( *report *message *cx -- )
  CR ." ERROR: "
  OVER ASCIIZ> TYPE CR 0
; 3 CELLS CALLBACK: ERRORREP

\ ѕример самодельной форт-функции, внедр€емой внутрь JS через JS_DefineFunctions
:NONAME ( *rval *argv argc *obj *cx -- flag )
  ." TESTF: "
  2>R DUP . \ число параметров
      OVER @ @ UASCIIZ> TYPE CR \ переданна€ строка
  2R>
  2>R 2>R 14 ( JSVAL_TRUE) OVER ! 2R> 2R> \ возвращаемый результат
  1 \ JS_TRUE - выполнено успешно
; 5 CELLS CALLBACK: TESTF


 
CREATE MyFunctions HERE 0 , ' TESTF , 1 ,
0 , 0 , 0 ,
HERE S" testf" S, 0 , SWAP !

( CREATE MyFunctions S" testf" S, 0 C, ' TESTF , 1 ,
0 , 0 , 0 , 
MyFunctions 20 DUMP)

\ EOF
\ 0 JS_GetImplementationVersion ASCIIZ> TYPE \ DeerPark a2: JavaScript-C 1.5 pre-release 6a 2004-06-09

JsInit
' ERRORREP cx @ 2 JS_SetErrorReporter .

MyFunctions global @ cx @ 3 JS_DefineFunctions .
S" testf('test')" JE

S" 5+5" JE
S" var x=10.0;Math.sqrt(x*x*x*x);" JE
S" Date()" JE
S" d=new Date;d.getFullYear()" JE
S" 'some string, рус'" JE
S" 5==5" JE
S" false" JE
S" this" JE
S" this.Date()" JE
S" x" JE
S" var y=5.6" JE
S" y" JE
S" s = /test/i;s.test('Test');" JE
S" s.test('Forth');" JE
S" d.toString().bold().link('http://www.ru/');" JE
S" '1 2 3'.split(' ')" JE
S" '1 2 3'.split(' ').toString()" JE
S" '1 2 3'.split(' ').constructor" JE
S" typeof('1 2 3'.split(/\s+/))" JE
\ S" var order = new XML('<order><customer><name>Joe Green</name><address><street>410 Main</street><city>York</city><state>VT</state></address></customer><item>. . .</item><item><make>Acme</make><model>Framistat</model><price>2.50</price><qty>30</qty></item></order>');" JE
S" var order = <order><customer><name>Joe Green</name><address><street>410 Main</street><city>York</city><state>VT</state></address></customer><item>. . .</item><item><make>Acme</make><model>Framistat</model><price>2.50</price><qty>30</qty></item></order>" JE
S" typeof(order)" JE
S" order.customer.address.toString()" JE
S" order..qty.toString()" JE
S" typeof([1])" JE
S" typeof(1)" JE
S" NaN" JE
\ S" SyntaxError()" JE
\ S" bug" JsEval . . CR
\ S" re=new RegExp(/g\[[^\]]+]/);testre=re.exec('abc[test]zzz[222]');testre.length" JE
\ S" re=new RegExp('/./');testre=re.exec('abc[test]zzz[222]');testre.length" JE
CHAR ' PARSE var it = Iterator({name:"Jack Bauer", username:"JackB", id:12345, agency:"CTU", region:"Los Angeles"})' JE
S" it.next().toString()" JE
S" function range(beg, end){ for(let i = beg; i < end; ++i) {yield i}}" JE
S" [i * i for (i in range(0, 10))].toString()" JE
S" let today = Date.parse('2006-10-25T')" JE
