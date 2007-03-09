DIS-OPT
REQUIRE button ~yz/lib/winctl.f
REQUIRE >FLOAT lib/include/float2.f
SET-OPT

0 VALUE edit_kg
0 VALUE edit_lbs

0 VALUE edit_from    
0 VALUE edit_to
0 VALUE conv_alg

: status 0 winmain set-status ;

: msg_ok " Готово... " status ;

: msg_init " Весь во внимании... " status ;

: msg_bad_num " Проверьте правильность ввода... " status ;

: convert { \ [ 100 ] str len -- } 
  edit_from -text#  TO len  \ получаем кол-во символов в числе из поля-получателя
  " " edit_to -text!        \ почистим поле-приемник 

  str edit_from -text@      \ помещаем во временную строку введенное число
  69 str len + C!           \ решаем, что ползователь ленивый и добавим за него в конце циферки букву "E"
  str len 1 + >FLOAT        \ переводим строчку во float
    IF                      \ если перевод удачный выполняем следующий блок 
      conv_alg              \ смотрим переменную conv_alg,
      IF                    \ если истина 
        0.456E F/           \ преобразовываем kg в lbs
      ELSE                  \ если ложь 
        0.456E F*           \ преобразовываем lbs в kg
      THEN
      >FNUM                 \ переводим float в строчку и копируем ее
      str CZMOVE            \ во временную Z строку 
      str edit_to -text!    \ записываем строчку в поле-прииемник 
      msg_ok
    ELSE      
      msg_bad_num
    THEN      
;

MESSAGES: edit_kg_msg
  M: en_killfocus
    TRUE TO conv_alg        \ помещаем в переменную conv_alg значение TRUE
                            \ это означает, что преобразование идет из kg в lbs
    edit_kg TO edit_from    \ определяем поле-источник
    edit_lbs TO edit_to     \ определяем поле-получатель
    convert
  M;
MESSAGES;

MESSAGES: edit_lbs_msg
  M: en_killfocus
    FALSE TO conv_alg
    edit_lbs TO edit_from
    edit_kg TO edit_to
    convert
  M;
MESSAGES;

: about
  " О программе"        \ заголовок окна
                        \ содержимое окна
  " Программа для перевода KG в LBS и обратно \nРазделитель целой и дробной части - точка \n\n\tВерсия 1.5 \n\nСделано на форт-системе SPF v4.16 \n\n\t\tАвтор - Цымбалов Е.А. \n\t\tН-Новгород, 2005 г." 
  0x0000 message-box    \ вывести сообщение в окне без иконки
  DROP                  \ убрать со стека код нажатой клавиши
;

MESSAGES: main_messages
M: wm_help
  about
  TRUE
M;
MESSAGES;

: run
  WINDOWS...
  0 dialog-window TO winmain
  " Калькулятор" winmain -text!

  \ Размещаем метки и поля ввода
  GRID
  ===
    GRID
    ===
      filler |
    ===  
      " KG" label (/ -align right /) -left | edit (/ -name edit_kg -size 120 20 -notify edit_kg_msg /) -right |
    ===
      " LBS" label (/ -align right /) -left | edit (/ -name edit_lbs -size 120 20 -notify edit_lbs_msg /) -right |
    ===
    " KG-LBS" groupbox cur-grid @ :gbox !
    GRID; |
  ===
  filler |
  ===
  GRID;  winmain -grid!

  32 edit_kg limit-edit     \ ограничиваем длину вводимых символов в полях ввода
  32 edit_lbs limit-edit    \    

  \ Создаем невидимую кнопку и заводим на нее все нажатия Enter
  " Пересчет " button
  -defbutton

  edit_kg winfocus

  winmain create-status
  msg_init

  \ установить наш обработчик сообщений
  main_messages winmain -wndproc!

  winmain wincenter
  winmain winshow

  ...WINDOWS
  BYE
;

\ 0 TO SPF-INIT?
 ' ANSI>OEM TO ANSI><OEM

\ TRUE TO ?GUI
\ ' run MAINX !
\ S" calc.exe" SAVE  

run

\EOF
