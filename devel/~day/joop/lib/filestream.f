\ Скелет для дргугих потоков - sockets, buffered files, com ports...
\ Вот только :copyFrom надо доделать

REQUIRE Stream ~day\joop\lib\stream.f

pvar: <handle

CLASS: HandleStream <SUPER Stream

	CELL VAR handle

: :create ( handle --)
    handle !
;
: :read ( buffer count -- u)
    handle @ READ-FILE THROW 
;
: :seek ( u --)
    DROP handle @ REPOSITION-FILE THROW
;
: :setSize ( u --)
    DROP RESIZE-FILE THROW
;
: :write ( buffer count --)
    handle @ WRITE-FILE THROW
;

: :free
    handle @ CLOSE-FILE THROW
;

;CLASS

CLASS: FileStream <SUPER HandleStream

: :create ( c-addr u mode)
    CREATE-FILE THROW handle !
;
: :open ( c-addr u mode)
    OPEN-FILE THROW handle !
;

;CLASS

<< :create
<< :setSize
<< :open