REQUIRE F.        lib/include/float.f
REQUIRE STRUCT:   lib/ext/struct.f
REQUIRE {         lib/ext/locals.f  
REQUIRE .S        lib/include/tools.f

FLONG

\ PRINT-EXP
\ 5 SET-PRECISION

0 VALUE MPtr
0 VALUE MdimX
0 VALUE MdimY
0 VALUE Mx
0 VALUE My
0 VALUE Mxt
0 VALUE _TempMatrix

STRUCT: matrix
CELL -- data
CELL -- dimX 
CELL -- dimY
;STRUCT

: GETMEM ALLOCATE THROW ; : FREEMEM FREE THROW ;

: dim! ( x y ^matrix -- )
   TUCK
     matrix::dimY !
     matrix::dimX !
;
: .dimX ( ^m -- x ) matrix::dimX @ ;
: .dimY ( ^m -- x ) matrix::dimY @ ;
: Msize ( ^matrix -- x*y )
  >R R@ .dimX 
     R> .dimY *
;
: MXY ( ^m x y -- addr )
  ROT >R 
   R@ .dimX * + 10 *
   R> matrix::data @ +
;
: MXY@ MXY F@ ; : MXY! MXY F! ;
: Matrix ( x y -- ^matrix)
    matrix::/SIZE GETMEM >R
    R@ dim!
    R@ Msize 10 * GETMEM R@ matrix::data !
    R>
;
: 0Matrix 0 0 Matrix ;
: ?Empty ( addr -- addr )
 ( проверить не ноль ли содержимое адреса и если таки да то освободить)
    DUP @ ?DUP 0<> IF FREEMEM THEN ;
: TempMatrix ( x y -- ^matrix)
    matrix::/SIZE GETMEM >R
    R@ dim!
    R@ Msize 10 * GETMEM R@ matrix::data !
    _TempMatrix ?DUP 0<> IF DUP matrix::data ?Empty DROP FREEMEM THEN
    R> DUP TO _TempMatrix
;
: KillMatrix ( ^matrix -- )
   DUP matrix::data ?Empty DROP
       FREE THROW
;
: ReMatrix ( x y m1 -- )
   >R
   R@ dim!
   R@ Msize 10 * GETMEM R@ matrix::data ?Empty !
   RDROP
;
: READ-WORD ( fileid -- addr u )
( считать с файла слово ограниченное символами с кодами меньше BL
  в конце файла ситуация не определена

)
   >R 64 GETMEM DUP
   BEGIN
    DUP 1 R@ READ-FILE THROW
             0= 
    OVER C@ BL > 
    OR
   UNTIL
   \ DROP DUP
   BEGIN
    DUP C@ BL > IF 1+ THEN
    DUP 1 R@ READ-FILE THROW
    0= IF RDROP OVER - EXIT THEN
    DUP C@ BL 1+ < IF RDROP OVER - EXIT THEN
   AGAIN
;

: LoadMatrix ( addr u ^matrix -- )
   >R 
   R/O OPEN-FILE THROW 
   DUP READ-WORD EVALUATE
   OVER READ-WORD EVALUATE 
   R@ dim!
   R@ Msize 10 * ALLOCATE THROW R@ matrix::data ?Empty !
   R@ matrix::data @ 
   R> Msize 0 ?DO ( fileid addr )
    OVER READ-WORD 2DUP
    DEPTH 2- >R
    EVALUATE ( должно запихнуть на флоатский стек)
    DEPTH R> <> ABORT" Matrix: Need floating point numbers in file"
    DROP FREE THROW ( убили строку)
    DUP F! 10 +
   LOOP
   DROP CLOSE-FILE THROW
;
: MCopy ( ^m1 ^m2 -- )( скопировать матрицу 1 в матрицу 2
                     если 2 не пусто то очистить)
   >R
   DUP Msize 10 * ALLOCATE THROW R@ matrix::data ?Empty ! 
   DUP .dimX R@ matrix::dimX !
   DUP .dimY R@ matrix::dimY !
   DUP Msize 10 *
   SWAP matrix::data @
   R> matrix:: data @
   ROT CMOVE
;
: TempCopy ( ^m1 -- temp ) _TempMatrix MCopy _TempMatrix ;
: VNorma ( ^vector -- F: norma ) \ Норма вектора
   DUP .dimX 1 <> ABORT" Matrix: Can't calculate norma"
   0e
   DUP .dimY 0 DO
   DUP 0 I MXY@ FDUP F* F+
   LOOP
   DROP
   FSQRT
;
: VNorma/ ( ^vector -- ) \ Нормировать вектор
  DUP VNorma
  DUP .dimY 0 DO
  DUP 0 I MXY@ FOVER F/ DUP 0 I MXY! 
  LOOP
  DROP FDROP
;
: MM* { m1 m2 \ cnt -- m3 } 
 ( перемножить две матрицы - результат в m3
   причём m3 временная если нужна дальше то скопируйте)

   m2 .dimY m1 .dimX <> ABORT" Matrix: Can't multiply matrices"
   m2 .dimX m1 .dimY TempMatrix DROP
   m1 .dimY 0 DO
    m2 .dimX 0 DO
     0e
     0 TO cnt
      BEGIN
       m1 cnt J MXY@ 
       m2 I cnt MXY@ F* F+
        cnt 1+ TO cnt 
        cnt m1 .dimX =
      UNTIL
     _TempMatrix I J MXY! 
    LOOP
   LOOP
   _TempMatrix
;
: MM+
 { m1 m2 \ cnt -- } 
 ( перемножить две матрицы - результат в m1 )

   m2 .dimY m1 .dimY <> 
   m2 .dimX m1 .dimX <>
           OR ABORT" Matrix: Can't add matrices"
   m1 .dimY 0 DO
    m1 .dimX 0 DO
      m1 I J MXY@ m2 I J MXY@ F+ m1 I J MXY!
    LOOP
   LOOP
;

: MApply ( xt ^m1 -- )
   >R 
    R@ matrix::data @ TO MPtr
    R@ matrix::dimY @ TO MdimY
    R> matrix::dimX @ TO MdimX
   TO Mxt
    MdimY 0 ?DO
     I TO My
      MdimX 0 ?DO
       I TO Mx
      MPtr F@ Mxt EXECUTE
      MPtr 10 + TO MPtr
     LOOP
    LOOP
;
: MatrixWord ( xt1 xt2 --
               xt1 to execute on each element,
               xt2 to execute at the end. 
               xt1 will be called with matrix element on the float stack
               and Mx,My current coordinates in matrix
               MPtr pointer to the current element 
               MDimX MDimY dimensions of the current matrix )
             CREATE , ,
             DOES> >R 
                   R@ CELL+ @ SWAP MApply 
                   R> @ EXECUTE ;

      :NONAME F. SPACE Mx MdimX 1- = IF CR THEN ; 
      :NONAME CR ;
 MatrixWord MPrint
      :NONAME FOVER F* MPtr F! ;
      :NONAME FDROP ;
 MatrixWord MConst* 
      :NONAME FDROP Mx My = IF 1e ELSE 0e THEN MPtr F! ;
      :NONAME ;
 MatrixWord IdMatrix

( 10 10 Matrix VALUE a
10 10 Matrix VALUE b

a b MCopy 
S" data.dat" a LoadMatrix
S" data2.dat" b LoadMatrix
b a MM* MPrint
a MPrint
b MPrint
10e a MConst* 
a MPrint
)
