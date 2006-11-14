
0 CONSTANT WFL

REQUIRE CASE         lib\ext\case.f

REQUIRE || ~day\hype3\locals.f

MODULE: COM

REQUIRE CLSCTX_LOCAL_SERVER ~yz/lib/automate.f

EXPORT

: [[ POSTPONE [[ ; IMMEDIATE

;MODULE


REQUIRE CString ~day\hype3\lib\string.f
REQUIRE CreateMsgProcessor ~day\wfl\lib\wfunc.f
REQUIRE ObjExtern ~day\wfl\lib\thunk.f
REQUIRE MENU      ~day\wfl\lib\menu.f
REQUIRE CRect     ~day\wfl\lib\misc.f
REQUIRE CDC          ~day\wfl\lib\gdi.f
REQUIRE ReflectNotifications ~day\wfl\lib\reflection.f

REQUIRE CMessageLoop ~day\wfl\lib\messageloop.f 

REQUIRE CWindow      ~day\wfl\lib\window.f

S" ~yz\cons\commctrl.const" ADD-CONST-VOC

REQUIRE CListView         ~day\wfl\lib\controls.f

REQUIRE DIALOG:      ~day\wfl\lib\dialogtemplates.f
REQUIRE CDialog      ~day\wfl\lib\dialog.f

REQUIRE CAXControl   ~day\wfl\lib\activex.f
REQUIRE CHTMLControl ~day\wfl\lib\htmlcontrol.f