\ 20-06-2005 переключатели

\ первое слово должно быть исполнено только один первый раз
: (sw) 0 , , ,
       DOES> DUP @ IF		     CELL+
		     ELSE -1 OVER !  2 CELLS +
		   THEN
	     @ EXECUTE ;

: switch ( 'a 'b | name --> ) CREATE (sw) ;

: switch: ( | name init work --> ) CREATE ' ' (sw) ;

\ EOF

: init ." первый проход " ;
: work ." выполнение " ;

switch: proba init work
' init ' work switch test

\ увы TO в СПФ не работает. Пока обойдусь без него.

\EOF

    'a 'b switch name
    or
	  switch: name a b

      0 To name
      x To name


	: init ( n port --> ) DUP 1 ioperm THROW PutByte ;

	switch: send init PutByte

       n send  в первый раз вызовет ioprem,
	       во второй раз PutByte