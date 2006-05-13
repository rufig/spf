REQUIRE BEGIN-CONST ~day/wincons/compile.f

REQUIRE CONST ~micro/lib/const/const.f
REQUIRE ENUM ~ygrek/lib/enum.f
:NONAME DUP CONSTANT 1+ ; ENUM enum:

BEGIN-CONST
 common.f
 color.f
S" farplugin.const" SAVE-CONST

BYE