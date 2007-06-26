\ 02-05-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ регистры ФВМ

CREATE psevdoregs

\ Реализация для подпрограммного шитого кода.
\ ESP - указатель стека возвратов
\ EBP - указатель стека данных
\ EDI - сохраняемый регистр [указатель данных потока в SPF]

\ -- основные регистры ------------------------------------------------------
MACRO: tos          EAX   ENDM \ вершина стека данных
MACRO: tos-byte     AL    ENDM \ младший байт tos
MACRO: tos-word     AX    ENDM \ младшие два байта tos
MACRO: [tos]        [EAX] ENDM
MACRO: [tos*CELL]   [EAX*4] ENDM
MACRO: top          EBP   ENDM \ указатель на вершину стека данных
MACRO: [top]        [EBP] ENDM
MACRO: subtop       [EBP] ENDM \ подвершина стека данных
MACRO: rtop         ESP   ENDM \ вершина стека возвратов - указатель
MACRO: [rtop]       [ESP] ENDM
MACRO: tls          EDI   ENDM \ регистр хранящий область данных потока
MACRO: [tls]        [EDI] ENDM

\ -- дополнительные регистры ------------------------------------------------
MACRO: addr         EBX   ENDM \ используется для временного хранения адресов
MACRO: [addr]       [EBX] ENDM \
MACRO: temp         EDX   ENDM \ для временного хранения данных
MACRO: temp-byte    DL    ENDM \
MACRO: temp-word    DX    ENDM \
MACRO: templ        ESI   ENDM \ еще один временный регистр
MACRO: cntr         ECX   ENDM \ временный регистр для хранения счетчика
