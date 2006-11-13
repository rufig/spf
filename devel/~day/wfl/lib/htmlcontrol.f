

CAxControl SUBCLASS CWebBrowser

: create ( id parent )
    S" SHDocVw.InternetExplorer" 2SWAP SUPER create
;


: goHome
    SUPER control @ [[ GoHome ]]
;

: navigate ( z-addr u )
    2>R
    SUPER control @ [[ Navigate ( 2R> STRING , 0 , 0 , 0 , 0 ) ]]
;

;CLASS