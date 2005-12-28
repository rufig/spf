( Модель полёта ракеты
  v' = [T-0.5*c*ro*S*v*v-m'*v]/m - g*sin[Teta]
  Teta' = -g*cos[Teta]/v
  x'=v*cos[Teta]
  y'=v*sin[Teta]
)
REQUIRE F. lib/include/float2.f
REQUIRE RungeKutta  ~ygrek/lib/difur.f

VOCABULARY Model2
ALSO Model2 DEFINITIONS

1e2 FVALUE show_time

0.25e FVALUE S \ площадь сечения
 0.7e FVALUE Teta \ начальный угол взлёта
1.29e FVALUE ro \ сопротивление воздуха ?
9.83e FVALUE g \ ускорение земного притяжения
 0.2e FVALUE c \ коэфициент формы

0.001e FVALUE v0 \ начальная скорость - ноль (для модели надо епсилон)
500e FVALUE m0  \ начальная масса ракеты
250e FVALUE mf  \ масса ракеты без топлива
0.5e FVALUE tf \ время сгорания топлива
3e5 FVALUE T0 \ стартовая тяга

\ перемнные диференцирования
( 0e FVALUE vn \ скорость
0e FVALUE Tn \ угол
0e FVALUE xn \ дальность
0e FVALUE yn \ высота

0e FVALUE x0 0e FVALUE xmax
0e FVALUE y0 0e FVALUE ymax
0e FVALUE vEnd 0e FVALUE TEnd 0e FVALUE tEnd
)

floats 
 vn Tn 
 xn x0 xmax 
 yn y0 ymax 
 vEnd TEnd tEnd
 ;


: zxc 1e  tn tf F/ F- 0e FMAX ;
\ Параметры меняющиеся во времени по известным законам
: TT zxc T0 F* ; \ тяга 
: m  zxc m0 F* mf F+ ; \ масса
: m' tn tf F- F0< IF m0 tf F/ FNEGATE ELSE 0e THEN ; \ масса по времени
   

\ v' = [T-0.5*c*ro*S*v*v-m'*v]/m - g*sin[Teta]
: func_v ( tn vn -- f )
 FSWAP FDROP 
 FDUP F* S F* ro F* c F*
 -0.5e F* 
 TT F+
 m' vn F* F-
 m F/
 g Tn FSIN F* F-
;

\  Teta' = -g*cos[Teta]/v
: func_T ( tn Tn -- f )
  FSWAP FDROP
  FCOS g F* vn F/ FNEGATE 
;

\  x'=v*cos[Teta]
: func_x ( tn xn -- f)
 FDROP FDROP
 Tn FCOS vn F*
;
\  y'=v*sin[Teta]
: func_y ( tn yn -- f)
 FDROP FDROP
 Tn FSIN vn F*
;

: solution FDROP 0e ;
: init
   0.01e FTO step
   show_time FTO interval
   0e FTO tn 
   x0 FDUP FTO xn FTO xmax
   y0 FDUP FTO yn FTO ymax
   Teta FTO Tn
   v0 FTO vn
   0e FTO err-norma 
; 

: prepareRK
 ['] init TO difur-init
 ['] solution TO difur-solution
 difur-init
;

: runRK
  yn -0.01e F< 
  IF 
   -0.02e FTO yn 0.01e FTO vn 
  ELSE
   yn FTO fn ['] func_y TO difur-func RungeKutta FTO yn
   xn FTO fn ['] func_x TO difur-func RungeKutta FTO xn 
   0.05e tn F< IF \ Влияние на угол только через некоторое время
                  \ физическая аналогия - ствол пусковой шахты.
                  \ Иначе просто не полетит
     Tn FTO fn ['] func_T TO difur-func RungeKutta FTO Tn
    THEN
   vn FTO fn ['] func_v TO difur-func RungeKutta FTO vn

  tn FTO tEnd
  Tn FTO TEnd
  vn FTO vEnd
  THEN 

  xmax xn F< IF xn FTO xmax THEN
  ymax yn F< IF yn FTO ymax THEN

  tn step F+ FTO tn
;

ONLY FORTH DEFINITIONS

\EOF
4 FFORM !
ALSO Model2
: a
  prepareRK
  10 0 DO
  I . ." ) "
  ." tn : " tn F. SPACE 
  ." xn : " xn F. SPACE
  ." yn : " yn F. SPACE
  ." vn : " vn F. SPACE
  ." Tn : " Tn F. CR
   runRK
  LOOP
;


