\ Разборки с потоками
\ Stream абстракный класс - не создавать, только наследовать!

REQUIRE Object ~day\joop\oop.f
REQUIRE { lib\ext\locals.f

pvar: <position
pvar: <size

4096 CONSTANT COPY_BUFFER

CLASS: Stream <SUPER Object

	CELL VAR position
	CELL VAR size


x: :new ;

x: :copyFrom { source count -- u }
;
x: :read ( buffer count -- u )
;
x: :readBuffer ( buffer count)
;
x: :seek ( offset origin -- u)
;
x: :write ( buffer count -- u)
;
x: :writeBuffer ( buffer count)
;

;CLASS

<< :copyFrom
<< :read
<< :seek
<< :write
<< :writeBuffer