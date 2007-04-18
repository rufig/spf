\ $Id$
\ Квантиль нормального распределения
\ http://algolist.manual.ru/maths/matstat/normal/index.php

REQUIRE 0e lib/include/float2.f
REQUIRE ENSURE ~ygrek/lib/debug/ensure.f
REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE { lib/ext/locals.f

[UNDEFINED] F> [IF] : F> FSWAP F< ; [THEN]

0 [IF]
/* Вычисляется квантиль уровня level,
 * который, согласно определению, является корнем уравнения
 *      N(x) = level,
 * где N(x) - стандартное нормальное распределение.
 * Решение уклоняется от точного значения не более, чем на 0.00045.
 * Конечно, значение level должно быть заключено между 0 и 1.
 */
[THEN]
: inv_normalDF ( F: level -- F: q )
   { | [ 4 ] level [ 4 ] t }
   FDUP 0e F> ENSURE
   FDUP 1e F< ENSURE

   level SF!
   0.5e level SF@ F< IF 1e level SF@ F- ELSE level SF@ THEN
   FLN -2e F* FSQRT t SF!
   
   0.010328e t SF@ F* 0.802853e F+ t SF@ F* 2.515517e F+
   0.001308e t SF@ F* 0.189269e F+ t SF@ F* 1.432788e F+ t SF@ F* 1e F+ F/
   t SF@ FSWAP F-

   level SF@ 0.5e F< IF FNEGATE THEN
;

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES inv_normalDF

  0.00045e FVALUE eps

  (( 0.95e inv_normalDF 1.6452e F- FABS eps F< -> TRUE ))
  (( 0.99e inv_normalDF 2.3267e F- FABS eps F< -> TRUE ))

END-TESTCASES
