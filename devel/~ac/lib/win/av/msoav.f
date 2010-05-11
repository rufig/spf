\ Тест антивирусного API Windows.
\ Лучше всего работает с Microsoft Security Essentials.
\ Почтовые файлы проверять НЕ умеет.

REQUIRE CLSID,  ~ac/lib/win/com/com.f
REQUIRE {       lib/ext/locals.f

2 CONSTANT CLSCTX_INPROC_HANDLER

CLSCTX_INPROC_SERVER
CLSCTX_INPROC_HANDLER OR
CLSCTX_LOCAL_SERVER OR
CLSCTX_REMOTE_SERVER OR
CONSTANT CLSCTX_ALL

0x80004005 CONSTANT E_FAIL

IID_IUnknown
Interface: IID_IOfficeAntiVirus {56FFCC30-D398-11d0-B2AE-00A0C908FA49}
  Method: ::Scan ( This,*pmsoavinfo)
Interface;

IID_IUnknown
Interface: IID_ICatInformation {0002E013-0000-0000-C000-000000000046}

  Method: ::EnumCategories ( 
            /* [in] */ LCID lcid,
            /* [out] */ IEnumCATEGORYINFO **ppenumCategoryInfo)
        
  Method: ::GetCategoryDesc ( 
            /* [in] */ REFCATID rcatid,
            /* [in] */ LCID lcid,
            /* [out] */ LPWSTR *pszDesc)
        
  Method: ::EnumClassesOfCategories ( 
            /* [in] */ ULONG cImplemented,
            /* [size_is][in] */ CATID rgcatidImpl[  ],
            /* [in] */ ULONG cRequired,
            /* [size_is][in] */ CATID rgcatidReq[  ],
            /* [out] */ IEnumGUID **ppenumClsid)
        
  Method: ::IsClassOfCategories ( 
            /* [in] */ REFCLSID rclsid,
            /* [in] */ ULONG cImplemented,
            /* [size_is][in] */ CATID rgcatidImpl[  ],
            /* [in] */ ULONG cRequired,
            /* [size_is][in] */ CATID rgcatidReq[  ])
        
  Method: ::EnumImplCategoriesOfClass ( 
            /* [in] */ REFCLSID rclsid,
            /* [out] */ IEnumGUID **ppenumCatid)
        
  Method: ::EnumReqCategoriesOfClass ( 
            /* [in] */ REFCLSID rclsid,
            /* [out] */ IEnumGUID **ppenumCatid)
Interface;

IID_IUnknown
Interface: IID_IEnumGUID {0002E000-0000-0000-C000-000000000046}

  Method: ::Next ( 
            /* [in] */ ULONG celt,
            /* [length_is][size_is][out] */ GUID *rgelt,
            /* [out] */ ULONG *pceltFetched)
        
  Method: ::Skip ( 
            /* [in] */ ULONG celt)
        
  Method: ::Reset ( void)
        
  Method: ::Clone ( 
            /* [out] */ IEnumGUID **ppenum)
Interface;


0
CELL -- MSOAV.cbsize \ size of this struct
\ bit -- MSOAV.fPath  \ when true use pwzFullPath else use lpstg
\ bit -- MSOAV.fReadOnlyRequest \ user requests file to be opened read/only
\ bit -- MSOAV.fInstalled \ the file at pwzFullPath is an installed file
\ bit -- MSOAV.fHttpDownload \ the file at pwzFullPath is a temp file downloaded from http/ftp
4 -- MSOAV.flags
CELL -- MSOAV.hwnd \ parent window of the Office9 app
\ union {
CELL -- MSOAV.pwzFullPath \ full path to the file about to be opened
\ CELL -- MSOAV.lpstg \ OLE Storage of the doc about to be opened
CELL -- MSOAV.pwzHostName \ Host Office 9 apps name
CELL -- MSOAV.pwzOrigURL \ URL of the origin of this downloaded file.
CONSTANT /MSOAVINFO

WINAPI: GetDesktopWindow USER32.DLL

: CLSID_AttachmentServices S" {4125dd96-e03a-4103-8f70-e0597d803b9c}" ;

IID_IUnknown
Interface: IID_IAttachmentExecute {73db1241-1e85-4581-8e4f-a81e1d0f8c57}

  Method: ::SetClientTitle ( 
            /* [string][in] */ LPCWSTR pszTitle)
        
  Method: ::SetClientGuid ( 
            /* [in] */ REFGUID guid)
        
  Method: ::SetLocalPath ( 
            /* [string][in] */ LPCWSTR pszLocalPath)
        
  Method: ::SetFileName ( 
            /* [string][in] */ LPCWSTR pszFileName)
        
  Method: ::SetSource ( 
            /* [string][in] */ LPCWSTR pszSource)
        
  Method: ::SetReferrer ( 
            /* [string][in] */ LPCWSTR pszReferrer)
        
  Method: ::CheckPolicy ( void)
        
  Method: ::Prompt ( 
            /* [in] */ HWND hwnd,
            /* [in] */ ATTACHMENT_PROMPT prompt,
            /* [out] */ ATTACHMENT_ACTION *paction)
        
  Method: ::Save ( void)
        
  Method: ::Execute ( 
            /* [in] */ HWND hwnd,
            /* [string][in] */ LPCWSTR pszVerb,
            HANDLE *phProcess)
        
  Method: ::SaveWithUI ( 
            HWND hwnd)
        
  Method: ::ClearClientState ( void)
        
Interface;

: AV_SCAN { a u \ info wdefender msoav cmgr aenum cats fet cls aes ae norton -- res }

  /MSOAVINFO ALLOCATE THROW -> info
  /MSOAVINFO info MSOAV.cbsize !
  0x3 info MSOAV.flags C!
  \ GetDesktopWindow info MSOAV.hwnd !
  S" shdocvw" >BSTR info MSOAV.pwzHostName ! \ см. HKEY_CLASSES_ROOT\CLSID\{2781761E-28E1-4109-99FE-B9D127C57AFE}\Hosts
  \ S" http://www.eicar.org/download/eicarcom2.zip" >BSTR info MSOAV.pwzOrigURL !

  a u >BSTR info MSOAV.pwzFullPath !
  ComInitAp DROP

  S" {0002e005-0000-0000-c000-000000000046}" CreateObject THROW -> cmgr \ StdComponentCategoriesMgr
  ^ cats IID_ICatInformation cmgr ::QueryInterface THROW

  \ перебираем установленные антивирусы

  ^ aenum 0 0 S" {56FFCC30-D398-11d0-B2AE-00A0C908FA49}" >UNICODE String>CLSID THROW
  1 cats ::EnumClassesOfCategories THROW
  BEGIN
    ^ fet PAD 1 aenum ::Next 0= fet 1 = AND
  WHILE
    PAD CLSID>String THROW UNICODE> TYPE SPACE

    ^ msoav IID_IOfficeAntiVirus CLSCTX_ALL 0 PAD CoCreateInstance HEX ." ci=" U. CR
    msoav IF
      info msoav ::Scan DUP ." scan=" HEX U.
      E_FAIL = IF info FREE THROW E_FAIL EXIT THEN
    THEN
    CR
  REPEAT

\  S" {2781761E-28E0-4109-99FE-B9D127C57AFE}" CreateObject THROW -> wdefender
\  {2781761E-28E1-4109-99FE-B9D127C57AFE} MSE
\  {DE1F7EEF-1851-11D3-939E-0004AC1ABE1F} NortonAntiVirus.OfficeAntiVirus.1
\  S" NortonAntiVirus.OfficeAntiVirus.1"  CreateObject THROW -> norton 
\  ^ msoav IID_IOfficeAntiVirus norton ::QueryInterface HEX ." no=" U.
\  ^ msoav IID_IOfficeAntiVirus wdefender ::QueryInterface THROW

  \ Интерфейс IAttachmentExecute внутри работает через IOfficeAntiVirus
  \ Но на практике IOfficeAntiVirus срабатывает реже, чем IAttachmentExecute,
  \ т.к. IOfficeAntiVirus не из всех приложений согласен вызываться...
  \ ::Save меняет дату файла, а при обнаружении вируса удаляет файл
(
  CLSID_AttachmentServices CreateObject THROW -> aes
  \ ^ ae IID_IAttachmentExecute CLSCTX_INPROC_SERVER 0 CLSID_AttachmentServices >UNICODE String>CLSID THROW CoCreateInstance HEX U.
  ^ ae IID_IAttachmentExecute aes ::QueryInterface THROW

  ae IF
    a u >BSTR ae ::SetLocalPath ." sp=" .
\    ae ::CheckPolicy ." po=" HEX U.
    ae ::Save ." sa=" HEX U.
  THEN
)

\ найден вирус и файл удален #define E_FAIL (0x80004005L)
\ 0x80070002 файл не найден или заблокирован  ERROR_FILE_NOT_FOUND
\ #define INET_E_SECURITY_PROBLEM          _HRESULT_TYPEDEF_(0x800C000EL)

  0
;
\ S" I:\dl\eicar_com(2).zip" AV_SCAN HEX U.
