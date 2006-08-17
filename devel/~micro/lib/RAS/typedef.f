: == CONSTANT ;

260 == MAX_PATH
256 == RAS_MaxEntryName
128 == RAS_MaxPhoneNumber
16 == RAS_MaxDeviceType
128 == RAS_MaxDeviceName
RAS_MaxPhoneNumber == RAS_MaxCallbackNumber
256 == UNLEN
256 == PWLEN
15 == CNLEN
CNLEN == DNLEN

: ~ DUP CONSTANT 1+ ;

MODULE: RASCONNSTATE
  0x1000 CONSTANT RASCS_PAUSED
  0x2000 CONSTANT RASCS_DONE
  
  0
  ~ RASCS_OpenPort
  ~ RASCS_PortOpened
  ~ RASCS_ConnectDevice
  ~ RASCS_DeviceConnected
  ~ RASCS_AllDevicesConnected
  ~ RASCS_Authenticate
  ~ RASCS_AuthNotify
  ~ RASCS_AuthRetry
  ~ RASCS_AuthCallback
  ~ RASCS_AuthChangePassword
  ~ RASCS_AuthProject
  ~ RASCS_AuthLinkSpeed
  ~ RASCS_AuthAck
  ~ RASCS_ReAuthenticate
  ~ RASCS_Authenticated
  ~ RASCS_PrepareForCallback
  ~ RASCS_WaitForModemReset
  ~ RASCS_WaitForCallback
  ~ RASCS_Projected
  ~ RASCS_StartAuthentication
  ~ RASCS_CallbackComplete
  ~ RASCS_LogonNetwork
  ~ RASCS_SubEntryConnected
  ~ RASCS_SubEntryDisconnected
  DROP
  
  RASCS_PAUSED
  ~ RASCS_Interactive
  ~ RASCS_RetryAuthentication
  ~ RASCS_CallbackSetByCaller
  ~ RASCS_PasswordExpired
  DROP
  
  RASCS_DONE
  ~ RASCS_Connected
  ~ RASCS_Disconnected
  DROP
;MODULE

0x10000 CONSTANT RASP_Amb
0x0803F CONSTANT RASP_PppNbf
0x0802B CONSTANT RASP_PppIpx
0x08021 CONSTANT RASP_PppIp
0x20000 CONSTANT RASP_Slip

MODULE: RASDIALPARAMS
  0
  CELL -- dwSize
  RAS_MaxEntryName 1+ -- szEntryName
  RAS_MaxPhoneNumber 1+ -- szPhoneNumber
  RAS_MaxCallbackNumber 1+ -- szCallbackNumber
  UNLEN 1+ -- szUserName
  PWLEN 1+ -- szPassword
  DNLEN 1+ -- szDomain
  CONSTANT structsize
;MODULE

MODULE: RASCONNSTATUS
  0
  CELL -- dwSize
  CELL -- rasconnstate
  CELL -- dwError
  RAS_MaxDeviceType 1+ -- szDeviceType
  RAS_MaxDeviceName 1+ -- szDeviceName
  2 +
  CONSTANT structsize
;MODULE

MODULE: RASCONN
  0
  CELL -- dwSize
  CELL -- hrasconn
  RAS_MaxEntryName 1+ -- szEntryName
  RAS_MaxDeviceType 1+ -- szDeviceType
  RAS_MaxDeviceName 1+ -- szDeviceName
\  MAX_PATH -- szPhoneBook
\  CELL -- dwSubEntry
\  16 -- guidEntry
  1+
  CONSTANT structsize
;MODULE
