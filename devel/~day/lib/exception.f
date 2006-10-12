( Dmitry Yakimov <c> 2004 ftech@tula.net
   ver. 1.2
   
   Генерация отчета об ошибке программы \втч трейс стека возвратов\
   и затем отсылка отчета ее создателям через Simple MAPI.
   В отчет возможно приаттачивать нужные файлы.
   
   Рекомендую положить в директорию программы файл spf.err - так
   сообщения будут информативнее.
    
   Пример использования - инсталляция:
   
   : ГлавноеСлово
        0 0 /
   ;
   
   : Application
       ['] ГлавноеСлово CATCH ProcessCatch
   ;
   
   и все.
   или же вместо установки MAINX сделайте так:
   ' ГлавноеСлово INSTALL-EXC-REPORT
   это и MAINX установит и обработку ошибок инсталлирует.
   
   установка subject и TO полей - куда шлем отчет:
   установите вектор
   <GetSendInfo> [ subj u to u ] \ здесь строки zero-terminated
   
   имеется возможность программе дописывать к полям отчета какую-то
   внутреннюю информацию во время ошибки - для этого установите вектор
   <WriteUserInfo> - он должен выводить в H-STDOUT.
   
   Добавление к отчету файлов:
   
   1. установите вектор <SetReportFiles>
   2. в нем делайте S" полный_путь_к_файлу" AddReportFile
      столько раз столько необходимо
   
   в случае если программа до этого вела лог H-STDLOG - 
   отчет об ошибке присоединяется к этому логу.
   
   см. пример в конце этого файла.
)

REQUIRE OSVER lib\win\osver.f
REQUIRE ||    ~ac/lib/temps.f
REQUIRE [DEFINED] lib\include\tools.f

[DEFINED] QuickSWL
[IF]

: ||  POSTPONE || TEMP-NAMES REFRESH-WLHASH ; IMMEDIATE
[THEN]

REQUIRE DIALOG:        ~ac/lib/win/window/dialog_creating.f

WINAPI: DialogBoxIndirectParamA USER32.DLL
WINAPI: EndDialog               USER32.DLL
WINAPI: GetDlgItemTextA         USER32.DLL
WINAPI: SetDlgItemTextA         USER32.DLL
WINAPI: GetDlgItem              USER32.DLL
WINAPI: SendMessageA            USER32.DLL
WINAPI: MAPISendMail            MAPI32.DLL

MODULE: ExceptionReport

0 VALUE log-text

\ ----------------------------------------------------------------------
\ функция окна диалога

: (DlgWndProc)     ( lparam wparam uint hwnd -- flag )
  || lparam wparam uint hwnd || (( lparam wparam uint hwnd ))

  uint WM_INITDIALOG = 
  IF  
      log-text
      101
      hwnd SetDlgItemTextA DROP
           
      TRUE EXIT 
  THEN

  uint WM_COMMAND =
  IF wparam IDCANCEL =
     IF 0 hwnd EndDialog EXIT THEN
     wparam IDOK =
     IF  1 hwnd EndDialog EXIT THEN
  THEN

  FALSE
;

' (DlgWndProc) WNDPROC: DlgWndProc

: DialogModal ( template xt parent-hwnd -- x )
  || tpl xt par || (( tpl xt par ))
  0 xt par tpl 0 DialogBoxIndirectParamA
;

: EDITTEXT ( N id x y cx cy style -- N+1 )
  WS_BORDER OR ( WS_TABSTOP OR) DI_Edit DIALOG_ITEM
;

0 0 320 235
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR
DS_SETFONT OR DS_CENTER OR

DIALOG: ErrorDialog Error report

      10 0 FONT Courier New

      101  4  4 310 190 
      ES_MULTILINE
      ES_AUTOHSCROLL OR
      ES_AUTOVSCROLL OR
      \ ES_READONLY OR
      \ ES_WANTRETURN OR 
      EDITTEXT
      
      IDOK  5 205 145 18 PUSHBUTTON Send the information to developer
      IDCANCEL 220 205 40 18 PUSHBUTTON Cancel

DIALOG;

: EXC-DUMP2
    STARTLOG
    EXC-DUMP1
;

' EXC-DUMP2 TO <EXC-DUMP>

EXPORT

VECT <WriteUserInfo>

DEFINITIONS

: WriteSystemInformation
   ." System information:" CR
   /OSVERSIONINFO ALLOCATE THROW DUP >R
   /OSVERSIONINFO R@ !
   GetVersionExA DROP
   R@ dwPlatformId @ DUP VER_PLATFORM_WIN32_NT =
   IF ." WinNT " THEN
   VER_PLATFORM_WIN32_WINDOWS =
   IF
     R@ dwMinorVersion @ 0 > R@ dwMajorVersion @ 4 = AND
     R@ dwMajorVersion @ 4 > OR IF ." Win98" ELSE ." Win95" THEN
   THEN
   R@ dwMajorVersion @ . [CHAR] . EMIT
   R@ dwMinorVersion @ . ."  build "
   R@ dwBuildNumber @ DECIMAL . CR
   
   CR ." Software information:" CR
   <WriteUserInfo>
   R> FREE THROW     
;

0
CELL -- .nextAttachedFile
CELL -- .path
CONSTANT /fileDesc

0 VALUE list

0 VALUE numberOfFiles

8 1 OR CONSTANT MAPI_DIALOG

CREATE mapi-msg
12 CELLS ALLOT
mapi-msg 12 CELLS ERASE
1 mapi-msg 8 CELLS + ! \ recip-count

CREATE mapi-recip 6 CELLS ALLOT
mapi-recip 6 CELLS ERASE
1 mapi-recip CELL+ ! \ MAPI_TO

mapi-recip mapi-msg 9 CELLS + !

0
CELL -- .flReserved
CELL -- .flFlags
CELL -- .nPosition
CELL -- .filePath
CELL -- .fileName
CELL -- .fileType
CONSTANT /mapiFileDesc

: PrintFiles ( -- )
    list
    BEGIN
       DUP 
          IF DUP .path @ ASCIIZ> TYPE CR
             .nextAttachedFile @ TRUE
          ELSE FALSE
          THEN
    UNTIL DROP
;

0 VALUE mapiArr

: fillMapiFiles
    list
    numberOfFiles 0
    DO
       DUP .path @ mapiArr I /mapiFileDesc * + .filePath ! ( path )
       -1 mapiArr I /mapiFileDesc * + .nPosition !       
       .nextAttachedFile @
    LOOP DROP
;

: prepareFiles
  list
  IF
     numberOfFiles /mapiFileDesc * DUP ALLOCATE THROW TO mapiArr
     mapiArr SWAP ERASE
     fillMapiFiles
     mapiArr mapi-msg 11 CELLS + !
     numberOfFiles mapi-msg 10 CELLS + !
  THEN
;

\ zero-ended strings!
: SendThroughMAPI ( subj text to )
     mapi-recip 3 CELLS + !
     mapi-msg 2 CELLS + !
     mapi-msg CELL+ !

     prepareFiles
     
     0 \ ulReserved
     MAPI_DIALOG 
     mapi-msg
     0 \ ulUIParam
     0 \ lhSession
     MAPISendMail DROP BYE
;

EXPORT

VECT <GetSendInfo> ( addr-subj u addr-to u )
VECT <SetReportFiles> ( -- )

DEFINITIONS

:NONAME
  S" subj" S" 911@activekitten.com"    
; TO <GetSendInfo>

: LoadLogFile
    S" spf.log" R/O OPEN-FILE THROW >R
    R@ FILE-SIZE THROW DROP
    DUP 2+ ALLOCATE THROW SWAP ( addr u )
    2DUP R@ READ-FILE THROW DROP
    R> CLOSE-FILE THROW
    
    OVER + 0 SWAP C!
    TO log-text    
;

: ShowLogInfo
    LoadLogFile
    ErrorDialog @ ['] DlgWndProc 0 DialogModal
    IF
       <SetReportFiles>    
       <GetSendInfo> DROP SWAP DROP
       log-text SWAP
       SendThroughMAPI
    THEN
;

EXPORT

: AddReportFile ( addr u -- )
     HEAP-COPY
     /fileDesc ALLOCATE THROW >R
     R@ .path !
     list R@ .nextAttachedFile !
     R> TO list 
     numberOfFiles 1+
       TO numberOfFiles
;

: ProcessCatch ( u -- )
    ?DUP
    IF
       H-STDLOG 0= IF STARTLOG THEN
       CR ." ERROR: " HEX DUP U. CR
       FORTH_ERROR DECODE-ERROR 4 - TYPE CR CR
       ER-U @
       IF
          ." Abort message: " ER-A @ ER-U @ TYPE CR
       THEN
       WriteSystemInformation
       ENDLOG
       ShowLogInfo
    THEN
;

;MODULE

\ использовать после установки MAINX

: INSTALL-EXC-REPORT ( mainx-xt )
    :NONAME SWAP LIT,
    POSTPONE CATCH
    POSTPONE ProcessCatch
    POSTPONE BYE
    POSTPONE ;
        MAINX !
;

\EOF

:NONAME
    S" c:\spf\devel\~day\lib\exception.f" AddReportFile
    S" c:\spf\devel\~day\lib\os_ver.f" AddReportFile    
; TO <SetReportFiles>

: test
    0 0 /
;

: Done
    ['] test CATCH ProcessCatch BYE
;

' test INSTALL-EXC-REPORT
-1 TO ?GUI
S" text-exc.exe" SAVE

Done