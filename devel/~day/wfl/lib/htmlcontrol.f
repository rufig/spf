

CAxControl SUBCLASS CWebBrowser

: className S" SHDocVw.InternetExplorer" ;

: create ( id parent )
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