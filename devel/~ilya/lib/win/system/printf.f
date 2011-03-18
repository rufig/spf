\ Враппер для sprintf 
\ Абдрахимов И.А.
\ 15.11.05г.

USER-VALUE _sp

WINAPI: sprintf MSVCRT.DLL 

\ Берём из float-стека число
: F>ST 0. SP@ DF! ;

\ Форматируем данные в C стиле
\ Где: 	i*x - данные на стеке данных
\		adr - форматная Z- строка вида " %s%8.2f"
: printf  ( i*x adr -- c-adr n )
		PAD sprintf DUP 0 < THROW 
		>R 
		_sp SP!
		R>
	PAD SWAP ;
: ]> DROP printf ;

: printf<[ 
SP@ TO _sp
;

\EOF
\ Пример
printf<[ 12.0345e F>ST S" stroka" DROP 333 S" Number:%d String:%s Float:%f" ]> CR TYPE


