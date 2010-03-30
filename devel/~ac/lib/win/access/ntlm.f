\ структуры сообщений NTLM (передаются между клиентом и сервером при авторизации)

REQUIRE {          lib/ext/locals.f
REQUIRE debase64   ~ac/lib/string/conv.f
REQUIRE LocalLogon ~ac/lib/win/access/sspi_logon.f 

\ NTLM_mes1 NEGOTIATE_MESSAGE от клиента серверу
0
8 -- ntlm_protocol \ asciiz "NTLMSSP"
1 -- ntlm_type     \ 0x01
3 -- ntlm_zero1    \ нули
2 -- ntlm_flags1   \ 0xB203 или 0xB207 или x8207
2 -- ntlm_flags2   \ 0xA208 или 0x0008
2 -- ntlm_domlen1  \ длина имени домена или рабочей группы (не asciiz)
2 -- ntlm_domlen2  \ то же (maxlen)
4 -- ntlm_domoffs  \ смещение имени домена
2 -- ntlm_hostlen1 \ длина имени хоста (WorkstationLen)
2 -- ntlm_hostlen2 \ то же (maxlen)
4 -- ntlm_hostoffs \ смещение имени хоста
1 -- ntlm_wprodmaj \ ProductMajorVersion (Windows - 6 или 5)
1 -- ntlm_wprodmin \ ProductMinorVersion (Windows - 0..2)
2 -- ntlm_wbuild   \ ProductBuild
3 -- ntlm_reserved \ нули
1 -- ntlm_revision \ NTLMSSP_REVISION_W2K3=0x0F, NTLMSSP_REVISION_W2K3_RC1=0x0A
\ далее собственно имя хоста и домена
CONSTANT /NTLM_mes1

\ NTLM_mes2 CHALLENGE_MESSAGE от сервера клиенту
0
8 -- ntlm2_protocol \ asciiz "NTLMSSP"
1 -- ntlm2_type     \ 0x02
3 -- ntlm2_zero4    \ нули
2 -- ntlm2_targlen1 \ длина TargetName (домен) или нули
2 -- ntlm2_targlen2 \ то же
4 -- ntlm2_targoffs \ смещение TargetName или 0x28 (/NTLM_mes2), если его нет
2 -- ntlm2_flags1   \ 0x8205 или 0x8201, если TargetName нет
2 -- ntlm2_flags2   \ ... или нули
8 -- ntlm2_mes      \ 64-bit challenge
8 -- ntlm2_reserv1  \ обязательно нули

2 -- ntlm2_tinflen1 \ длина TargetInfo, поле есть, если флаг NTLMSSP_NEGOTIATE_TARGET_INFO
2 -- ntlm2_tinflen2 \ то же
4 -- ntlm2_tinfoffs \ смещение TargetInfo

1 -- ntlm2_wprodmaj \ ProductMajorVersion (Windows - 6 или 5)
1 -- ntlm2_wprodmin \ ProductMinorVersion (Windows - 0..2)
2 -- ntlm2_wbuild   \ ProductBuild
3 -- ntlm2_reserved \ нули
1 -- ntlm2_revision \ NTLMSSP_REVISION_W2K3=0x0F, NTLMSSP_REVISION_W2K3_RC1=0x0A

CONSTANT /NTLM_mes2

CREATE NTLM_mes2 CHAR N C, CHAR T C, CHAR L C, CHAR M C, CHAR S C, CHAR S C, CHAR P C, 0 C,
2 , 0 , 40 , 0x8201 , 0 , 0 , 0 , 0 , 

\ challenge-сообщение сервера в случае, если на сервере не работает SSPI
\ или клиент и сервер в разных доменах, в разных сетях, или не-windows-сети
: BNTLM_mes2 NTLM_mes2 0x28 ( /NTLM_mes2 ) base64 ;

\ NTLM_mes3 AUTHENTICATE_MESSAGE от клиента серверу
0
8 -- ntlm3_protocol \ asciiz "NTLMSSP"
1 -- ntlm3_type     \ 0x03 (NtLmAuthenticate)
3 -- ntlm3_zero8    \ нули
2 -- ntlm3_resplen1 \ длина ответа LanManager (0x18)
2 -- ntlm3_resplen2 \ то же

4 -- ntlm3_respoffs \ смещение ответа LanManager
2 -- ntlm3_ntrespl1 \ длина ответа NT (0x38 или 0x18)
2 -- ntlm3_ntrespl2 \ то же
4 -- ntlm3_ntrespof \ смещение ответа NT
2 -- ntlm3_domlen1  \ длина домена в байтах,
                    \ сам домен в виде unicode (вместо рабочей группы имя хоста строчными)
2 -- ntlm3_domlen2  \ то же

4 -- ntlm3_domoffs  \ смешение имени домена
2 -- ntlm3_userlen1 \ длина логина в байтах (сам логин в unicode = UTF-16LE)
2 -- ntlm3_userlen2 \ то же
4 -- ntlm3_useroffs \ смещение логина
2 -- ntlm3_hostlen1 \ длина хоста в байтах (сам в unicode прописными)
2 -- ntlm3_hostlen2 \ то же

4 -- ntlm3_hostoffs \ смещение имени хоста
2 -- ntlm3_seskeyl1 \ длина сессионного ключа (на практике 0)
2 -- ntlm3_seskeyl2 \ то же
4 -- ntlm3_keyoffs  \ смещение ключа (на практике здесь длина всей структуры!)
2 -- ntlm3_flags1   \ 0x8205 или 0x8201 или 0xC205
2 -- ntlm3_flags2   \ 0x0200 или 0xA288

1 -- ntlm3_wprodmaj \ ProductMajorVersion (Windows - 6 или 5)
1 -- ntlm3_wprodmin \ ProductMinorVersion (Windows - 0..2)
2 -- ntlm3_wbuild   \ ProductBuild
3 -- ntlm3_reserved \ нули
1 -- ntlm3_revision \ NTLMSSP_REVISION_W2K3=0x0F, NTLMSSP_REVISION_W2K3_RC1=0x0A
\ далее неизвестные числа (16 байт во всех браузерах), скорее всего user GUID
\ далее домен, логин, хост, LM-ответ, NT-ответ 
\ (все эти "далее" могут отсутствовать, если соответствующие длины =0)
CONSTANT /NTLM_mes3

1 CONSTANT NtLmNegotiate
3 CONSTANT NtLmAuthenticate
