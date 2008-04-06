

CONCEIVE  
`NodeName & EXEC, `#comment SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`TRUE & EXEC,  BIRTH DUP `#comment NAMING- advice-rule-before
  

CONCEIVE  
`NodeName & EXEC, `#text SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NodeValue & EXEC, 
`T-PLAIN & EXEC, 
`TRUE & EXEC,  BIRTH DUP `#text NAMING- advice-rule-before
  

CONCEIVE  
`NodeName & EXEC, `forth SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`trans-childs & EXEC, 
`TRUE & EXEC,  BIRTH DUP `f:forth NAMING- advice-rule-before
  


 
CONCEIVE  
`NodeName & EXEC, `m SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`INC-M & EXEC, 
`trans-childs & EXEC, 
`DEC-M & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:m NAMING- advice-rule-before
  

CONCEIVE  
`NodeName & EXEC, `direct SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`M-DEC-STATE & EXEC, 
`trans-childs & EXEC, 
`M-INC-STATE & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:direct NAMING- advice-rule-before
  

CONCEIVE  
`NodeName & EXEC, `postpone SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`M-INC-STATE & EXEC, 
`trans-childs & EXEC, 
`M-DEC-STATE & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:postpone NAMING- advice-rule-before
  




CONCEIVE  
`NodeName & EXEC, `yield SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`trans-childs & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:yield NAMING- advice-rule-before
  




CONCEIVE  
`NodeName & EXEC, `get-attribute SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW `name SLIT, 
`GetAttribute & EXEC, 
`STATE & EXEC, 
`@ & EXEC, 
`TS-SLIT & EXEC, `GetAttribute & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, `T-SLIT & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:get-attribute NAMING- advice-rule-before
  


CONCEIVE  
`NodeName & EXEC, `get-name SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`GetName & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, `T-PAT & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:get-name NAMING- advice-rule-before
  





CONCEIVE  
`NodeName & EXEC, `for-each SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW `select SLIT, 
`GetAttribute & EXEC, 
`name-n-uri & EXEC, 
`2>R & EXEC, 
`STATE & EXEC, 
`@ & EXEC, 
`TS-SLIT & EXEC, 
`2R> & EXEC, 
`STATE & EXEC, 
`@ & EXEC, 
`TS-SLIT & EXEC, `cnode & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, `>R & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, `FirstChildByTagNameNS & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`DEC-S & EXEC, `MBW & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`INC-S & EXEC, `cnode & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`DEC-S & EXEC, `ZBFW2, & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`INC-S & EXEC, 
`trans-childs & EXEC, `NextSiblingEqualNS & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`DEC-S & EXEC, `BBW, & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, `RFW & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`INC-S & EXEC, `R> & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, `cnode! & LIT,  
`STATE & EXEC, 
`@ & EXEC, 
`TS-EXEC & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:for-each NAMING- advice-rule-before
  




CONCEIVE  
`NodeName & EXEC, `exit-fail SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 

`FALSE & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`EXIT, & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:exit-fail NAMING- advice-rule-before
  


CONCEIVE  
`NodeName & EXEC, `rule SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW 
`NamespaceURI & EXEC, `http://forth.org.ru/ForthML/Rules/ SLIT, 
`CEQUAL & EXEC, 
`0= & EXEC, ZBFW, 

`FALSE & EXEC, EXIT, 
RFW `match SLIT, 
`GetAttribute & EXEC, 
`name-n-uri & EXEC, 
`2>R & EXEC, 
`T-SLIT & EXEC, 
`2R> & EXEC, 
`T-SLIT & EXEC, 
`2SWAP & LIT,  `T-EXEC & EXEC, 
`CONCEIVE & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 
`NodeName & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`SLIT, & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 
`CEQUAL & LIT,  `T-EXEC & EXEC, 
`0= & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`ZBFW, & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 

`FALSE & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`EXIT, & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 

`M-DEC-STATE & EXEC, 
`RFW & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 
`NamespaceURI & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`SLIT, & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 
`CEQUAL & LIT,  `T-EXEC & EXEC, 
`0= & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`ZBFW, & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 

`FALSE & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`EXIT, & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 

`M-DEC-STATE & EXEC, 
`RFW & LIT,  `T-EXEC & EXEC, 
`M-INC-STATE & EXEC, 

`trans-childs & EXEC, 
`TRUE & LIT,  `T-EXEC & EXEC, 
`M-DEC-STATE & EXEC, 
`BIRTH & LIT,  `T-EXEC & EXEC, 
`DUP & LIT,  `T-EXEC & EXEC, `match SLIT, `T-SLIT & EXEC, 
`GetAttribute & LIT,  `T-EXEC & EXEC, 
`NAMING- & LIT,  `T-EXEC & EXEC, 
`advice-rule-before & LIT,  `T-EXEC & EXEC, 
`TRUE & EXEC,  BIRTH DUP `r:rule NAMING- advice-rule-before
  










 