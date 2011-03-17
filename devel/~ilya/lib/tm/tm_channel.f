\ Константы для работы с HIP-ами
\ S" lib/include/float2.f" INCLUDED
S" ~af/lib/c/define.f" INCLUDED
1e0 32767e0 F/ FCONSTANT NETRSKOF \ (1./32767.)

#define TRMIN 30
#define TRMAX 0x8000

#define LTRTEMP 109  \ длина приемника
#define LRSTEMP 72   \ длина передатчика

#define VERTMP   0   \ версия ПО создавшего шаблон
#define DATETMP  1	\ дата создания шаблона
#define SINTTMP  2	\ частота синтеза
#define FMIDDLE  3   \ средняя частота
#define DEVITMP  4	\	девиация
#define SPIDMODE 5   \ скорость модуляции

#define OTSLEVE  0
#define MINOTS   0
#define MAXOTS   0
#define ATOTS    0
#define KOFOTS   0


#define NPARZAP 31  \ число параметров для приемо-передатчика

#define VERSOFT 0
#define LONGFILE 1
#define KOFTR 2
#define BITMOL 3
#define DIGMOD 4
#define REJOTS 5
#define YROTS 6
#define KOFRS 7
#define INVTR 8
#define INVRS 9
#define KTXCOD 10
#define KRXCOD 11

#define DATEPROG5 18
#define MNSIN5 20
#define MYFRIC5 21

#define DATEPROG6 26
#define MNSIN6 28
#define MYFRIC6 29

#define ATTADC5 24
#define ATTADC6 30

\ команды контроллеру
\ существующие:
#define TRSYMBOL 	0  \ передать очередной символ
#define TRSTOP 		1  \ остановить передачу
#define TRSTART 	2  \ начать передачу
#define TRLOAD 		3  \ загрузить новый передатчик
#define DACOUT 		4  \ изменить множитель выхода передатчика
#define TRATTEN 	5  \ изменить аттенюатор DAC
#define TRLSYM 		6  \ изменить длинну передаваемого слова

#define RSSTART         8  \ разрешить прием
#define RSSTOP          9  \ запретить прием
#define RSLOAD          10 \ загрузить новый приемник
#define RSSYN		11 \ новый синхросимвол для приемника
#define RSLSYM          12 \ новая длинна для принимаемого слова
#define RSATTEN 	16 \ изменить аттенюатор ADC
#define RSDM            17 \ установить режим цифрового приема-предатчика
#define TRSCRB          18 \ режим заполнения паузы передатчика включен

#define RSMASK          20 \ изменить маску синхросимвола
#define CNKPRS 		21 \ изменить текущую контрольную точку
#define ZAPROS		23 \ послать запрос в HIP
#define TRKOFC          24 \ новый коэф. связи для передатчика
#define RSKOFC          25 \ новый коэф. связи для приемника
#define NULLLEV         26 \ очистить min max уровень
#define OTSTIP		28 \ установить тип отсечки
#define OTSLEV		29 \ установить уровень отсечки
#define TRSNRATIO 	30 \ изменить амплитуду генератора шума
#define RSTRECEIVE	45 \ рестарт загруженного приемника
#define RSTTRANSMIT	46 \ рестарт загруженного передатчика
#define ChangeChan      40 \ изменить текущий канал связи
#define SETDATA 53 \ установить дату программирования
#define CMYFRIC 54 \ установить собственную частоту
#define CINVTR  43 \ установить инверсию передатчика
#define CINVRS  44 \ установить инверсию приемника
#define MTXCOD  55 \ установить усиление ДК из линии
#define MRXCOD  56 \ установить усиление ДК в линию
#define PUTNCHAN  58 \ установить номер текущего канала


\ коды HIP запросов
#define RSLEV 		 0 \ запрос уровня приема
#define TIPOTS           1 \ запрос на тип отсечки канала связи
#define RSKOFSV          2 \ запрос на коэф. связи приемника
#define RSKOFAT		 3 \ запрос на аттенюатор ADC
#define OTSVOL		 4 \ запрос на величину отсечки
#define NMINLEV		 5 \ дать мин. значение уровня
#define NMAXLEV		 6 \ дать мах. значение уровня
#define GETSOSTC         7 \ дать текущее состояние канала связи

#define TRTekSost        8 \ Выдать текущее состояние передатчика
#define RsCRC            9 \ Выдать текущее состояние CRC приемника
#define TrCRC           10 \ Выдать текущее состояние CRC передатчика
#define SAVEOPT		11 \ сохранить текущие настройки параметров
#define inKoffTr        12 \ выдать текущий коэффициент связи передатчика
#define inUrTr          13 \ выдать масштаб уровня генератора
#define inDACkof        14 \ выдать текущее значение усилителя DAC
#define inDMset         15 \ выдать коэф. усиления приемника
#define inCodec         16 \ выдать значение настройки регистра аналогового инте
#define BITMOLZAP       17  \ выдать значение бита заполнения паузы

#define SAVEBOOT 			27 \ сохранить программу
#define TESTFLASHPRG		28 \ определить наличие сохраненной программы
#define GETTMPVAR			29 \ получить время прошивки программы
#define GETNCHAN			30 \ получить номер текущего канала связи

: _2W@ ( adr n - n )
2* + W@
;

: PrnMDate ( un - uy um ud )  { v -- }
v 0x007F AND 
v 0x0780 AND 7 RSHIFT 
v 0xF800 AND 11 RSHIFT 
;
