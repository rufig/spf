REQUIRE MapiLogon        ~ac/lib/win/mapi/exmapi.f
REQUIRE MapiListMessage  ~ac/lib/win/mapi/list.f

HEX
\ S" MGW" S" password" MapiLogon THROW  MapiGetStores
S" Outlook" S" password" MapiLogon THROW  MapiGetStores

\ CR MapiStoresRS DumpRowSet
\ CR MapiStoresRS PR_PROVIDER_DISPLAY S" MAPILab Group Folders" MapiRow@ 
\ PR_DISPLAY_NAME MapiRowProp@ 2DROP ASCIIZ> ANSI>OEM TYPE CR

\ S" MAPILab Group Folders" MapiOpenProvStore
\ S" RAINBOW:Личные папки" MapiOpenStore
S" Personal Folders" MapiOpenStore
\ S" Личные папки" MapiOpenStore

MapiGetRootFolderId MapiOpenFolder DROP
DUP ( folder ) PR_DISPLAY_NAME  MapiProp@ ANSI>OEM TYPE CR \ дает "Корень личных папок"
    ( folder ) ' MapiListFolder MapiEnumSubfolders

MapiOpenInbox DUP uMapiFolder ! ' MapiListMessage MapiEnumContent

\ S" IPF.Task" MapiGetIPF MapiOpenFolder DROP
\ DUP ( folder ) PR_DISPLAY_NAME  MapiProp@ ANSI>OEM TYPE CR \ дает "Корень личных папок"
\     ( folder ) DUP uMapiFolder ! ' MapiListMessage MapiEnumContent

S" IPM.Note" MapiNewMessage

S" test.eml" MapiImportMime

\ перезапишем дату импортированного письма текущей датой
MapiMessage PR_CREATION_TIME MapiProp@ ( x1 x2 )
MapiMessage PR_MESSAGE_DELIVERY_TIME MapiProp! \ эта дата показывается в "Получено"


S" Test subject 9" MapiSubject!
S" tester@forth.org.ru" S" AYC8" MapiSender!
\ S" Это тест 10" MapiBody!
\ " X-MapiLib: LibMapi/$Id$/eserv.ru
\ " STR@ MapiHeaders!

S" ac@eserv.ru" S" Andrey Cherezov" MapiAddRcpt
S" ac@forth.org.ru" S" Andrey SPF" MapiAddRcpt
S" dev@forth.org.ru" S" SPF DEV" MapiAddRcptCc
S" arc@forth.org.ru" S" SPF ARC" MapiAddRcptBcc

S" 1.html" FILE S" 1.html" S" text/html" MapiAddAtt .
S" 12346" S" file.txt" S" text/plain" MapiAddAtt .
S" mapi4.rar" FILE S" mapi4.rar" S" application/octet-stream" MapiAddAtt .
\ S" C:\Eserv3\EservEproxy332_nas-setup.exe"  FILE S" EservEproxy332_nas-setup.exe" S" application/octet-stream" MapiAddAtt .

S" exported.eml" MapiExportMime
MapiSave

MAPIUninitialize THROW

