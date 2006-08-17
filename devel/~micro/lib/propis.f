: nSTR
( 0 addr u -- addr u -1 )
( n addr u -- n-1 )
	ROT DUP IF
		NIP NIP
	THEN
	1- ;

MODULE: Propis

\ genders

0 CONSTANT neuter
1 CONSTANT male
2 CONSTANT female

: trans-0-9-male ( n -- addr u )
	S" ноль" nSTR
	S" один" nSTR
	S" два" nSTR
	S" три" nSTR
	S" четыре" nSTR
	S" пять" nSTR
	S" шесть" nSTR
	S" семь" nSTR
	S" восемь" nSTR
	S" девять" nSTR
	DROP
;

: trans-0-9-female ( n -- addr u )
	DUP 1 = OVER 2 = OR IF
		1-
		S" одна" nSTR
		S" две" nSTR
		DROP
	ELSE
		trans-0-9-male
	THEN ;

: trans-0-9-neuter ( n -- addr u )
	DUP 1 = IF
		DROP
		S" одно"
	ELSE
		trans-0-9-male
	THEN ;

: trans-0-9 ( n gender -- addr u )
	DUP male = IF
		DROP trans-0-9-male
	ELSE
		female = IF
			trans-0-9-female
		ELSE
			trans-0-9-neuter
		THEN
	THEN ;

: trans-10-19-any ( n -- addr u )
	10 -
	S" десять" nSTR
	S" одиннадцать" nSTR
	S" двенадцать" nSTR
	S" тринадцать" nSTR
	S" четырнадцать" nSTR
	S" пятнадцать" nSTR
	S" шестнадцать" nSTR
	S" семнадцать" nSTR
	S" восемнадцать" nSTR
	S" девятнадцать" nSTR
	DROP
;

: trans-tens-2-9-any ( n -- addr u )
	2 -
	S" двадцать" nSTR
	S" тридцать" nSTR
	S" сорок" nSTR
	S" пятьдесят" nSTR
	S" шестьдесят" nSTR
	S" семьдесят" nSTR
	S" восемьдесят" nSTR
	S" девяносто" nSTR
	DROP
;

: #trans-0-9
	trans-0-9 HOLDS ;

: #try-trans-less-number-by ( n genre max xt -- n1 )
	>R
	SWAP >R
	/MOD SWAP ( n/max n_mod_max )
	DUP IF
		R> R> EXECUTE
		BL HOLD
	ELSE
		DROP RDROP RDROP
	THEN
;

: #trans-0-99 ( n gender -- )
	OVER 10 < IF
		trans-0-9 HOLDS
	ELSE
		OVER 20 < IF
			DROP trans-10-19-any HOLDS
		ELSE
			10 ['] #trans-0-9 #try-trans-less-number-by
			trans-tens-2-9-any HOLDS
		THEN
	THEN
;

: trans-hundreds-1-9-any ( n -- addr u )
	1-
	S" сто" nSTR
	S" двести" nSTR
	S" триста" nSTR
	S" четыреста" nSTR
	S" пятьсот" nSTR
	S" шестьсот" nSTR
	S" семьсот" nSTR
	S" восемсот" nSTR
	S" девятьсот" nSTR
	DROP
;	

: #trans-0-999 ( n genre -- )
	OVER 100 < IF
		#trans-0-99
    ELSE
    	100 ['] #trans-0-99 #try-trans-less-number-by
    	trans-hundreds-1-9-any HOLDS
    THEN
;

: number-of ( n -- 0 | 1 | 2 )
	DUP 10 / 10 MOD 1 = IF
		DROP 0
	ELSE
		10 MOD
		DUP 0= IF
			DROP 0
		ELSE
			DUP 1 = IF
				DROP 1
			ELSE
				5 < IF
					2
			    ELSE
			    	0
			    THEN
			THEN
		THEN
	THEN
;

: #trans-million ( n genre -- )
	OVER 1000 < IF
		#trans-0-999
	ELSE
		1000 ['] #trans-0-999 #try-trans-less-number-by
		DUP number-of
			S" тысяч" nSTR
			S" тысяча" nSTR
			S" тысячи" nSTR
			DROP
		HOLDS
		BL HOLD
		female #trans-0-999
	THEN
;

: #trans-billion ( n genre -- )
	OVER 1000000 < IF
		#trans-million
	ELSE
		1000000 ['] #trans-million #try-trans-less-number-by
		DUP number-of
			S" миллионов" nSTR
			S" миллион" nSTR
			S" миллиона" nSTR
			DROP
		HOLDS
		BL HOLD
		male #trans-0-999 
	THEN
;

\ максимальное 32битное число 2147483647
\ 2 147 483 647
\    |   |
\    |   тысяч
\    миллионов

\ максимальное 64битное число 9223372036854775807
\ 9 223 372 036 854 775 807
\    |   |   |   |   |
\    |   |   |   |   тысяч
\    |   |   |   миллионов
\    |   |   миллиардов
\    |   триллионов
\    квадриллионов

: mlrd-UM/MOD ( d n -- quotient remainder[d] )
	>R
	1000000000 UM/MOD ( d_mod_mlrd d/mlrd )
	R> /MOD SWAP ( d_mod_mlrd [d/mlrd]_mod_n [d/mlrd]/n )
	ROT S>D ( [d/mlrd]/n [d/mlrd]_mod_n d_mod_mlrd[d] )
	ROT 1000000000 UM*
	D+
;

: #D-try-trans-less-number-by ( d gender max-mlrds xt -- n1 )
	>R
	SWAP >R
	mlrd-UM/MOD
	2DUP OR IF
		R> R> EXECUTE
		BL HOLD
	ELSE
		2DROP RDROP RDROP
	THEN
;

: #D-trans-billion ( d genre -- )
	>R D>S R> #trans-billion
;

: D-number-of ( d -- 0 | 1 | 2 )
	1000000000 UM/MOD DROP number-of
;

: #trans-trillion ( d genre -- )
	>R
	2DUP 1000000000. D< IF
		D>S R> #trans-billion
	ELSE
		R> 1 ['] #D-trans-billion #D-try-trans-less-number-by
		DUP number-of
			S" миллиардов" nSTR
			S" миллиард" nSTR
			S" миллиарда" nSTR
			DROP
		HOLDS
		BL HOLD
		male #trans-0-999
	THEN 
;

: #trans-quadrillion ( d genre -- )
	>R
	2DUP 1000000000000. D< IF
		R> #trans-trillion
	ELSE
		R> 1000 ['] #trans-trillion #D-try-trans-less-number-by
		DUP number-of
			S" триллионов" nSTR
			S" триллион" nSTR
			S" триллиона" nSTR
			DROP
	    HOLDS
	    BL HOLD
	    male #trans-0-999
	THEN
;

: #trans ( d genre -- )
	>R
	2DUP 1000000000000000. D< IF
		R> #trans-quadrillion
	ELSE
		R> 1000000 ['] #trans-quadrillion #D-try-trans-less-number-by
		DUP number-of
			S" квадриллионов" nSTR
			S" квадриллион" nSTR
			S" квадриллиона" nSTR
			DROP
	    HOLDS
	    BL HOLD
	    male #trans-0-999
	THEN
;

;MODULE

\ \EOF

\ на P100:
\ число                 переводов в секунду
\ 999999999999999999     4000
\ 100000000000000000    45000
\                  1   166000

ALSO Propis

: q
	1000000 0 DO
		I 1000000000 UM* I S>D D+ I 35846 UM* D+
		2DUP D.
		2DUP <# female #trans 0. #> TYPE ."  "
		D-number-of
			S" белых ворон" nSTR
			S" белая ворона" nSTR
			S" белые вороны" nSTR
			DROP
		TYPE CR
		KEY DROP
	LOOP
;

