\ Включаем/отключаем системные устройства (модем, камера, USB - устройства, ...)
\ Aug 2008
WINAPI: SetupDiEnumDeviceInfo Setupapi.dll
WINAPI: SetupDiGetClassDevsA Setupapi.dll
WINAPI: SetupDiDestroyDeviceInfoList Setupapi.dll
WINAPI: SetupDiGetDeviceRegistryPropertyA Setupapi.dll
WINAPI: SetupDiSetClassInstallParamsA Setupapi.dll
WINAPI: SetupDiCallClassInstaller Setupapi.dll

0 VALUE hDevInfo
CREATE DeviceInfoData 100 ALLOT
CREATE DeviceInfoData1 500 ALLOT
CREATE DeviceDesc 255 ALLOT

18 CONSTANT DIF_PROPERTYCHANGE
1 CONSTANT DICS_ENABLE
2 CONSTANT DICS_DISABLE
1 CONSTANT DICS_FLAG_GLOBAL
4 CONSTANT DIGCF_ALLCLASSES
2 CONSTANT DIGCF_PRESENT

0 CONSTANT SPDRP_DEVICEDESC
2 CONSTANT SPDRP_COMPATIBLEIDS
7 CONSTANT SPDRP_CLASS
8 CONSTANT SPDRP_CLASSGUID
0x16 CONSTANT SPDRP_ENUMERATOR_NAME
0x1 CONSTANT SPDRP_HARDWAREID
0x4 CONSTANT SPDRP_SERVICE
0x19 CONSTANT SPDRP_DEVTYPE
16 CONSTANT SPDRP_CAPABILITIES

\ =========== Структуры
0
CELL -- cbSize
CELL -- InstallFunction
CELL -- StateChange
CELL -- Scope
CELL -- HwProfile
CONSTANT /PSP_PROPCHANGE_PARAMS

CREATE PSP_PROPCHANGE_PARAMS /PSP_PROPCHANGE_PARAMS ALLOT

: init-psp-struct ( n -- )
PSP_PROPCHANGE_PARAMS StateChange !
DICS_FLAG_GLOBAL PSP_PROPCHANGE_PARAMS Scope !
DIF_PROPERTYCHANGE PSP_PROPCHANGE_PARAMS InstallFunction !
8 PSP_PROPCHANGE_PARAMS !
;

: _find-device
0
	BEGIN
		28 DeviceInfoData !
		DeviceInfoData OVER hDevInfo SetupDiEnumDeviceInfo
	WHILE
		HERE 500 DeviceInfoData1 HERE CELL+ SPDRP_DEVICEDESC \ SPDRP_SERVICE
		DeviceInfoData hDevInfo SetupDiGetDeviceRegistryPropertyA DROP
		DeviceInfoData1 ASCIIZ> DeviceDesc ASCIIZ>
		COMPARE 0=
		IF DROP TRUE EXIT THEN
		1+
	REPEAT
	DROP
	FALSE
;

: plug/unplag-device ( n adr n -- )
DeviceDesc SWAP CMOVE
init-psp-struct
DIGCF_PRESENT DIGCF_ALLCLASSES OR
0 0 0 SetupDiGetClassDevsA
DUP INVALID_HANDLE_VALUE =
IF
	ABORT" Invalid handle!"
ELSE
	TO hDevInfo
	_find-device
	IF
		/PSP_PROPCHANGE_PARAMS
		PSP_PROPCHANGE_PARAMS
		DeviceInfoData hDevInfo
		SetupDiSetClassInstallParamsA DROP

		DeviceInfoData hDevInfo DIF_PROPERTYCHANGE
		SetupDiCallClassInstaller DROP
	THEN
	hDevInfo SetupDiDestroyDeviceInfoList DROP
THEN
;
\EOF
: test
 DICS_DISABLE
\ DICS_ENABLE
\ S" Acer Crystal Eye webcam"
S" SD плата памяти"
plug/unplag-device
;
test
