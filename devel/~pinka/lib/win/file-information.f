REQUIRE lexicon.basics-aligned  ~pinka/lib/ext/basics.f  \ to access fields via Q@ and T@
REQUIRE WORDLIST-NAMED          ~pinka/spf/compiler/native-wordlist.f
REQUIRE PUSH-DEVELOP            ~pinka/spf/compiler/native-context.f
REQUIRE AsQName                 ~pinka/samples/2006/syntax/qname.f


WINAPI: GetFileInformationByHandle KERNEL32.DLL ( lpFileInformation hFile -- bool )

`BHFI WORDLIST-NAMED PUSH-DEVELOP

\ BY_HANDLE_FILE_INFORMATION
0
4 -- dwFileAttributes
8 -- ftCreationTime
8 -- ftLastAccessTime
8 -- ftLastWriteTime
4 -- dwVolumeSerialNumber
4 -- nFileSizeHigh
4 -- nFileSizeLow
4 -- nNumberOfLinks
4 -- nFileIndexHigh
4 -- nFileIndexLow
CONSTANT /BY_HANDLE_FILE_INFORMATION
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa363788.aspx

/BY_HANDLE_FILE_INFORMATION >CELLS 1+ CONSTANT SIZE-CELLS

DROP-DEVELOP
