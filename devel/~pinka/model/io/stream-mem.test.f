REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`stream-mem.L1.f.xml EMBODY

( ѕростой бинарный поток данных в динамически распредел€емой пам€ти.
  ѕри исчерпании очередного блока пам€ти создаетс€ новый блок,
  блоки св€зываютс€ в список. –азмер каждого следующего блока
  адаптируетс€ под объем данных дл€ уменьшени€ общего числа блоков.
  ѕри чтении полностью вычитанные блоки освобождаютс€.
   огда читать больше нечего -- длина прочитанного 0.
)


 \ stream-mem-hidden ALSO!

 S" abc" write
 HERE 100 readout TYPE CR

 HERE 10000 write
 HERE 10000 write
 HERE 50000 readout SWAP . . CR
 HERE 50000 readout SWAP . . CR
 HERE 50000 readout SWAP . . CR
 HERE 50000 readout SWAP . . CR
 CR
 HERE 10000 write
 HERE 10000 write
 next-chunk SWAP . . CR
 next-chunk SWAP . . CR
 next-chunk SWAP . . CR



(  ќ, попалось архивное по близкой теме:
    http://article.gmane.org/gmane.comp.lang.forth.spf/733/ 
    -- письмо от ~yz в spf-dev@ от 2006-05-10
      http://blogs.msdn.com/larryosterman/archive/2004/04/19/116084.aspx
      -- создание временного файла в пам€ти через атрибуты
      FILE_ATTRIBUTE_TEMPORARY | FILE_FLAG_DELETE_ON_CLOSE
)
