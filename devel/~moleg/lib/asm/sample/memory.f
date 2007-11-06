\ 26-06-2005 ~mOleg
\ работа с памятью

\ x - значение по адресу a-addr.
CODE @ ( a-addr --> x )
       MOV tos , [tos]
     exit
  END-CODE

\ Записать x по адресу a-addr.
CODE ! ( x a-addr --> )
       MOV temp , subtop
       MOV [tos] , temp
       MOV tos , CELL [top]
       dheave 2 CELLS
     exit
  END-CODE

\ Получить byte по адресу c-addr.
\ Незначащие старшие биты ячейки нулевые.
CODE B@ ( c-addr --> char )
        MOVZX tos , BYTE [tos]
      exit
   END-CODE

\ Записать byte по адресу a-addr.
CODE B! ( char c-addr --> )
        MOV temp , subtop
        MOV BYTE [tos] , temp-byte
        MOV tos , CELL [top]
        dheave 2 CELLS
      exit
   END-CODE

\ Получить символ по адресу c-addr.
\ Незначащие старшие биты ячейки нулевые.
CODE C@ ( c-addr --> char )
        MOVZX tos , BYTE [tos]
      exit
   END-CODE

\ Записать char по адресу a-addr.
CODE C! ( char c-addr --> )
        MOV temp , subtop
        MOV BYTE [tos] , temp-byte
        MOV tos , CELL [top]
        dheave 2 CELLS
      exit
   END-CODE

\ Получить word по адресу c-addr. Незначащие старшие биты ячейки нулевые.
CODE W@ ( c-addr --> word )
        MOVZX tos , WORD [tos]
      exit
   END-CODE

\ Записать word по адресу a-addr.
CODE W! ( word c-addr --> )
        MOV temp , subtop
        MOV WORD [tos] , temp-word
        MOV tos , CELL [top]
        dheave 2 CELLS
      exit
   END-CODE

\ извлечь число двойной точности из памяти по адресу addr
CODE 2@ ( addr --> d )
        MOV temp , CELL [tos]
        dpush temp
        MOV tos , [tos]
      exit
   END-CODE

\ сохранить число двойной точности в памяти по адресу addr
CODE 2! ( d addr --> )
        MOV temp , subtop
        MOV [tos] , temp
        MOV temp , CELL [top]
        MOV CELL [tos] , temp
        dheave 3 CELLS
        MOV tos , -CELL [top]
      exit
   END-CODE

\ увеличить значение по адресу addr
CODE 1+! ( addr --> )
         INC DWORD [tos]
         dpop tos
      exit
    END-CODE

\ Прибавить число n к числу хранящемуся в памяти по адресу addr
CODE +! ( n addr --> )
        MOV temp , subtop
        ADD [tos] , temp
        MOV tos , CELL [top]
        dheave 2 CELLS
      exit
   END-CODE

\ в осмыслении...
\ смысл в том, что разрядность адресной ссылки может не совпадать с
\ разрядностью данных, то есть может быть меньше или равно в данном случае.

\ извлечь адрес
CODE A@ ( a-addr --> x )
        MOV tos , [tos]
      exit
   END-CODE

\ сохранить адрес
CODE A! ( x a-addr --> )
        MOV temp , subtop
        MOV [tos] , temp
        MOV tos , CELL [top]
        dheave 2 CELLS
      exit
   END-CODE

\ заменить значение по указанному адресу на new - старое вернуть
CODE ACHANGE ( new addr --> old )
             dpop temp
             MOV addr , tos
             MOV tos , [addr]
             MOV [addr] , temp
           exit
       END-CODE
