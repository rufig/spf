\ Simple MAPI
WINAPI: MAPILogon          MAPI32.DLL
WINAPI: MAPILogoff         MAPI32.DLL
WINAPI: MAPIFindNext       MAPI32.DLL
WINAPI: MAPIReadMail       MAPI32.DLL

\ Extended MAPI
WINAPI: MAPIInitialize     MAPI32.DLL
WINAPI: MAPIUninitialize   MAPI32.DLL
WINAPI: MAPILogonEx        MAPI32.DLL

WINAPI: HrQueryAllRows@24  MAPI32.DLL
\ WINAPI: HrMAPIOpenFolderEx MAPI32.DLL \ из EDK, не устанавливается с аутлуком

WINAPI: WrapCompressedRTFStream MAPI32.DLL \ html в MAPI хранится как сжатый RTF
\ WINAPI: WrapCompressedRTFStreamEx MAPI32.DLL \ в Outlook 2002 нет

WINAPI: OpenStreamOnFile   MAPI32.DLL
