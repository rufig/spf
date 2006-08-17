REQUIRE ON ~micro/lib/onoff.f

VARIABLE RunSamples RunSamples OFF

: COMMENT>
  BEGIN
    REFILL
  0= UNTIL
  0 #TIB !
;

: SAMPLES>
  RunSamples @ 0= IF
    COMMENT>
  THEN
;

SAMPLES>

.( Sample!!!!!!!!!!!!)

COMMENT>

Комментирующие слова

VARIABLE RunSamples
SAMPLES> если RunSamples = FALSE, то прекращаем интерпретировать
COMMENT> прекращаем интерпретировать
