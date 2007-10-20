\ пример реализации контроллеров которые изменяют поведение контрола
\ первый контроллер сменит шрифт, второй - цвет контрола
\ все это на модальном диалоге, больше приближено к реальным условиям

\ то есть смену цвета static можно цеплять к любому static без множественного
\ наследования - вот в чем суть контроллеров

\ смену цвета можно было бы сделать гораздо проще - без контроллеров
\ в классе CMyStatic, например, но эти контроллеры можно 
\ использовать с другими классами что есть многократное использование
\ плюс примеры из реальной жизни будут менее искуственными (например splitter)

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f

100 CONSTANT CUSTOM_STATIC

0 0 100 50
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR
DS_SETFONT OR DS_CENTER OR

DIALOG: Dialog1 Customized static

      8 0 FONT MS Sans Serif

      CUSTOM_STATIC  25  15  50 15  WS_GROUP LTEXT Static1

DIALOG;

\ этот контроллер будет ловить отраженное WM_CTLCOLOR сообщение
CMsgController SUBCLASS CColorController

       CBrush OBJ brush

init:
    0xFF 0xFF 0 rgb brush createSolid SUPER -wthrow
;

\ Note - it is R: for reflected message, not W:

R: WM_CTLCOLORSTATIC ( -- n )
    SUPER msg wParam @
    TRANSPARENT SWAP SetBkMode DROP
    brush handle @

    \ Это не обязательно и по умолчанию уже работает. 
    \ Обычно используется FALSE SetHandled
    \ если мы хотим чтобы данное Win сообщение обработалось следующими
    \ контроллерами (а также самим владельцем-окном) в цепочке

    TRUE SUPER SetHandled 
;

;CLASS

CMsgController SUBCLASS CFontController

      CFont OBJ m_font

\ этот метод вызывается каждый раз когда контроллер цепляется к окну
 \ (в том числе и в attach методе)
: onAttached
    -18 FW_BOLD S" Tahoma" m_font create
    0 SUPER parent-obj@ ^ setFont
;

;CLASS

\ создадим новый класс диалога - для того чтобы инициализировать кнопку
\ в WM_INITDIALOG

CDialog SUBCLASS CMyDialog

    CFontController OBJ m_fontController
    CColorController OBJ m_colorController
    CStatic OBJ m_static

\ послылаем уведомления обратно дочерним окнам
REFLECT_NOTFICATIONS

W: WM_INITDIALOG ( -- res )
    \ прицепляем экзамеляр CStatic к хендлу окна static
    CUSTOM_STATIC SUPER getDlgItem m_static attach

    \ добавляем контроллеры к экземпляру класса static
     \ по умолчанию существует требование что inject можно делать
      \ в экземпляры с не нулевым hWnd
    m_colorController this m_static injectMsgController
    m_fontController this m_static injectMsgController

    0
;

;CLASS

CMyDialog NEW dlg1

Dialog1 0 dlg1 showModal DROP