\ Чтение/запись профиля
\ Перед загрузкой определить имя файла в переменной profile

REQUIRE " ~yz/lib/common.f

WINAPI: GetPrivateProfileStringA   KERNEL32.DLL
WINAPI: GetPrivateProfileIntA      KERNEL32.DLL
WINAPI: WritePrivateProfileStringA KERNEL32.DLL

: read-profile ( section key to -- )
  -ROT >R >R >R profile 256 R> " ?" R> R> SWAP
  GetPrivateProfileStringA DROP ;

: write-profile ( section key value -- ) 
  -ROT 2>R >R profile R> R> R> WritePrivateProfileStringA DROP ;

: read-profile-int ( section key -- n)
  profile -1 2SWAP SWAP GetPrivateProfileIntA ;
