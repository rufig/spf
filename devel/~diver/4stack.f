( \ идея заимствована у Bernd Paysan { bernd.paysan@gmx.de }
_______версия 1.1.2______

попробуем сделать нечто вроде сопроцессора для организации параллельных 
вычислений - 4 стека с набором функций, плюс два набора регистров R N L {F}
как в процессоре {см. его документацию}

-> стек - куча последовательных байт в памяти пока - восемь ячеек, + указатель
на область памяти для быстрого сохранения
-> переходы, условия и прочее пока на совести форта
-> 
)
\ предполагаемая структура для управления этим безобразием
(
вообще - кол-во активных стеков, текущий стек;
для каждого стека - дно, указатель;
)

\ возможно будет полезно
.( loading multi stacks extention v1.01 ) CR

( for gforth capability define this...
: 2- 2 - ;
: CELL 4 ; : CELLS 4 * ;
: CELL- CELL - ; 
)

VOCABULARY 4xSTACK
USER StNum USER stack 	\ общее кол-во, текущий, глубина
USER Sp USER St	USER ssize	\ указатели, дно
USER RealS0 USER RealSP

256 ssize ! \ -глубина по умолчанию

\ _________управление

: -stacks ( N -- )	 	\ отвели памяти под стеки, запомнили адреса
				\ для операций с матрицами, когда каждый стек
				\ становится столбцом\строкой выделяется один
				\ большой кусок памяти
DUP StNum ! 4 CELLS * ALLOCATE THROW \ ." памяти взяли" \ addr
DUP St ! StNum @ CELLS + Sp !
ssize @ CELLS StNum @ * DUP ALLOCATE THROW CELL- +
StNum @ 0 ?DO
  DUP ssize @ CELLS I * - 
  DUP St @ I CELLS + ! Sp @ I CELLS + !
LOOP DROP
S0 @ RealS0 ! SP@ RealSP ! ;

: -stacks_diff ( xn ... x0 N -- ) 	\ отвели памяти под стеки, запомнили адреса
				\ для операций с матрицами, когда каждый стек
				\ становится столбцом\строкой выделяется один
				\ большой кусок памяти
DUP StNum ! 4 CELLS * ALLOCATE THROW \ ." памяти взяли" \ addr
DUP St ! StNum @ CELLS + Sp !
ssize @ CELLS StNum @ * DUP ALLOCATE THROW CELL- + \ последний занятый адрес
StNum @ 0 ?DO
  DUP ROT CELLS I * - 
  DUP St @ I CELLS + ! Sp @ I CELLS + !
LOOP DROP
S0 @ RealS0 ! SP@ RealSP ! ;

: :st ( n -- ) 		\ делаем текущим стек с заданным номером - переключение стеков
CELLS SP@ CELL+ stack @ Sp @ + ! \ ." запомнили текущий указатель " .S
DUP Sp @ + @ SWAP 	\ ." взяли указатель " .S
DUP St @ + @ 		\ ." взяли дно " .S 
SWAP stack !
S0 ! SP! ;

: :named_stack ( n -- ) \ создаем именованный стек, n его номер
CREATE ,
DOES> @ :st \ при исполнении переключает текущий стек
\ дальнейшие операции происходят на нем
;

: start_stacks		\ запустили систему: 0-й стек текущий.
SP@ S0 @ RealS0 ! RealSP ! 0 stack ! Sp @ @ St @ @ S0 ! SP! ;

: end_stacks		\ останов системы - но память не освобождается
			\ возврат на стек, который был
SP@ CELL+ stack @ Sp @ + !
RealSP @ RealS0 @ S0 ! SP! ;

: free_stacks		\ освобождает память после наших упражнений
St @ @ ssize @ CELLS StNum @ * CELL- - FREE THROW ;

\ _________операции с элементами стеков

: s@ ( n i - x )	\ n-ый элемент i-ого стека на вершину текущего
CELLS Sp @ + @ SWAP CELLS + @ ;

: s! ( x n i - )	\ запись n-го элемента i-ого стека с вершины текущего
CELLS Sp @ + @ SWAP CELLS + ! ;

	\ доступ к значениям стека как к массиву
	\ т.е. нумерация теперь со дна, проверки ест-но никакой

: []@ ( n i - x )	\ получаем n-ый элемент со дна i-го стека
CELLS St @ + @ SWAP 1+ CELLS - @ ;

: []! ( x n i -  )	\ записываем n-ый элемент со дна i-го стека
CELLS St @ + @ SWAP 1+ CELLS - ! ;

: PIN ( xn ... x0 -- x0 xn ... x1 ) \ вершину стека перемещает на дно
DUP SP@ DUP CELL- DEPTH 2- CELLS CMOVE S0 @ CELL- ! ;

\ PREVIOUS

\ ALSO FORTH DEFINITIONS

\ PREVIOUS FORTH DEFINITIONS