\ http://fforum.winglion.ru/viewtopic.php?p=5594#5594
WORDLIST CONSTANT voc

{{ voc DEFINITIONS
: a CR ." voc.a" ; \ определяем в словаре voc
}} DEFINITIONS

: a CR ." a" ; \ определяем в общаке

{{ voc
a \ пускаем voc-овый
}}
a \ пускаем общаковый

VOCABULARY voc1

{{ voc1 DEFINITIONS
: a CR ." voc1.a" ;  \ определяем в словаре voc1
}} DEFINITIONS

\ voc::a \ не работает!
voc1::a \ пускаем voc1-овый
a