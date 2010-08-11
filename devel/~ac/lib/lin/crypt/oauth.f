\ Поддержка протокола OAuth для доступа к API веб-сервисов. http://oauth.net/
\ OAuth 1.0 April 2010: RFC 5849

\ OAuth 2.0 July 2010: http://tools.ietf.org/html/draft-ietf-oauth-v2-10
( OAuth 2.0 не требует навесной клиентской криптографии вообще, т.к. передает
  client_secret внутри httpS-соединения, соответственно для всей работы с OA2
  достаточно базовых средств curl'а и браузера )

REQUIRE STR@        ~ac/lib/str5.f
REQUIRE base64      ~ac/lib/string/conv.f
REQUIRE URLENCODE2  ~ac/lib/string/urlencode.f 
REQUIRE SBetween    ~ac/lib/string/between.f 
REQUIRE HMAC-SHA1   ~ac/lib/lin/crypt/gcrypt.f 
REQUIRE UnixTime    ~ac/lib/win/date/unixtime.f 
REQUIRE POST-FILE   ~ac/lib/lin/curl/curlpost.f 

\ Перед первым вызовом функций надо выполнить GCryptInit.
\ Комплект задействованных DLL (gcrypt, curl и openssl для curl) около 3Мб!

: OAuth1RequestToken { cka cku csa csu urla urlu \ ut par -- ta tu tsa tsu }
  \ на входе строки consumer_key и consumer_secret
  \ (выдаваемые обычно при регистрации приложения у поставщика API сервиса)
  \ и URL сервиса ...oauth/request_token;
  \ на выходе oauth_token и oauth_token_secret, которыми на следующем
  \ шаге запрашивается разрешение пользователя на доступ к его данным;
  \ при сетевых ошибках (в CURL) выходные строки могут быть пустыми

  UnixTime -> ut \ например twitter сверяет время !
  ut
  csa csu + 1- C@ ut 2 / csa C@ " o4{n}{n}{n}" STR@ \ nonce
  cka cku 
  " oauth_consumer_key={s}&oauth_nonce={s}&oauth_signature_method=HMAC-SHA1&oauth_timestamp={n}&oauth_version=1.0"
  DUP -> par
  STR@ URLENCODE2
  urla urlu URLENCODE2
  " GET&{s}&{s}" STR@
  csa csu " {s}&" STR@ \ consumer_secret&token_secret
  HMAC-SHA1 base64 URLENCODE2
  " oauth_signature={s}" STR@
  par STR@ urla urlu " {s}?{s}&{s}" STR@
  GET-FILE STR@
  2DUP S" oauth_token=" S" &" SBetween
  2SWAP S" oauth_token_secret=" S" &" SBetween
;
: OAuth2AppToken { cia ciu csa csu urla urlu \ ut par -- ta tu }
  \ на входе client_id (app_id) и client_secret (app_secret)
  \ на выходе токен с полномочиями для доступа к самому приложению
  \ без прав доступа к пользовательским данным
  \ type=client_cred здесь вместо браузерного redirect_uri
  csa csu
  cia ciu
  urla urlu
  " {s}?type=client_cred&client_id={s}&client_secret={s}" STR@ GET-FILE STR@
  S" access_token=" S" &" SBetween
;
