\ 20-06-2005 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com 
\ переключатели

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

\ Необходимость появилось при работе с линуксевой версией СПФ при обращении 
\ к портам. В линуксе сначала нужно выполнить операцию ioperm, и лишь за тем 
\ ( если конечно доступ получен ) можно писать в порт или читать из него. 
\ В данном случае об ioperm можно забыть. Идею можно использовать везде, 
\ где сначала нужно что-то инициализировать а затем с этим работать. 
\ Например так можно поступать с файлами.
