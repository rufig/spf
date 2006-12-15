\ TODO:
\ http://msdn.microsoft.com/workshop/browser/hosting/wbcustomization.asp
\ http://www.codeguru.com/cpp/com-tech/atl/atl/article.php/c11007/

CAxControl SUBCLASS CWebBrowser

: className S" SHDocVw.InternetExplorer" ;

: create ( id parent-obj -- hwnd )
    className 2SWAP SUPER create
;

: goHome
    SUPER control @ [[ GoHome ]]
;

: navigate ( z-addr u )
    2>R
    SUPER control @ [[ Navigate ( 2R> STRING , 0 , 0 , 0 , 0 ) ]]
;

;CLASS