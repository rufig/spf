REQUIRE Object ~day\joop\oop.f

WINAPI: ChooseColorA COMDLG32.DLL

2 CONSTANT CC_FULLOPEN
1 CONSTANT CC_RGBINIT

pvar: <hwndOwner

CLASS: ColorDialog <SUPER Object

   RECORD: CHOOSECOLOR
	CELL VAR lStructSize
	CELL VAR hwndOwner
	CELL VAR hInstance
	CELL VAR rgbResult
          48 ARR lpCustColors
	CELL VAR flags
	CELL VAR lCustData
	CELL VAR lpfnHook
	CELL VAR lpTemplateName
  /REC	

: :new
    own :new
    size: CHOOSECOLOR lStructSize !
    CC_FULLOPEN CC_RGBINIT OR flags !
;

: :execute
   CHOOSECOLOR ChooseColorA
;

: :result
   rgbResult @
;

;CLASS

<< :execute
<< :result