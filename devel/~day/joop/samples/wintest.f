REQUIRE FrameWindow ~day\joop\win\framewindow.f
REQUIRE Button ~day\joop\win\control.f
REQUIRE Font ~day\joop\win\font.f
REQUIRE OpenDialog ~day\joop\win\filedialogs.f
REQUIRE MENUITEM ~day\joop\win\menu.f

~day\joop\samples\about_dlg.f

\ Идентификаторы меню
105 CONSTANT MI_CLOSE
106 CONSTANT MI_EXIT
107 CONSTANT MI_CUT
108 CONSTANT MI_PASTE
109 CONSTANT MI_CONTENT
110 CONSTANT MI_ABOUT
111 CONSTANT MI_TEXTFILE
111 CONSTANT MI_BINARY

<< :button1Click
<< :button2Click

CLASS: MyWindow <SUPER FrameWindow

        Button OBJ button
        Button OBJ button2
        Button OBJ frame
        Edit   OBJ edit1
        Static OBJ st1
        Static OBJ st2
        OpenDialog OBJ openDialog
        ListBox OBJ listBox1
        ProgressBar OBJ pb1

: :createPopup
   POPUPMENU
    POPUP
      S" &he he"        MI_ABOUT        MENUITEM
      S" &ha ha"        MI_ABOUT        MENUITEM
    S" &yahho" END-POPUP
    POPUP
      S" &ku ku"        MI_ABOUT      MENUITEM
      S" &la la"        MI_ABOUT      MENUITEM
    S" &uhha" END-POPUP
   END-MENU   
;

: :initListBox
  \ Вывести список только директорий в c:
    S" c:\*" DROP
    DDL_DIRECTORY DDL_EXCLUSIVE  OR
    LB_DIR listBox1 <handle @
    SendMessageA DROP
;
        
: :createMenu
    MENU
    POPUP
      POPUP
        S" &Text file"          MI_TEXTFILE     MENUITEM
        S" &Binary data"        MI_BINARY       MENUITEM
      S" &Open" END-POPUP
      S" &Close"        MI_CLOSE        MENUITEM
      MENUSEPARATOR
      S" &Exit"         MI_EXIT         MENUITEM
    S" &File" END-POPUP
    POPUP
      S" &Cut"          MI_CUT          MENUITEM
      S" &Paste"        MI_PASTE        MENUITEM
    S" &Edit" END-POPUP
    POPUP
      S" &Content"      MI_CONTENT      MENUITEM
      S" &About"        MI_ABOUT        MENUITEM
    S" &Help" END-POPUP
    END-MENU
    DUP menu !
;

M: MI_ABOUT
   S" Just an example of jOOP usage" S" Version 1.0" self ShowAbout
;

M: MI_EXIT
   BYE
;
M: MI_BINARY
    openDialog :execute DROP
    openDialog :fileName edit1 :setText
;
               
: :button1Click
   S" Выберите меню File\open\text file" self :showMessage
;

: :button2Click { \ w }
   MyWindow :new -> w
   self w :create
   105 55 200 160 w :move       
   S" Вот что может jOOP!" w :setText   
   w :showModal DROP
   w :free
;

: :create { \ sfont }
   own :create
   S" click me" 10 10 50 20 self button :install
   ['] :button1Click button <OnClick !

   0 0 100 10 80 40 self listBox1 :install
   own :initListBox 
   
   S" Hello"  10 35 80 11 self edit1 :install
   max-path edit1 :setLimit
   S" Модальное окно" 40 60 50 20 self button2 :install
   ['] :button2Click button2 <OnClick !
   S" Это просто текст, причем особенным шрифтом. Обратите на это внимание"
   100 45 70 80 self st1 :install
   
   Font :new -> sfont
   S" Comic Sans MS" DROP sfont <lpszFace !
   20 sfont <height !
   sfont :create
   sfont <handle @ st1 :setFont

   
   S" Кликните правой кнопкой мыши на форме. Это окно - не диалог Windows!!!"
   20 100 150 30 self st2 :install      
   S" Times New Roman" DROP sfont <lpszFace !   
   TRUE sfont <italic !
   FW_BOLD sfont <weight !
   sfont :create
   sfont <handle @ st2 :setFont

   BS_GROUPBOX frame <style !
   0 0 3 0 190 130 self frame :install
   0 0 19 119 150 10 self pb1 :install
   0 100 pb1 :setRange
   60 pb1 :setPos
;

;CLASS


: test { \ w }
   MyWindow :new -> w
   0 w :create
   S" Вот что может jOOP!" w :setText
   100 50 200 160 w :move    
   w :show
   w :run 
   w :free
   BYE
;

\ test BYE
HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE
' test MAINX !
TRUE TO ?GUI
S" wintest.exe" SAVE BYE
