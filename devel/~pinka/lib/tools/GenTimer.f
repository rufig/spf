

REQUIRE BEGIN-CODE  ~day\common\code.f 

(  ¬ Pentium'е разработчиками была введена команда RDTSC, возвращающа€ число
тактов процесора с момента подачи на него напр€жени€.  од этой команды $0F $31.
команда возвращает восьмибайтное число в регистрах EDX:EAX. 
)

BEGIN-CODE
ALSO ASSEMBLER

CODE GetTicks  (  -- tlo thi )
     RDTSC
     SUB EBP, # 8
     MOV [EBP], EDX
     MOV 4 [EBP], EAX
     RET
END-CODE

PREVIOUS
CLOSE-CODE

BYE
