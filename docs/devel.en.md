[SP-Forth](readme.en.html): Additional libraries
================================================

<title>SP-Forth: additional libraries</title>

<small>$Date$</small>

<!-- Translation is in sync with devel.ru.md rev. 1.7 -->

*REQUIRE is a forth word, which loads library; unnecessary text is commented out, so you can use this list as a forth code to include libs :)*

----

[[Russian](devel.ru.html)] [[English](devel.en.html)]

----

[[Network](#net)] [[Graphics](#graph)] [[Archives](#arc)] [[Linked lists](#list)] [[Records](#record)] [[Data structures](#data)] [[Sort and search](#sort-n-search)] [[Techniques](#techniques)] [[Debugging](#debug)] [[Random numbers](#random)] [[Hash tables](#hash)] [[Hash functions](#hash-func)] [[Compiletime constants](#compiletime-const)] [[Windows GUI](#WinGUI)] [[Windows COM](#WinCOM)] [[Windows services](#services)] [[Date and time](#datetime)] [[Databases](#db)] [[Threads](#threads)] [[Windows registry and ini](#ini-registry)] [[Strings](#str)] [[Files](#files)] [[OOP](#oop)] [[Vocabularies](#vocs)] [[Memory](#mem)] 

----

<a id="net"/>
### \\ Network
* REQUIRE CreateSocket <a
href='../devel/~ac/lib/win/winsock/sockets.f'>~ac/lib/win/winsock/sockets.f</a> \\ basic TCP/IP support
* REQUIRE SslInit <a href='../devel/~ac/lib/win/winsock/ssl.f'>~ac/lib/win/winsock/ssl.f</a> \\ basic SSL/TLS support
* REQUIRE SslClientSocket <a href='../devel/~ac/lib/win/winsock/sockets_ssl.f'>~ac/lib/win/winsock/sockets_ssl.f</a> \\ SSL/TLS-server 
* REQUIRE SocketLine <a href='../devel/~ac/lib/win/winsock/socketline2.f'>~ac/lib/win/winsock/socketline2.f</a> \\ line-by-line buffered socket reading
* REQUIRE ReadFrom <a href='../devel/~ac/lib/win/winsock/sockname.f'>~ac/lib/win/winsock/sockname.f</a> \\ UDP support
* REQUIRE fsockopen <a href='../devel/~ac/lib/win/winsock/psocket.f'>~ac/lib/win/winsock/psocket.f</a> \\ simplified interface to sockets
* REQUIRE ForEachIP <a href='../devel/~ac/lib/win/winsock/foreach_ip.f'>~ac/lib/win/winsock/foreach_ip.f</a> \\ performing given tasks for each IP host
* REQUIRE SendDnsQuery <a
href='../devel/~ac/lib/win/winsock/dns_q.f'>~ac/lib/win/winsock/dns_q.f</a> \\ querying DNS-servers 
* REQUIRE PutFileTr <a href='../devel/~ac/lib/win/winsock/transmit.f'>~ac/lib/win/winsock/transmit.f</a> \\ high-speed file transmition in Windows 
* REQUIRE SnmpInit <a
href='../devel/~ac/lib/win/snmp/snmp.f'>~ac/lib/win/snmp/snmp.f</a> \\ SNMP support
* REQUIRE GET-FILE-VIAPROXY <a href='../devel/~ac/lib/lin/curl/curl.f'>~ac/lib/lin/curl/curl.f</a> \\ cURL-wrapper - send/receive files via HTTP/FTP/etc
* \\ ~nn/lib/net/ \\ HTTP, POP3, FTP, etc 

<a id="graph"/>
### \\ Graphics
* REQUIRE GLWindow <a href='../devel/~ygrek/lib/joopengl/GLWindow.f'>~ygrek/lib/joopengl/GLWindow.f</a> \\ OpenGL with joop 

<a id="list"/>
### \\ Data structures - list 
* REQUIRE ListNode <a href='../devel/~day/joop/lib/list.f'>~day/joop/lib/list.f</a> \\ double-linked list 
* REQUIRE AddNode <a href='../devel/~ac/lib/list/STR_LIST.f'>~ac/lib/list/STR_LIST.f</a> \\ linked list 
* REQUIRE LINK, <a href='../devel/~day/common/link.f'>~day/common/link.f</a> \\ static list (compiles in code area) 
* REQUIRE firstNode <a href='../devel/~day/lib/staticlist.f'>~day/lib/staticlist.f</a> \\ double-linked list, pretty much words 
* REQUIRE list+s <a href='../devel/~pinka/lib/list_ext.f'>~pinka/lib/list_ext.f</a> \\ linked list 

<a id="record"/>
### \\ Data structures - record
* REQUIRE STRUCT: <a href='../lib/ext/struct.f'>lib/ext/struct.f</a> \\ simple records 
* REQUIRE f: <a href='../devel/~af/lib/struct.f'>~af/lib/struct.f</a> \\ defining records with elements-functions 
* REQUIRE f: <a href='../devel/~af/lib/struct-t.f'>~af/lib/struct-t.f</a> \\ defining records with elements-functions in the temporary vocabulary

<a id="data"/
### \\ Data structures - misc
* REQUIRE Stack <a href='../devel/~day/joop/lib/stack.f'>~day/joop/lib/stack.f</a> \\ stack
* REQUIRE New-Queue <a href='../devel/~pinka/lib/queue_pr.f'>~pinka/lib/queue_pr.f</a> \\ priority queue
* REQUIRE x.mask <a href='../devel/~mlg/SrcLib/bitfield.f'>~mlg/SrcLib/bitfield.f</a> \\ Bit arrays
* REQUIRE RATIO <a href='../devel/~pinka/lib/BigMath.f'>~pinka/lib/BigMath.f</a> \\ Rational fractions (big numbers)

### \\ Programming techniques 
* REQUIRE { <a href='../lib/ext/locals.f'>lib/ext/locals.f</a> \\ Local variables
* REQUIRE LAMBDA{ <a href='../devel/~pinka/lib/lambda.f'>~pinka/lib/lambda.f</a> \\ :NONAME but in the compilation state
* REQUIRE (: <a href='../devel/~yz/lib/inline.f'>~yz/lib/inline.f</a> \\ lambda analogue
* REQUIRE CONT <a href='../devel/~profit/lib/bac4th.f'>~profit/lib/bac4th.f</a> \\ backtracking, see description in <a href='../devel/~mlg/index.html#bacforth'>~mlg/#bacforth</a> 

<a id="sort-n-search"/>
### \\ Search and sort
* REQUIRE HeapSort <a href='../devel/~mlg/SrcLib/hsort.f'>~mlg/SrcLib/hsort.f</a>  \\ Heap sort
* REQUIRE quick_sort <a href='../devel/~pinka/samples/2003/common/qsort.f'>~pinka/samples/2003/common/qsort.f</a> \\ Quick sort
* REQUIRE binary-search <a href='../devel/~profit/lib/binary-search.f'>~profit/lib/binary-search.f</a> \\ Binary search

<a id="debug"/>
### \\ Debugging facilities
* REQUIRE HeapEnum <a href='../devel/~ac/lib/memory/heap_enum2.f'>~ac/lib/memory/heap_enum2.f</a> \\ enumerating allocated memory blocks on the heap
* REQUIRE mem\_stub <a href='../devel/~day/lib/mem_sanity.f'>~day/lib/mem_sanity.f</a> \\ Verifying FREE (via filling with template) 
* REQUIRE MemReport <a href='../devel/~day/lib/memreport.f'>~day/lib/memreport.f</a> \\  Memory leakages checking with stack report (supports multithreading) 
* REQUIRE ACCERT( <a href='../lib/ext/debug/accert.f'>lib/ext/debug/accert.f</a> \\ Conditional compilation, suitable for debug checks
* REQUIRE TRACER <a href='../lib/ext/debug/tracer.f'>lib/ext/debug/tracer.f</a> \\ Detailed execution report

<a id="random"/>
### \\ Random numbers 
* REQUIRE RANDOM <a href='../lib/ext/rnd.f'>lib/ext/rnd.f</a> \\ linear congruent generator
* REQUIRE RANDOM <a href='../devel/~day/common/rnd.f'>~day/common/rnd.f</a> \\ linear congruent generator 
* REQUIRE RANDOM <a href='../devel/~af/lib/random.f'>~af/lib/random.f</a> \\ linear congruent generator
* REQUIRE RANDOM <a href='../devel/~nn/lib/ran4.f'>~nn/lib/ran4.f</a> \\ RAN4 
* REQUIRE GENRAND <a href='../devel/~ygrek/lib/neilbawd/mersenne.f'>~ygrek/lib/neilbawd/mersenne.f</a> \\ Mersenne twister - high-speed and quality RNG

<a id="hash"/>
### \\ Hashes
* REQUIRE new-hash <a href='../devel/~pinka/lib/hash-table.f'>~pinka/lib/hash-table.f</a> 
* REQUIRE ListAllocate <a href='../devel/~af/lib/simple_hash.f'>~af/lib/simple_hash.f</a> 
* REQUIRE HASH-TABLE <a href='../devel/~yz/lib/hash.f'>~yz/lib/hash.f</a> 

( Comparing speed in <a href='../devel/~pinka/samples/2003/test-hash/'>~pinka/samples/2003/test-hash/</a>)

* REQUIRE HASH <a href='../devel/~day/common/hash.f'>~day/common/hash.f</a> \\ hash counting procedure

<a id="hash-func"/>
### \\ Cryptographic hashes
* REQUIRE MD5 <a href='../devel/~clf/md5.f'>~clf/md5.f</a> 
* REQUIRE MD5 <a href='../devel/~clf/md5-ts.f'>~clf/md5-ts.f</a> \\ thread safe 
* REQUIRE SHAbuffer <a href='../devel/~nn/lib/security/SHA256.f'>~nn/lib/security/SHA256.f</a> 
* REQUIRE MD5 <a href='../lib/alg/md5-jz.f'>lib/alg/md5-jz.f</a> 

<a id="compiletime-const"/>
### \\ Compile-time constants
* REQUIRE LOAD-CONSTANTS <a href='../devel/~yz/lib/const.f'>~yz/lib/const.f</a> \\ including constants - the `W:` word searches the constant
* REQUIRE ADD-CONST-VOC <a href='../devel/~day/wincons/wc.f'>~day/wincons/wc.f</a> \\ including constants - redefining `NOTFOUND`
* REQUIRE BEGIN-CONST <a href='../devel/~day/wincons/compile.f'>~day/wincons/compile.f</a> \\ *.const files compiler
* \\ <a href='../devel/~day/wincons/h2f.f'>~day/wincons/h2f.f</a> \\ extracting Forth constants from C language header files
* \\ <a href='../devel/~yz/cons/'>~yz/cons/</a> \\ precompiled constants for sql, commctrl, windows 
* \\ <a href='../devel/~ygrek/lib/data/'>~ygrek/lib/data/</a> \\ farplugin, opengl 

<a id="WinGUI"/>
### \\ Windows GUI 
* REQUIRE WINDOWS... <a href='../devel/~yz/lib/winlib.f'>~yz/lib/winlib.f</a> \\ WinLib - Windows GUI interface library. Stretches forms and controls on it. Specifying controls position without coordinates, only position in grid - know-how! Good <a href='http://www.forth.org.ru/~yz/winlib.html'>documentation</a>. 
* REQUIRE FrameWindow <a href='../devel/~day/joop/win/'>~day/joop/win/framewindow.f</a> \\ windows library with joop 
* \\ <a href='../devel/~ac/lib/win/window/'>~ac/lib/win/window/</a> \\ simple and small implementation

<a id="WinCOM"/>
### \\ Windows COM 
* REQUIRE ComInit <a href='../devel/~ac/lib/win/com/com.f'>~ac/lib/win/com/com.f</a> \\ basic COM support
* REQUIRE Extends <a href='../devel/~ac/lib/win/com/com_server.f'>~ac/lib/win/com/com_server.f</a> \\ COM-server 

<a id="services"/>
### \\ System services
* REQUIRE CreateService <a href='../devel/~ac/lib/win/service/service.f'>~ac/lib/win/service/service.f</a> \\ NT services
* REQUIRE InstallService95 <a href='../devel/~ac/lib/win/service/service95.f'>~ac/lib/win/service/service95.f</a> \\ "services" for Win9x/ME 

<a id="datetime"/>
### \\ Date and time
* REQUIRE DateTime# <a href='../devel/~ac/lib/win/date/date-int.f'>~ac/lib/win/date/date-int.f</a> \\ date/time in different formats
* REQUIRE UNIXDATE <a href='../devel/~ac/lib/win/date/unixdate.f'>~ac/lib/win/date/unixdate.f</a> \\ Unixdate support
* REQUIRE FileDateTime# <a href='../devel/~ac/lib/win/file/filetime.f'>~ac/lib/win/file/filetime.f</a> \\ file date/time 
* REQUIRE parse-date? <a href='../devel/~ygrek/lib/spec/sdate.f'>~ygrek/lib/spec/sdate.f</a> \\ S" Tue, 19 Dec 2006 19:55:16 +0300" dates' parsing

<a id="db"/>
### \\ Databases
* REQUIRE StartSQL <a href='../devel/~yz/lib/odbc.f'>~yz/lib/odbc.f</a> \\ ODBC, typed data
* REQUIRE StartSQL <a href='../devel/~ac/lib/win/odbc/'>~ac/lib/win/odbc/odbc.f</a> \\ ODBC, all data as strings 
* REQUIRE ExecSQLTxt <a href='../devel/~pinka/lib/win/odbc/odbc-txt.f'>~pinka/lib/win/odbc/odbc-txt.f</a> \\ DELETE and UPDATE support for Text File Driver 
* REQUIRE db3_open <a href='../devel/~ac/lib/lin/sql/sqlite3.f'>~ac/lib/lin/sql/sqlite3.f</a> \\ SQLite 
* REQUIRE MyQuery <a href='../devel/~day/lib/mysql.f'>~day/lib/mysql.f</a> \\ MySQL wrapper 

<a id="threads"/>
### \\ Processes, threads and access rights
* \\ <a href='../devel/~ac/lib/win/process/'>~ac/lib/win/process/</a> 
* REQUIRE GetProcessACL <a href='../devel/~ac/lib/win/access/nt_access.f'>~ac/lib/win/access/nt_access.f</a> \\ access rights
* REQUIRE IsapiRunExtension <a href='../devel/~ac/lib/win/isapi/isapi.f'>~ac/lib/win/isapi/isapi.f</a> \\ support ISAPI-compatible extensions
* REQUIRE CREATE-CP <a href='../devel/~ac/lib/win/thread/pool.f'>~ac/lib/win/thread/pool.f</a> \\ thread-pool in Win200x 

<a id="ini-registry"/>
### \\ Windows registry and ini-files 
* REQUIRE RG_CreateKey <a href='../devel/~ac/lib/win/registry2.f'>~ac/lib/win/registry2.f</a> 
* REQUIRE IniFile@ <a href='../devel/~ac/lib/win/ini.f'>~ac/lib/win/ini.f</a> 

<a id="str"/>
### \\ Strings
* REQUIRE STR@ <a href='../devel/~ac/lib/str5.f'>~ac/lib/str5.f</a> \\ dynamic strings
* REQUIRE BNF <a href='../devel/~ac/lib/transl/BNF.f'>~ac/lib/transl/BNF.f</a> \\ basic BNF data types
* REQUIRE CHECK-SET <a href='../devel/~day/common/sbnf.f'>~day/common/sbnf.f</a> \\ simple BNF parser
* REQUIRE WildCMP-U <a href='../devel/~pinka/lib/mask.f'>~pinka/lib/mask.f</a> \\ comparing string and wildcard mask
* REQUIRE ULIKE <a href='../devel/~pinka/lib/like.f'>~pinka/lib/like.f</a> \\ comparing string and wildcard mask
* REQUIRE re_start <a href='../devel/~nn/lib/re.f'>~nn/lib/re.f</a> \\ regexps 
* REQUIRE PcreMatch <a href='../devel/~ac/lib/string/regexp.f'>~ac/lib/string/regexp.f</a> \\ PCRE wrapper 
* REQUIRE BregexpMatch <a href='../devel/~ac/lib/string/bregexp/bregexp.f'>~ac/lib/string/bregexp/bregexp.f</a> \\ bregexp.dll wrapper 
* REQUIRE debase64 <a href='../devel/~ac/lib/string/conv.f'>~ac/lib/string/conv.f</a> \\ base64, win-koi, urlencode etc. 
* REQUIRE UPPERCASE <a href='../devel/~ac/lib/string/uppercase.f'>~ac/lib/string/uppercase.f</a> \\ uppercase conversion
* REQUIRE COMPARE-U <a href='../devel/~ac/lib/string/compare-u.f'>~ac/lib/string/compare-u.f</a> \\ case-ignorant comparison
* REQUIRE GetParam <a href='../devel/~ac/lib/string/get_params.f'>~ac/lib/string/get_params.f</a> \\ URL-parameters string parser

<a id="files"/>
### \\ Files
* REQUIRE OPEN-FILE-SHARED-DELETE <a href='../devel/~ac/lib/win/file/share-delete.f'>~ac/lib/win/file/share-delete.f</a> \\ opening file with "light" shareable access
* REQUIRE LAY-PATH <a href='../devel/~pinka/samples/2005/lib/lay-path.f'>~pinka/samples/2005/lib/lay-path.f</a> \\ creation of path directories
* REQUIRE ATTACH <a href='../devel/~pinka/samples/2005/lib/append-file.f'>~pinka/samples/2005/lib/append-file.f</a> \\ appending string to file
* REQUIRE SPEAK-WITH <a href='../devel/~pinka/samples/2005/ext/tank.f'>~pinka/samples/2005/ext/tank.f</a> \\ controlling output stream, executing xt with output to file redirection 

### \\ Small simplifications
* REQUIRE CONST <a href='../devel/~micro/lib/const/const.f'>~micro/lib/const/const.f</a> \\ constants enumeration
* REQUIRE ENUM <a href='../devel/~ygrek/lib/enum.f'>~ygrek/lib/enum.f</a> \\ enumerating similar words

### \\ Big simplifications :) 
* REQUIRE DLOPEN <a href='../devel/~ac/lib/ns/dlopen.f'>~ac/lib/ns/dlopen.f</a> \\ unix-compatible way of loading WindowsDLL/UnixSO 
* \\ <a href='../devel/~ac/lib/ns/'>~ac/lib/ns/</a> \\ mapping external tree structures on forth wordlist
* REQUIRE XML\_READ\_DOC <a href='../devel/~ac/lib/lin/xml/xml.f'>~ac/lib/lin/xml/xml.f</a> \\ XML via LibXml2 
* REQUIRE XSLT <a href='../devel/~ac/lib/lin/xml/xslt.f'>~ac/lib/lin/xml/xslt.f</a> \\ XSLT via LinXslt 

<a id="oop"/>
### \\ OOP extensions
* REQUIRE CLASS: <a href='../devel/~day/joop/oop.f'>~day/joop/oop.f</a> \\ just oop with great pile of examples
* REQUIRE CLASS: <a href='../devel/~af/mc/microclass.f'>~af/mc/microclass.f</a> \\ microclass 
* REQUIRE CLASS: <a href='../devel/~day/mc/microclass.f'>~day/mc/microclass.f</a> \\ microclass 

<a id="vocs"/>
### \\ Vocabularies
* REQUIRE InVoc{ <a href='../devel/~ac/lib/transl/vocab.f'>~ac/lib/transl/vocab.f</a> \\ shortening vocabulary manipulations (MODULE: analogue) 
* REQUIRE ForEach <a href='../devel/~ac/lib/ns/iterators.f'>~ac/lib/ns/iterators.f</a> \\ iterators for context vocabularies
* REQUIRE ForEach-Word <a href='../devel/~pinka/lib/Words.f'>~pinka/lib/Words.f</a> \\ ForEach-Word 
* REQUIRE QuickSWL-Support <a href='../devel/~pinka/spf/quick-swl2.f'>~pinka/spf/quick-swl2.f</a> \\ Quick Search Wordlist (due to hashing) 

<a id="mem"/>
### \\ Memory
* REQUIRE STACK\_MEM <a href='../devel/~ac/lib/memory/mem_stack.f'>~ac/lib/memory/mem_stack.f</a> \\ "Stack"-way memory allocation
* REQUIRE LowMemory? <a href='../devel/~ac/lib/memory/low_memory.f'>~ac/lib/memory/low_memory.f</a> \\ Controlling extra memory consumption
* REQUIRE PAllocSupport <a href='../devel/~af/lib/pallocate.f'>~af/lib/pallocate.f</a> \\ Allocating memory in the global process space (shareable between threads) 
* REQUIRE LOCALLOC <a href='../devel/~mak/lalloc.f'>~mak/lalloc.f</a> \\ local array allocation (on the return stack) 
* REQUIRE ALLOCATE2 <a href='../devel/~pinka/spf/mem2.f'>~pinka/spf/mem2.f</a> \\ switching memory words for process and thread heap
* REQUIRE LoadDelphiMM <a href='../devel/~ss/lib/borlndmm.f'>~ss/lib/borlndmm.f</a> \\ Borland memory manager
* REQUIRE INIT-TASK-VALUES <a href='../devel/~ss/lib/task-values.f'>~ss/lib/task-values.f</a> \\ global thread variables 
* REQUIRE PROTECT-RETURN-STACK <a href='../devel/~ss/ext/stack-quard.f'>~ss/ext/stack-quard.f</a> \\ Protecting return stack from erasing with data stack
* REQUIRE GMEM <a href='../devel/~yz/lib/gmem.f'>~yz/lib/gmem.f</a> \\ Global memory shareable between threads