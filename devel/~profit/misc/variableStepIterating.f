\ Эксперименты с переменным и изменяемым шагом итераторов

~profit\lib\bac4th-iterators.f 
: a S" abcdef" iterateByBytes DUP @ SWAP CHAR+ SWAP EMIT ; a

CR

: b S" abcdef" 0 iterateBy
\              ^-- итератор пускай не дёргается и не меняет
\                  бегунок -- мы сами будем его менять
DUP @ SWAP CHAR+ SWAP EMIT ; b

\ Также интересно ещё одно последствие задания нулевого шага
\ итератора: он всегда будет генерироваться