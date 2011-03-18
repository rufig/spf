\ Name: vararr.f
\ "Работа в Variant-массивами"
\ Примочка для Automate.f (c) ~yz 
\ Абдрахимов И.А. ilya@forth.org.ru
\ v1.0 - 14.07.2005г.
\ v1.1 - 17.07.2005г.



WINAPI: SafeArrayGetElement OLEAUT32.DLL
WINAPI: SafeArrayGetDim OLEAUT32.DLL
WINAPI: SafeArrayGetElemsize OLEAUT32.DLL
WINAPI: SafeArrayGetIID OLEAUT32.DLL
WINAPI: SafeArrayGetVartype OLEAUT32.DLL
WINAPI: SafeArrayCreateVector OLEAUT32.DLL
WINAPI: SafeArrayCreate   OLEAUT32.DLL
WINAPI: SafeArrayCopy   OLEAUT32.DLL
WINAPI: SafeArrayCopyData   OLEAUT32.DLL
WINAPI: SafeArrayDestroy   OLEAUT32.DLL
WINAPI: SafeArrayGetLBound   OLEAUT32.DLL
WINAPI: SafeArrayGetUBound   OLEAUT32.DLL
WINAPI: SafeArrayAccessData   OLEAUT32.DLL
WINAPI: SafeArrayUnaccessData   OLEAUT32.DLL


0
CELL -- cElements
CELL -- lLbound
CONSTANT /SAFEARRAYBOUND

0
2 -- cDims
2 -- fFeatures
2 -- cbElements
2 -- cLocks
CELL -- handle
4 -- pvData
CELL -- rgsabound
CONSTANT /SAFEARRAY


CREATE SAFEARRAYBOUND /SAFEARRAYBOUND 10 * ALLOT

VARIABLE psa			\ дескриптор SAFEARRAY массива
VARIABLE c_arr			\ укзатель на массив в "С++" формате
VARIABLE colMax			\ кол-во столбцов в массиве
VARIABLE rowMax			\ кол-во строк в массиве
VARIABLE varrType		\ тип массива

: create-arr SafeArrayCreate DUP 0= ABORT" Not Create Array !" ;
: destroy-arr SafeArrayDestroy  ABORT" Not Destroy Array !" ;

: copy-arr ( psaOut psa -- ) SafeArrayCopy ABORT" Not Copy Array !" ;

\ Получаем доступ к данным (в формате C++) из массива адресованного psa
: acc-arr ( psa -- ) c_arr SWAP SafeArrayAccessData ABORT" Not Access Array !" ;
\ Закрываем доступ к данным (в формате C++) из массива адресованного psa
: unacc-arr ( psa -- ) SafeArrayUnaccessData ABORT" Not Unaccess Array !" ;

\ Получаем количество строк и столбцов в массиве
: get-range
	rowMax 1 psa @ SafeArrayGetUBound DROP
	colMax 2 psa @ SafeArrayGetUBound DROP
;

\ Проверка на допустимость индексов
: check-index ( row col -- )
	get-range
	OVER colMax @ 1- > IF ABORT" Column Index Out of Range !" THEN
	DUP rowMax @ 1- > IF  ABORT" Row Index Out of Range !" THEN
;

\ Получить n-й элемент из 2-х мерного массива (в формате C++) 
: _getel-arr ( n - value/dvalue type )
	4 CELLS * c_arr @ +
	variant@ 
;

\ Получить элемент адресованный row,col из 2-х мерного массива (в формате C++)
: getel-arr ( col row -- value/dvalue type) \ { \ rowMax colMax -- }
	check-index
	SWAP rowMax @ * +  _getel-arr
;

\ Поместить в массив n-й элемент
: _putel-arr
	4 CELLS * c_arr @ +
	variant!
;

\ Поместить элемент адресованный row,col в 2-х мерный массив (в формате C++)
: putel-arr ( value/dvalue type col row -- ) \ { \ rowMax colMax -- }
	check-index
	SWAP rowMax @ * +  _putel-arr
;

: _ARR-SAVE { \ psain -- }
@ DUP TO psain 
		\ Создаём новый (пустой) массив с размером и типом входящего массива
		SafeArrayGetDim DUP CR ." DIM=" .H
		psain W@ .H
		\ tmp 1 psain SafeArrayGetUBound 0= IF CR ." UBound=" tmp @ . THEN
		\ tmp 2 psain SafeArrayGetUBound 0= IF CR ." UBound=" tmp @ . THEN
		0 SAFEARRAYBOUND cElements !
		SAFEARRAYBOUND SWAP
		varrType psain SafeArrayGetVartype DROP varrType @ CR ." =>" .S ." <=" create-arr psa ! 
		\ Копируем входящий массив во вновь созданный
		psa psain copy-arr
		psa @	\ на выходе отдаём указатель на дескриптор массива
;
' _ARR-SAVE TO ARR-SAVE