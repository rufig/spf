MODULE: WINSTRUCTS
STRUCT: ABC DROP
    0 ' ! ' @ propfield: abcA
    4 ' ! ' @ propfield: abcB
    8 ' ! ' @ propfield: abcC
12 ;STRUCT

STRUCT: ABCFLOAT DROP
    0 ' ! ' @ propfield: abcfA
    4 ' ! ' @ propfield: abcfB
    8 ' ! ' @ propfield: abcfC
12 ;STRUCT

STRUCT: ACCEL DROP
    0 ' C! ' C@ propfield: fVirt
    2 ' W! ' W@ propfield: key
    4 ' W! ' W@ propfield: cmd
6 ;STRUCT

STRUCT: ACE_HEADER DROP
    0 ' C! ' C@ propfield: AceType
    1 ' C! ' C@ propfield: AceFlags
    2 ' W! ' W@ propfield: AceSize
4 ;STRUCT

STRUCT: ACCESS_ALLOWED_ACE DROP
    0 ' Carr! ' Carr@ propfield: Header
    4 ' ! ' @ propfield: Mask
    8 ' ! ' @ propfield: SidStart
12 ;STRUCT

STRUCT: ACCESS_DENIED_ACE DROP
    0 ' Carr! ' Carr@ propfield: Header
    4 ' ! ' @ propfield: Mask
    8 ' ! ' @ propfield: SidStart
12 ;STRUCT

STRUCT: ACCESSTIMEOUT DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: iTimeOutMSec
12 ;STRUCT

STRUCT: ACL DROP
    0 ' C! ' C@ propfield: AclRevision
    1 ' C! ' C@ propfield: Sbz1
    2 ' W! ' W@ propfield: AclSize
    4 ' W! ' W@ propfield: AceCount
    6 ' W! ' W@ propfield: Sbz2
8 ;STRUCT

STRUCT: ACL_REVISION_INFORMATION DROP
    0 ' ! ' @ propfield: AclRevision
4 ;STRUCT

STRUCT: ACL_SIZE_INFORMATION DROP
    0 ' ! ' @ propfield: AceCount
    4 ' ! ' @ propfield: AclBytesInUse
    8 ' ! ' @ propfield: AclBytesFree
12 ;STRUCT

STRUCT: ACTION_HEADER DROP
    0 ' ! ' @ propfield: transport_id
    4 ' W! ' W@ propfield: action_code
    6 ' W! ' W@ propfield: reserved
8 ;STRUCT

STRUCT: ADAPTER_STATUS DROP
    0 ' Carr! ' Carr@ propfield: adapter_address
    6 ' C! ' C@ propfield: rev_major
    7 ' C! ' C@ propfield: reserved0
    8 ' C! ' C@ propfield: adapter_type
    9 ' C! ' C@ propfield: rev_minor
    10 ' W! ' W@ propfield: duration
    12 ' W! ' W@ propfield: frmr_recv
    14 ' W! ' W@ propfield: frmr_xmit
    16 ' W! ' W@ propfield: iframe_recv_err
    18 ' W! ' W@ propfield: xmit_aborts
    20 ' ! ' @ propfield: xmit_success
    24 ' ! ' @ propfield: recv_success
    28 ' W! ' W@ propfield: iframe_xmit_err
    30 ' W! ' W@ propfield: recv_buff_unavail
    32 ' W! ' W@ propfield: t1_timeouts
    34 ' W! ' W@ propfield: ti_timeouts
    36 ' ! ' @ propfield: reserved1
    40 ' W! ' W@ propfield: free_ncbs
    42 ' W! ' W@ propfield: max_cfg_ncbs
    44 ' W! ' W@ propfield: max_ncbs
    46 ' W! ' W@ propfield: xmit_buf_unavail
    48 ' W! ' W@ propfield: max_dgram_size
    50 ' W! ' W@ propfield: pending_sess
    52 ' W! ' W@ propfield: max_cfg_sess
    54 ' W! ' W@ propfield: max_sess
    56 ' W! ' W@ propfield: max_sess_pkt_size
    58 ' W! ' W@ propfield: name_count
60 ;STRUCT

STRUCT: ADDJOB_INFO_1 DROP
    0 ' ! ' @ propfield: Path
    4 ' ! ' @ propfield: JobId
8 ;STRUCT

STRUCT: ANIMATIONINFO DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: iMinAnimate
8 ;STRUCT

STRUCT: RECT DROP
    0 ' ! ' @ propfield: left
    4 ' ! ' @ propfield: top
    8 ' ! ' @ propfield: right
    12 ' ! ' @ propfield: bottom
16 ;STRUCT

STRUCT: RECTL DROP
    0 ' ! ' @ propfield: left
    4 ' ! ' @ propfield: top
    8 ' ! ' @ propfield: right
    12 ' ! ' @ propfield: bottom
16 ;STRUCT

STRUCT: APPBARDATA DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: hWnd
    8 ' ! ' @ propfield: uCallbackMessage
    12 ' ! ' @ propfield: uEdge
    16 ' Carr! ' Carr@ propfield: rc
    32 ' ! ' @ propfield: lParam
36 ;STRUCT

STRUCT: BITMAP DROP
    0 ' ! ' @ propfield: bmType
    4 ' ! ' @ propfield: bmWidth
    8 ' ! ' @ propfield: bmHeight
    12 ' ! ' @ propfield: bmWidthBytes
    16 ' W! ' W@ propfield: bmPlanes
    18 ' W! ' W@ propfield: bmBitsPixel
    20 ' ! ' @ propfield: bmBits
24 ;STRUCT

STRUCT: BITMAPCOREHEADER DROP
    0 ' ! ' @ propfield: bcSize
    4 ' W! ' W@ propfield: bcWidth
    6 ' W! ' W@ propfield: bcHeight
    8 ' W! ' W@ propfield: bcPlanes
    10 ' W! ' W@ propfield: bcBitCount
12 ;STRUCT

STRUCT: RGBTRIPLE DROP
    0 ' C! ' C@ propfield: rgbtBlue
    1 ' C! ' C@ propfield: rgbtGreen
    2 ' C! ' C@ propfield: rgbtRed
3 ;STRUCT

STRUCT: BITMAPCOREINFO DROP
    0 ' Carr! ' Carr@ propfield: bmciHeader
    12 ' Carr! ' Carr@ propfield: bmciColors
16 ;STRUCT

STRUCT: BITMAPFILEHEADER DROP
    0 ' W! ' W@ propfield: bfType
    2 ' ! ' @ propfield: bfSize
    6 ' W! ' W@ propfield: bfReserved1
    8 ' W! ' W@ propfield: bfReserved2
    10 ' ! ' @ propfield: bfOffBits
14 ;STRUCT

STRUCT: BITMAPINFOHEADER DROP
    0 ' ! ' @ propfield: biSize
    4 ' ! ' @ propfield: biWidth
    8 ' ! ' @ propfield: biHeight
    12 ' W! ' W@ propfield: biPlanes
    14 ' W! ' W@ propfield: biBitCount
    16 ' ! ' @ propfield: biCompression
    20 ' ! ' @ propfield: biSizeImage
    24 ' ! ' @ propfield: biXPelsPerMeter
    28 ' ! ' @ propfield: biYPelsPerMeter
    32 ' ! ' @ propfield: biClrUsed
    36 ' ! ' @ propfield: biClrImportant
40 ;STRUCT

STRUCT: RGBQUAD DROP
    0 ' C! ' C@ propfield: rgbBlue
    1 ' C! ' C@ propfield: rgbGreen
    2 ' C! ' C@ propfield: rgbRed
    3 ' C! ' C@ propfield: rgbReserved
4 ;STRUCT

STRUCT: BITMAPINFO DROP
    0 ' Carr! ' Carr@ propfield: bmiHeader
    40 ' Carr! ' Carr@ propfield: bmiColors
44 ;STRUCT

STRUCT: CIEXYZ DROP
    0 ' ! ' @ propfield: ciexyzX
    4 ' ! ' @ propfield: ciexyzY
    8 ' ! ' @ propfield: ciexyzZ
12 ;STRUCT

STRUCT: CIEXYZTRIPLE DROP
    0 ' Carr! ' Carr@ propfield: ciexyzRed
    12 ' Carr! ' Carr@ propfield: ciexyzGreen
    24 ' Carr! ' Carr@ propfield: ciexyzBlue
36 ;STRUCT

STRUCT: BITMAPV4HEADER DROP
    0 ' ! ' @ propfield: bV4Size
    4 ' ! ' @ propfield: bV4Width
    8 ' ! ' @ propfield: bV4Height
    12 ' W! ' W@ propfield: bV4Planes
    14 ' W! ' W@ propfield: bV4BitCount
    16 ' ! ' @ propfield: bV4V4Compression
    20 ' ! ' @ propfield: bV4SizeImage
    24 ' ! ' @ propfield: bV4XPelsPerMeter
    28 ' ! ' @ propfield: bV4YPelsPerMeter
    32 ' ! ' @ propfield: bV4ClrUsed
    36 ' ! ' @ propfield: bV4ClrImportant
    40 ' ! ' @ propfield: bV4RedMask
    44 ' ! ' @ propfield: bV4GreenMask
    48 ' ! ' @ propfield: bV4BlueMask
    52 ' ! ' @ propfield: bV4AlphaMask
    56 ' ! ' @ propfield: bV4CSType
    60 ' Carr! ' Carr@ propfield: bV4Endpoints
    96 ' ! ' @ propfield: bV4GammaRed
    100 ' ! ' @ propfield: bV4GammaGreen
    104 ' ! ' @ propfield: bV4GammaBlue
108 ;STRUCT

STRUCT: BLOB DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: pBlobData
8 ;STRUCT

STRUCT: SHITEMID DROP
    0 ' W! ' W@ propfield: cb
    2 ' C! ' C@ propfield: abID
3 ;STRUCT

STRUCT: ITEMIDLIST DROP
    0 ' Carr! ' Carr@ propfield: mkid
3 ;STRUCT

STRUCT: BROWSEINFO DROP
    0 ' ! ' @ propfield: hwndOwner
    4 ' ! ' @ propfield: pidlRoot
    8 ' ! ' @ propfield: pszDisplayName
    12 ' ! ' @ propfield: lpszTitle
    16 ' ! ' @ propfield: ulFlags
    20 ' ! ' @ propfield: lpfn
    24 ' ! ' @ propfield: lParam
    28 ' ! ' @ propfield: iImage
32 ;STRUCT

STRUCT: FILETIME DROP
    0 ' ! ' @ propfield: dwLowDateTime
    4 ' ! ' @ propfield: dwHighDateTime
8 ;STRUCT

STRUCT: BY_HANDLE_FILE_INFORMATION DROP
    0 ' ! ' @ propfield: dwFileAttributes
    4 ' Carr! ' Carr@ propfield: ftCreationTime
    12 ' Carr! ' Carr@ propfield: ftLastAccessTime
    20 ' Carr! ' Carr@ propfield: ftLastWriteTime
    28 ' ! ' @ propfield: dwVolumeSerialNumber
    32 ' ! ' @ propfield: nFileSizeHigh
    36 ' ! ' @ propfield: nFileSizeLow
    40 ' ! ' @ propfield: nNumberOfLinks
    44 ' ! ' @ propfield: nFileIndexHigh
    48 ' ! ' @ propfield: nFileIndexLow
52 ;STRUCT

STRUCT: FIXED DROP
    0 ' W! ' W@ propfield: fract
    2 ' W! ' W@ propfield: value
4 ;STRUCT

STRUCT: POINT DROP
    0 ' ! ' @ propfield: x
    4 ' ! ' @ propfield: y
8 ;STRUCT

STRUCT: POINTFX DROP
    0 ' Carr! ' Carr@ propfield: x
    4 ' Carr! ' Carr@ propfield: y
8 ;STRUCT

STRUCT: POINTL DROP
    0 ' ! ' @ propfield: x
    4 ' ! ' @ propfield: y
8 ;STRUCT

STRUCT: POINTS DROP
    0 ' W! ' W@ propfield: x
    2 ' W! ' W@ propfield: y
4 ;STRUCT

STRUCT: CANDIDATEFORM DROP
    0 ' ! ' @ propfield: dwIndex
    4 ' ! ' @ propfield: dwStyle
    8 ' Carr! ' Carr@ propfield: ptCurrentPos
    16 ' Carr! ' Carr@ propfield: rcArea
32 ;STRUCT

STRUCT: CANDIDATELIST DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwStyle
    8 ' ! ' @ propfield: dwCount
    12 ' ! ' @ propfield: dwSelection
    16 ' ! ' @ propfield: dwPageStart
    20 ' ! ' @ propfield: dwPageSize
    24 ' ! ' @ propfield: dwOffset
28 ;STRUCT

STRUCT: CREATESTRUCT DROP
    0 ' ! ' @ propfield: lpCreateParams
    4 ' ! ' @ propfield: hInstance
    8 ' ! ' @ propfield: hMenu
    12 ' ! ' @ propfield: hwndParent
    16 ' ! ' @ propfield: cy
    20 ' ! ' @ propfield: cx
    24 ' ! ' @ propfield: y
    28 ' ! ' @ propfield: x
    32 ' ! ' @ propfield: style
    36 ' ! ' @ propfield: lpszName
    40 ' ! ' @ propfield: lpszClass
    44 ' ! ' @ propfield: dwExStyle
48 ;STRUCT

STRUCT: CBT_CREATEWND DROP
    0 ' ! ' @ propfield: lpcs
    4 ' ! ' @ propfield: hwndInsertAfter
8 ;STRUCT

STRUCT: CBTACTIVATESTRUCT DROP
    0 ' ! ' @ propfield: fMouse
    4 ' ! ' @ propfield: hWndActive
8 ;STRUCT

STRUCT: CHAR_INFO DROP
    0 ' W! ' W@ propfield: Char
    2 ' W! ' W@ propfield: Attributes
4 ;STRUCT

STRUCT: CHARFORMAT DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwMask
    8 ' ! ' @ propfield: dwEffects
    12 ' ! ' @ propfield: yHeight
    16 ' ! ' @ propfield: yOffset
    20 ' ! ' @ propfield: crTextColor
    24 ' C! ' C@ propfield: bCharSet
    25 ' C! ' C@ propfield: bPitchAndFamily
    26 ' Carr! ' Carr@ propfield: szFaceName
60 ;STRUCT

STRUCT: CHARRANGE DROP
    0 ' ! ' @ propfield: cpMin
    4 ' ! ' @ propfield: cpMax
8 ;STRUCT

STRUCT: FONTSIGNATURE DROP
    0 ' arr! ' arr@ propfield: fsUsb
    16 ' arr! ' arr@ propfield: fsCsb
24 ;STRUCT

STRUCT: CHARSETINFO DROP
    0 ' ! ' @ propfield: ciCharset
    4 ' ! ' @ propfield: ciACP
    8 ' Carr! ' Carr@ propfield: fs
32 ;STRUCT

STRUCT: CHOOSECOLOR DROP
    0 ' ! ' @ propfield: lStructSize
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: hInstance
    12 ' ! ' @ propfield: rgbResult
    16 ' ! ' @ propfield: lpCustColors
    20 ' ! ' @ propfield: Flags
    24 ' ! ' @ propfield: lCustData
    28 ' ! ' @ propfield: lpfnHook
    32 ' ! ' @ propfield: lpTemplateName
36 ;STRUCT

STRUCT: LOGFONT DROP
    0 ' ! ' @ propfield: lfHeight
    4 ' ! ' @ propfield: lfWidth
    8 ' ! ' @ propfield: lfEscapement
    12 ' ! ' @ propfield: lfOrientation
    16 ' ! ' @ propfield: lfWeight
    20 ' C! ' C@ propfield: lfItalic
    21 ' C! ' C@ propfield: lfUnderline
    22 ' C! ' C@ propfield: lfStrikeOut
    23 ' C! ' C@ propfield: lfCharSet
    24 ' C! ' C@ propfield: lfOutPrecision
    25 ' C! ' C@ propfield: lfClipPrecision
    26 ' C! ' C@ propfield: lfQuality
    27 ' C! ' C@ propfield: lfPitchAndFamily
    28 ' Carr! ' Carr@ propfield: lfFaceName
60 ;STRUCT

STRUCT: CHOOSEFONT DROP
    0 ' ! ' @ propfield: lStructSize
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: hDC
    12 ' ! ' @ propfield: lpLogFont
    16 ' ! ' @ propfield: iPointSize
    20 ' ! ' @ propfield: Flags
    24 ' ! ' @ propfield: rgbColors
    28 ' ! ' @ propfield: lCustData
    32 ' ! ' @ propfield: lpfnHook
    36 ' ! ' @ propfield: lpTemplateName
    40 ' ! ' @ propfield: hInstance
    44 ' ! ' @ propfield: lpszStyle
    48 ' W! ' W@ propfield: nFontType
    50 ' W! ' W@ propfield: ___MISSING_ALIGNMENT__
    52 ' ! ' @ propfield: nSizeMin
    56 ' ! ' @ propfield: nSizeMax
60 ;STRUCT

STRUCT: CIDA DROP
    0 ' ! ' @ propfield: cidl
    4 ' ! ' @ propfield: aoffset
8 ;STRUCT

STRUCT: CLIENTCREATESTRUCT DROP
    0 ' ! ' @ propfield: hWindowMenu
    4 ' ! ' @ propfield: idFirstChild
8 ;STRUCT

STRUCT: CMINVOKECOMMANDINFO DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: fMask
    8 ' ! ' @ propfield: hwnd
    12 ' ! ' @ propfield: lpVerb
    16 ' ! ' @ propfield: lpParameters
    20 ' ! ' @ propfield: lpDirectory
    24 ' ! ' @ propfield: nShow
    28 ' ! ' @ propfield: dwHotKey
    32 ' ! ' @ propfield: hIcon
36 ;STRUCT

STRUCT: COLORADJUSTMENT DROP
    0 ' W! ' W@ propfield: caSize
    2 ' W! ' W@ propfield: caFlags
    4 ' W! ' W@ propfield: caIlluminantIndex
    6 ' W! ' W@ propfield: caRedGamma
    8 ' W! ' W@ propfield: caGreenGamma
    10 ' W! ' W@ propfield: caBlueGamma
    12 ' W! ' W@ propfield: caReferenceBlack
    14 ' W! ' W@ propfield: caReferenceWhite
    16 ' W! ' W@ propfield: caContrast
    18 ' W! ' W@ propfield: caBrightness
    20 ' W! ' W@ propfield: caColorfulness
    22 ' W! ' W@ propfield: caRedGreenTint
24 ;STRUCT

STRUCT: COLORMAP DROP
    0 ' ! ' @ propfield: from
    4 ' ! ' @ propfield: to
8 ;STRUCT

STRUCT: DCB DROP
    0 ' ! ' @ propfield: DCBlength
    4 ' ! ' @ propfield: BaudRate
    14 ' W! ' W@ propfield: XonLim
    16 ' W! ' W@ propfield: XoffLim
    18 ' C! ' C@ propfield: ByteSize
    19 ' C! ' C@ propfield: Parity
    20 ' C! ' C@ propfield: StopBits
    21 ' C! ' C@ propfield: XonChar
    22 ' C! ' C@ propfield: XoffChar
    23 ' C! ' C@ propfield: ErrorChar
    24 ' C! ' C@ propfield: EofChar
    25 ' C! ' C@ propfield: EvtChar
    26 ' W! ' W@ propfield: wReserved1
28 ;STRUCT

STRUCT: COMMCONFIG DROP
    0 ' ! ' @ propfield: dwSize
    4 ' W! ' W@ propfield: wVersion
    8 ' Carr! ' Carr@ propfield: dcb
    36 ' ! ' @ propfield: dwProviderSubType
    40 ' ! ' @ propfield: dwProviderOffset
    44 ' ! ' @ propfield: dwProviderSize
    48 ' W! ' W@ propfield: wcProviderData
52 ;STRUCT

STRUCT: COMMPROP DROP
    0 ' W! ' W@ propfield: wPacketLength
    2 ' W! ' W@ propfield: wPacketVersion
    4 ' ! ' @ propfield: dwServiceMask
    8 ' ! ' @ propfield: dwReserved1
    12 ' ! ' @ propfield: dwMaxTxQueue
    16 ' ! ' @ propfield: dwMaxRxQueue
    20 ' ! ' @ propfield: dwMaxBaud
    24 ' ! ' @ propfield: dwProvSubType
    28 ' ! ' @ propfield: dwProvCapabilities
    32 ' ! ' @ propfield: dwSettableParams
    36 ' ! ' @ propfield: dwSettableBaud
    40 ' W! ' W@ propfield: wSettableData
    42 ' W! ' W@ propfield: wSettableStopParity
    44 ' ! ' @ propfield: dwCurrentTxQueue
    48 ' ! ' @ propfield: dwCurrentRxQueue
    52 ' ! ' @ propfield: dwProvSpec1
    56 ' ! ' @ propfield: dwProvSpec2
    60 ' W! ' W@ propfield: wcProvChar
64 ;STRUCT

STRUCT: COMMTIMEOUTS DROP
    0 ' ! ' @ propfield: ReadIntervalTimeout
    4 ' ! ' @ propfield: ReadTotalTimeoutMultiplier
    8 ' ! ' @ propfield: ReadTotalTimeoutConstant
    12 ' ! ' @ propfield: WriteTotalTimeoutMultiplier
    16 ' ! ' @ propfield: WriteTotalTimeoutConstant
20 ;STRUCT

STRUCT: COMPAREITEMSTRUCT DROP
    0 ' ! ' @ propfield: CtlType
    4 ' ! ' @ propfield: CtlID
    8 ' ! ' @ propfield: hwndItem
    12 ' ! ' @ propfield: itemID1
    16 ' ! ' @ propfield: itemData1
    20 ' ! ' @ propfield: itemID2
    24 ' ! ' @ propfield: itemData2
32 ;STRUCT

STRUCT: COMPCOLOR DROP
    0 ' ! ' @ propfield: crText
    4 ' ! ' @ propfield: crBackground
    8 ' ! ' @ propfield: dwEffects
12 ;STRUCT

STRUCT: COMPOSITIONFORM DROP
    0 ' ! ' @ propfield: dwStyle
    4 ' Carr! ' Carr@ propfield: ptCurrentPos
    12 ' Carr! ' Carr@ propfield: rcArea
28 ;STRUCT

STRUCT: COMSTAT DROP
    4 ' ! ' @ propfield: cbInQue
    8 ' ! ' @ propfield: cbOutQue
12 ;STRUCT

STRUCT: CONSOLE_CURSOR_INFO DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: bVisible
8 ;STRUCT

STRUCT: COORD DROP
    0 ' W! ' W@ propfield: X
    2 ' W! ' W@ propfield: Y
4 ;STRUCT

STRUCT: SMALL_RECT DROP
    0 ' W! ' W@ propfield: Left
    2 ' W! ' W@ propfield: Top
    4 ' W! ' W@ propfield: Right
    6 ' W! ' W@ propfield: Bottom
8 ;STRUCT

STRUCT: CONSOLE_SCREEN_BUFFER_INFO DROP
    0 ' Carr! ' Carr@ propfield: dwSize
    4 ' Carr! ' Carr@ propfield: dwCursorPosition
    8 ' W! ' W@ propfield: wAttributes
    10 ' Carr! ' Carr@ propfield: srWindow
    18 ' Carr! ' Carr@ propfield: dwMaximumWindowSize
22 ;STRUCT

STRUCT: FLOATING_SAVE_AREA DROP
    0 ' ! ' @ propfield: ControlWord
    4 ' ! ' @ propfield: StatusWord
    8 ' ! ' @ propfield: TagWord
    12 ' ! ' @ propfield: ErrorOffset
    16 ' ! ' @ propfield: ErrorSelector
    20 ' ! ' @ propfield: DataOffset
    24 ' ! ' @ propfield: DataSelector
    28 ' Carr! ' Carr@ propfield: RegisterArea
    108 ' ! ' @ propfield: Cr0NpxState
112 ;STRUCT

STRUCT: CONTEXTcpu DROP
    0 ' ! ' @ propfield: ContextFlags
    4 ' ! ' @ propfield: Dr0
    8 ' ! ' @ propfield: Dr1
    12 ' ! ' @ propfield: Dr2
    16 ' ! ' @ propfield: Dr3
    20 ' ! ' @ propfield: Dr6
    24 ' ! ' @ propfield: Dr7
    28 ' Carr! ' Carr@ propfield: FloatSave
    140 ' ! ' @ propfield: SegGs
    144 ' ! ' @ propfield: SegFs
    148 ' ! ' @ propfield: SegEs
    152 ' ! ' @ propfield: SegDs
    156 ' ! ' @ propfield: Edi
    160 ' ! ' @ propfield: Esi
    164 ' ! ' @ propfield: Ebx
    168 ' ! ' @ propfield: Edx
    172 ' ! ' @ propfield: Ecx
    176 ' ! ' @ propfield: Eax
    180 ' ! ' @ propfield: Ebp
    184 ' ! ' @ propfield: Eip
    188 ' ! ' @ propfield: SegCs
    192 ' ! ' @ propfield: EFlags
    196 ' ! ' @ propfield: Esp
    200 ' ! ' @ propfield: SegSs
716 ;STRUCT

STRUCT: LIST_ENTRY DROP
    0 ' ! ' @ propfield: Flink
    4 ' ! ' @ propfield: Blink
8 ;STRUCT

STRUCT: CRITICAL_SECTION_DEBUG DROP
    0 ' W! ' W@ propfield: Type
    2 ' W! ' W@ propfield: CreatorBackTraceIndex
    4 ' ! ' @ propfield: CriticalSection
    8 ' Carr! ' Carr@ propfield: ProcessLocksList
    16 ' ! ' @ propfield: EntryCount
    20 ' ! ' @ propfield: ContentionCount
32 ;STRUCT

STRUCT: CRITICAL_SECTION DROP
    0 ' ! ' @ propfield: DebugInfo
    4 ' ! ' @ propfield: LockCount
    8 ' ! ' @ propfield: RecursionCount
    12 ' ! ' @ propfield: OwningThread
    16 ' ! ' @ propfield: LockSemaphore
24 ;STRUCT

STRUCT: SECURITY_QUALITY_OF_SERVICE DROP
    0 ' ! ' @ propfield: Length
    4 ' ! ' @ propfield: ImpersonationLevel
    8 ' ! ' @ propfield: ContextTrackingMode
    9 ' C! ' C@ propfield: EffectiveOnly
12 ;STRUCT

STRUCT: CONVCONTEXT DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: wFlags
    8 ' ! ' @ propfield: wCountryID
    12 ' ! ' @ propfield: iCodePage
    16 ' ! ' @ propfield: dwLangID
    20 ' ! ' @ propfield: dwSecurity
    24 ' Carr! ' Carr@ propfield: qos
36 ;STRUCT

STRUCT: CONVINFO DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: hUser
    8 ' ! ' @ propfield: hConvPartner
    12 ' ! ' @ propfield: hszSvcPartner
    16 ' ! ' @ propfield: hszServiceReq
    20 ' ! ' @ propfield: hszTopic
    24 ' ! ' @ propfield: hszItem
    28 ' ! ' @ propfield: wFmt
    32 ' ! ' @ propfield: wType
    36 ' ! ' @ propfield: wStatus
    40 ' ! ' @ propfield: wConvst
    44 ' ! ' @ propfield: wLastError
    48 ' ! ' @ propfield: hConvList
    52 ' Carr! ' Carr@ propfield: ConvCtxt
    88 ' ! ' @ propfield: hwnd
    92 ' ! ' @ propfield: hwndPartner
96 ;STRUCT

STRUCT: COPYDATASTRUCT DROP
    0 ' ! ' @ propfield: dwData
    4 ' ! ' @ propfield: cbData
    8 ' ! ' @ propfield: lpData
12 ;STRUCT

STRUCT: CPINFO DROP
    0 ' ! ' @ propfield: MaxCharSize
    4 ' Carr! ' Carr@ propfield: DefaultChar
    6 ' Carr! ' Carr@ propfield: LeadByte
20 ;STRUCT

STRUCT: CPLINFO DROP
    0 ' ! ' @ propfield: idIcon
    4 ' ! ' @ propfield: idName
    8 ' ! ' @ propfield: idInfo
    12 ' ! ' @ propfield: lData
16 ;STRUCT

STRUCT: CREATE_PROCESS_DEBUG_INFO DROP
    0 ' ! ' @ propfield: hFile
    4 ' ! ' @ propfield: hProcess
    8 ' ! ' @ propfield: hThread
    12 ' ! ' @ propfield: lpBaseOfImage
    16 ' ! ' @ propfield: dwDebugInfoFileOffset
    20 ' ! ' @ propfield: nDebugInfoSize
    24 ' ! ' @ propfield: lpThreadLocalBase
    28 ' ! ' @ propfield: lpStartAddress
    32 ' ! ' @ propfield: lpImageName
    36 ' W! ' W@ propfield: fUnicode
40 ;STRUCT

STRUCT: CREATE_THREAD_DEBUG_INFO DROP
    0 ' ! ' @ propfield: hThread
    4 ' ! ' @ propfield: lpThreadLocalBase
    8 ' ! ' @ propfield: lpStartAddress
12 ;STRUCT

STRUCT: CURRENCYFMT DROP
    0 ' ! ' @ propfield: NumDigits
    4 ' ! ' @ propfield: LeadingZero
    8 ' ! ' @ propfield: Grouping
    12 ' ! ' @ propfield: lpDecimalSep
    16 ' ! ' @ propfield: lpThousandSep
    20 ' ! ' @ propfield: NegativeOrder
    24 ' ! ' @ propfield: PositiveOrder
    28 ' ! ' @ propfield: lpCurrencySymbol
32 ;STRUCT

STRUCT: CURSORSHAPE DROP
    0 ' ! ' @ propfield: xHotSpot
    4 ' ! ' @ propfield: yHotSpot
    8 ' ! ' @ propfield: cx
    12 ' ! ' @ propfield: cy
    16 ' ! ' @ propfield: cbWidth
    20 ' C! ' C@ propfield: Planes
    21 ' C! ' C@ propfield: BitsPixel
24 ;STRUCT

STRUCT: CWPRETSTRUCT DROP
    0 ' ! ' @ propfield: lResult
    4 ' ! ' @ propfield: lParam
    8 ' ! ' @ propfield: wParam
    12 ' ! ' @ propfield: message
    16 ' ! ' @ propfield: hwnd
20 ;STRUCT

STRUCT: CWPSTRUCT DROP
    0 ' ! ' @ propfield: lParam
    4 ' ! ' @ propfield: wParam
    8 ' ! ' @ propfield: message
    12 ' ! ' @ propfield: hwnd
16 ;STRUCT

STRUCT: DATATYPES_INFO_1 DROP
    0 ' ! ' @ propfield: pName
4 ;STRUCT

STRUCT: DDEACK DROP
2 ;STRUCT

STRUCT: DDEADVISE DROP
    2 ' W! ' W@ propfield: cfFormat
4 ;STRUCT

STRUCT: DDEDATA DROP
    2 ' W! ' W@ propfield: cfFormat
    4 ' C! ' C@ propfield: Value
6 ;STRUCT

STRUCT: DDELN DROP
    2 ' W! ' W@ propfield: cfFormat
4 ;STRUCT

STRUCT: DDEML_MSG_HOOK_DATA DROP
    0 ' ! ' @ propfield: uiLo
    4 ' ! ' @ propfield: uiHi
    8 ' ! ' @ propfield: cbData
    12 ' arr! ' arr@ propfield: Data
44 ;STRUCT

STRUCT: DDEPOKE DROP
    2 ' W! ' W@ propfield: cfFormat
    4 ' C! ' C@ propfield: Value
6 ;STRUCT

STRUCT: DDEUP DROP
    2 ' W! ' W@ propfield: cfFormat
    4 ' C! ' C@ propfield: rgb
6 ;STRUCT

STRUCT: EXCEPTION_RECORD DROP
    0 ' ! ' @ propfield: ExceptionCode
    4 ' ! ' @ propfield: ExceptionFlags
    8 ' ! ' @ propfield: ExceptionRecord
    12 ' ! ' @ propfield: ExceptionAddress
    16 ' ! ' @ propfield: NumberParameters
    20 ' arr! ' arr@ propfield: ExceptionInformation
80 ;STRUCT

STRUCT: EXCEPTION_DEBUG_INFO DROP
    0 ' Carr! ' Carr@ propfield: ExceptionRecord
    80 ' ! ' @ propfield: dwFirstChance
84 ;STRUCT

STRUCT: EXIT_PROCESS_DEBUG_INFO DROP
    0 ' ! ' @ propfield: dwExitCode
4 ;STRUCT

STRUCT: EXIT_THREAD_DEBUG_INFO DROP
    0 ' ! ' @ propfield: dwExitCode
4 ;STRUCT

STRUCT: LOAD_DLL_DEBUG_INFO DROP
    0 ' ! ' @ propfield: hFile
    4 ' ! ' @ propfield: lpBaseOfDll
    8 ' ! ' @ propfield: dwDebugInfoFileOffset
    12 ' ! ' @ propfield: nDebugInfoSize
    16 ' ! ' @ propfield: lpImageName
    20 ' W! ' W@ propfield: fUnicode
24 ;STRUCT

STRUCT: UNLOAD_DLL_DEBUG_INFO DROP
    0 ' ! ' @ propfield: lpBaseOfDll
4 ;STRUCT

STRUCT: OUTPUT_DEBUG_STRING_INFO DROP
    0 ' ! ' @ propfield: lpDebugStringData
    4 ' W! ' W@ propfield: fUnicode
    6 ' W! ' W@ propfield: nDebugStringLength
8 ;STRUCT

STRUCT: RIP_INFO DROP
    0 ' ! ' @ propfield: dwError
    4 ' ! ' @ propfield: dwType
8 ;STRUCT

STRUCT: DEBUG_EVENT DROP
    0 ' ! ' @ propfield: dwDebugEventCode
    4 ' ! ' @ propfield: dwProcessId
    8 ' ! ' @ propfield: dwThreadId
96 ;STRUCT

STRUCT: DEBUGHOOKINFO DROP
    0 ' ! ' @ propfield: idThread
    4 ' ! ' @ propfield: idThreadInstaller
    8 ' ! ' @ propfield: lParam
    12 ' ! ' @ propfield: wParam
    16 ' ! ' @ propfield: code
20 ;STRUCT

STRUCT: DELETEITEMSTRUCT DROP
    0 ' ! ' @ propfield: CtlType
    4 ' ! ' @ propfield: CtlID
    8 ' ! ' @ propfield: itemID
    12 ' ! ' @ propfield: hwndItem
    16 ' ! ' @ propfield: itemData
20 ;STRUCT

STRUCT: DEV_BROADCAST_HDR DROP
    0 ' ! ' @ propfield: dbch_size
    4 ' ! ' @ propfield: dbch_devicetype
    8 ' ! ' @ propfield: dbch_reserved
12 ;STRUCT

STRUCT: DEV_BROADCAST_OEM DROP
    0 ' ! ' @ propfield: dbco_size
    4 ' ! ' @ propfield: dbco_devicetype
    8 ' ! ' @ propfield: dbco_reserved
    12 ' ! ' @ propfield: dbco_identifier
    16 ' ! ' @ propfield: dbco_suppfunc
20 ;STRUCT

STRUCT: DEV_BROADCAST_PORT DROP
    0 ' ! ' @ propfield: dbcp_size
    4 ' ! ' @ propfield: dbcp_devicetype
    8 ' ! ' @ propfield: dbcp_reserved
    12 ' C! ' C@ propfield: dbcp_name
16 ;STRUCT

STRUCT: DEV_BROADCAST_VOLUME DROP
    0 ' ! ' @ propfield: dbcv_size
    4 ' ! ' @ propfield: dbcv_devicetype
    8 ' ! ' @ propfield: dbcv_reserved
    12 ' ! ' @ propfield: dbcv_unitmask
    16 ' W! ' W@ propfield: dbcv_flags
20 ;STRUCT

STRUCT: DEVMODE DROP
    0 ' Carr! ' Carr@ propfield: dmDeviceName
    32 ' W! ' W@ propfield: dmSpecVersion
    34 ' W! ' W@ propfield: dmDriverVersion
    36 ' W! ' W@ propfield: dmSize
    38 ' W! ' W@ propfield: dmDriverExtra
    40 ' ! ' @ propfield: dmFields
    44 ' W! ' W@ propfield: dmOrientation
    46 ' W! ' W@ propfield: dmPaperSize
    48 ' W! ' W@ propfield: dmPaperLength
    50 ' W! ' W@ propfield: dmPaperWidth
    52 ' W! ' W@ propfield: dmScale
    54 ' W! ' W@ propfield: dmCopies
    56 ' W! ' W@ propfield: dmDefaultSource
    58 ' W! ' W@ propfield: dmPrintQuality
    60 ' W! ' W@ propfield: dmColor
    62 ' W! ' W@ propfield: dmDuplex
    64 ' W! ' W@ propfield: dmYResolution
    66 ' W! ' W@ propfield: dmTTOption
    68 ' W! ' W@ propfield: dmCollate
    70 ' Carr! ' Carr@ propfield: dmFormName
    102 ' W! ' W@ propfield: dmLogPixels
    104 ' ! ' @ propfield: dmBitsPerPel
    108 ' ! ' @ propfield: dmPelsWidth
    112 ' ! ' @ propfield: dmPelsHeight
    116 ' ! ' @ propfield: dmDisplayFlags
    120 ' ! ' @ propfield: dmDisplayFrequency
    124 ' ! ' @ propfield: dmICMMethod
    128 ' ! ' @ propfield: dmICMIntent
    132 ' ! ' @ propfield: dmMediaType
    136 ' ! ' @ propfield: dmDitherType
148 ;STRUCT

STRUCT: DEVNAMES DROP
    0 ' W! ' W@ propfield: wDriverOffset
    2 ' W! ' W@ propfield: wDeviceOffset
    4 ' W! ' W@ propfield: wOutputOffset
    6 ' W! ' W@ propfield: wDefault
8 ;STRUCT

STRUCT: DIBSECTION DROP
    0 ' Carr! ' Carr@ propfield: dsBm
    24 ' Carr! ' Carr@ propfield: dsBmih
    64 ' arr! ' arr@ propfield: dsBitfields
    76 ' ! ' @ propfield: dshSection
    80 ' ! ' @ propfield: dsOffset
84 ;STRUCT

STRUCT: LARGE_INTEGER DROP
    0 ' ! ' @ propfield: LowPart
    4 ' ! ' @ propfield: HighPart
8 ;STRUCT

STRUCT: DISK_GEOMETRY DROP
    0 ' Carr! ' Carr@ propfield: Cylinders
    8 ' ! ' @ propfield: MediaType
    12 ' ! ' @ propfield: TracksPerCylinder
    16 ' ! ' @ propfield: SectorsPerTrack
    20 ' ! ' @ propfield: BytesPerSector
24 ;STRUCT

STRUCT: DISK_PERFORMANCE DROP
    0 ' Carr! ' Carr@ propfield: BytesRead
    8 ' Carr! ' Carr@ propfield: BytesWritten
    16 ' Carr! ' Carr@ propfield: ReadTime
    24 ' Carr! ' Carr@ propfield: WriteTime
    32 ' ! ' @ propfield: ReadCount
    36 ' ! ' @ propfield: WriteCount
    40 ' ! ' @ propfield: QueueDepth
48 ;STRUCT

STRUCT: DLGITEMTEMPLATE DROP
    0 ' ! ' @ propfield: style
    4 ' ! ' @ propfield: dwExtendedStyle
    8 ' W! ' W@ propfield: x
    10 ' W! ' W@ propfield: y
    12 ' W! ' W@ propfield: cx
    14 ' W! ' W@ propfield: cy
    16 ' W! ' W@ propfield: id
18 ;STRUCT

STRUCT: DLGTEMPLATE DROP
    0 ' ! ' @ propfield: style
    4 ' ! ' @ propfield: dwExtendedStyle
    8 ' W! ' W@ propfield: cdit
    10 ' W! ' W@ propfield: x
    12 ' W! ' W@ propfield: y
    14 ' W! ' W@ propfield: cx
    16 ' W! ' W@ propfield: cy
18 ;STRUCT

STRUCT: DOC_INFO_1 DROP
    0 ' ! ' @ propfield: pDocName
    4 ' ! ' @ propfield: pOutputFile
    8 ' ! ' @ propfield: pDatatype
12 ;STRUCT

STRUCT: DOC_INFO_2 DROP
    0 ' ! ' @ propfield: pDocName
    4 ' ! ' @ propfield: pOutputFile
    8 ' ! ' @ propfield: pDatatype
    12 ' ! ' @ propfield: dwMode
    16 ' ! ' @ propfield: JobId
20 ;STRUCT

STRUCT: DOCINFO DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: lpszDocName
    8 ' ! ' @ propfield: lpszOutput
    12 ' ! ' @ propfield: lpszDatatype
    16 ' ! ' @ propfield: fwType
20 ;STRUCT

STRUCT: DRAGLISTINFO DROP
    0 ' ! ' @ propfield: uNotification
    4 ' ! ' @ propfield: hWnd
    8 ' Carr! ' Carr@ propfield: ptCursor
16 ;STRUCT

STRUCT: DRAWITEMSTRUCT DROP
    0 ' ! ' @ propfield: CtlType
    4 ' ! ' @ propfield: CtlID
    8 ' ! ' @ propfield: itemID
    12 ' ! ' @ propfield: itemAction
    16 ' ! ' @ propfield: itemState
    20 ' ! ' @ propfield: hwndItem
    24 ' ! ' @ propfield: hDC
    28 ' Carr! ' Carr@ propfield: rcItem
    44 ' ! ' @ propfield: itemData
48 ;STRUCT

STRUCT: DRAWTEXTPARAMS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: iTabLength
    8 ' ! ' @ propfield: iLeftMargin
    12 ' ! ' @ propfield: iRightMargin
    16 ' ! ' @ propfield: uiLengthDrawn
20 ;STRUCT

STRUCT: PARTITION_INFORMATION DROP
    24 ' C! ' C@ propfield: PartitionType
    25 ' C! ' C@ propfield: BootIndicator
    26 ' C! ' C@ propfield: RecognizedPartition
    27 ' C! ' C@ propfield: RewritePartition
    0 ' Carr! ' Carr@ propfield: StartingOffset
    8 ' Carr! ' Carr@ propfield: PartitionLength
    16 ' Carr! ' Carr@ propfield: HiddenSectors
32 ;STRUCT

STRUCT: DRIVE_LAYOUT_INFORMATION DROP
    0 ' ! ' @ propfield: PartitionCount
    4 ' ! ' @ propfield: Signature
    8 ' Carr! ' Carr@ propfield: PartitionEntry
40 ;STRUCT

STRUCT: DRIVER_INFO_1 DROP
    0 ' ! ' @ propfield: pName
4 ;STRUCT

STRUCT: DRIVER_INFO_2 DROP
    0 ' ! ' @ propfield: cVersion
    4 ' ! ' @ propfield: pName
    8 ' ! ' @ propfield: pEnvironment
    12 ' ! ' @ propfield: pDriverPath
    16 ' ! ' @ propfield: pDataFile
    20 ' ! ' @ propfield: pConfigFile
24 ;STRUCT

STRUCT: DRIVER_INFO_3 DROP
    0 ' ! ' @ propfield: cVersion
    4 ' ! ' @ propfield: pName
    8 ' ! ' @ propfield: pEnvironment
    12 ' ! ' @ propfield: pDriverPath
    16 ' ! ' @ propfield: pDataFile
    20 ' ! ' @ propfield: pConfigFile
    24 ' ! ' @ propfield: pHelpFile
    28 ' ! ' @ propfield: pDependentFiles
    32 ' ! ' @ propfield: pMonitorName
    36 ' ! ' @ propfield: pDefaultDataType
40 ;STRUCT

STRUCT: EDITSTREAM DROP
    0 ' ! ' @ propfield: dwCookie
    4 ' ! ' @ propfield: dwError
    8 ' ! ' @ propfield: pfnCallback
12 ;STRUCT

STRUCT: EMR DROP
    0 ' ! ' @ propfield: iType
    4 ' ! ' @ propfield: nSize
8 ;STRUCT

STRUCT: EMRANGLEARC DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptlCenter
    16 ' ! ' @ propfield: nRadius
    20 ' ! ' @ propfield: eStartAngle
    24 ' ! ' @ propfield: eSweepAngle
28 ;STRUCT

STRUCT: EMRARC DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBox
    24 ' Carr! ' Carr@ propfield: ptlStart
    32 ' Carr! ' Carr@ propfield: ptlEnd
40 ;STRUCT

STRUCT: EMRARCTO DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBox
    24 ' Carr! ' Carr@ propfield: ptlStart
    32 ' Carr! ' Carr@ propfield: ptlEnd
40 ;STRUCT

STRUCT: EMRCHORD DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBox
    24 ' Carr! ' Carr@ propfield: ptlStart
    32 ' Carr! ' Carr@ propfield: ptlEnd
40 ;STRUCT

STRUCT: EMRPIE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBox
    24 ' Carr! ' Carr@ propfield: ptlStart
    32 ' Carr! ' Carr@ propfield: ptlEnd
40 ;STRUCT

STRUCT: XFORM DROP
    0 ' ! ' @ propfield: eM11
    4 ' ! ' @ propfield: eM12
    8 ' ! ' @ propfield: eM21
    12 ' ! ' @ propfield: eM22
    16 ' ! ' @ propfield: eDx
    20 ' ! ' @ propfield: eDy
24 ;STRUCT

STRUCT: EMRBITBLT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: xDest
    28 ' ! ' @ propfield: yDest
    32 ' ! ' @ propfield: cxDest
    36 ' ! ' @ propfield: cyDest
    40 ' ! ' @ propfield: dwRop
    44 ' ! ' @ propfield: xSrc
    48 ' ! ' @ propfield: ySrc
    52 ' Carr! ' Carr@ propfield: xformSrc
    76 ' ! ' @ propfield: crBkColorSrc
    80 ' ! ' @ propfield: iUsageSrc
    84 ' ! ' @ propfield: offBmiSrc
    92 ' ! ' @ propfield: offBitsSrc
    96 ' ! ' @ propfield: cbBitsSrc
100 ;STRUCT

STRUCT: LOGBRUSH DROP
    0 ' ! ' @ propfield: lbStyle
    4 ' ! ' @ propfield: lbColor
    8 ' ! ' @ propfield: lbHatch
12 ;STRUCT

STRUCT: EMRCREATEBRUSHINDIRECT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihBrush
    12 ' Carr! ' Carr@ propfield: lb
24 ;STRUCT

STRUCT: LOGCOLORSPACE DROP
    0 ' ! ' @ propfield: lcsSignature
    4 ' ! ' @ propfield: lcsVersion
    8 ' ! ' @ propfield: lcsSize
    12 ' ! ' @ propfield: lcsCSType
    16 ' ! ' @ propfield: lcsIntent
    20 ' Carr! ' Carr@ propfield: lcsEndpoints
    56 ' ! ' @ propfield: lcsGammaRed
    60 ' ! ' @ propfield: lcsGammaGreen
    64 ' ! ' @ propfield: lcsGammaBlue
    68 ' Carr! ' Carr@ propfield: lcsFilename
328 ;STRUCT

STRUCT: EMRCREATECOLORSPACE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihCS
    12 ' Carr! ' Carr@ propfield: lcs
600 ;STRUCT

STRUCT: EMRCREATEDIBPATTERNBRUSHPT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihBrush
    12 ' ! ' @ propfield: iUsage
    16 ' ! ' @ propfield: offBmi
    20 ' ! ' @ propfield: cbBmi
    24 ' ! ' @ propfield: offBits
    28 ' ! ' @ propfield: cbBits
32 ;STRUCT

STRUCT: EMRCREATEMONOBRUSH DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihBrush
    12 ' ! ' @ propfield: iUsage
    16 ' ! ' @ propfield: offBmi
    20 ' ! ' @ propfield: cbBmi
    24 ' ! ' @ propfield: offBits
    28 ' ! ' @ propfield: cbBits
32 ;STRUCT

STRUCT: PALETTEENTRY DROP
    0 ' C! ' C@ propfield: peRed
    1 ' C! ' C@ propfield: peGreen
    2 ' C! ' C@ propfield: peBlue
    3 ' C! ' C@ propfield: peFlags
4 ;STRUCT

STRUCT: LOGPALETTE DROP
    0 ' W! ' W@ propfield: palVersion
    2 ' W! ' W@ propfield: palNumEntries
    4 ' Carr! ' Carr@ propfield: palPalEntry
8 ;STRUCT

STRUCT: EMRCREATEPALETTE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihPal
    12 ' Carr! ' Carr@ propfield: lgpl
20 ;STRUCT

STRUCT: LOGPEN DROP
    0 ' ! ' @ propfield: lopnStyle
    4 ' Carr! ' Carr@ propfield: lopnWidth
    12 ' ! ' @ propfield: lopnColor
16 ;STRUCT

STRUCT: EMRCREATEPEN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihPen
    12 ' Carr! ' Carr@ propfield: lopn
28 ;STRUCT

STRUCT: EMRELLIPSE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBox
24 ;STRUCT

STRUCT: EMRRECTANGLE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBox
24 ;STRUCT

STRUCT: EMREOF DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: nPalEntries
    12 ' ! ' @ propfield: offPalEntries
    16 ' ! ' @ propfield: nSizeLast
20 ;STRUCT

STRUCT: EMREXCLUDECLIPRECT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclClip
24 ;STRUCT

STRUCT: EMRINTERSECTCLIPRECT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclClip
24 ;STRUCT

STRUCT: PANOSE DROP
    0 ' C! ' C@ propfield: bFamilyType
    1 ' C! ' C@ propfield: bSerifStyle
    2 ' C! ' C@ propfield: bWeight
    3 ' C! ' C@ propfield: bProportion
    4 ' C! ' C@ propfield: bContrast
    5 ' C! ' C@ propfield: bStrokeVariation
    6 ' C! ' C@ propfield: bArmStyle
    7 ' C! ' C@ propfield: bLetterform
    8 ' C! ' C@ propfield: bMidline
    9 ' C! ' C@ propfield: bXHeight
10 ;STRUCT

STRUCT: EXTLOGFONT DROP
    0 ' Carr! ' Carr@ propfield: elfLogFont
    60 ' Carr! ' Carr@ propfield: elfFullName
    124 ' Carr! ' Carr@ propfield: elfStyle
    156 ' ! ' @ propfield: elfVersion
    160 ' ! ' @ propfield: elfStyleSize
    164 ' ! ' @ propfield: elfMatch
    168 ' ! ' @ propfield: elfReserved
    172 ' Carr! ' Carr@ propfield: elfVendorId
    176 ' ! ' @ propfield: elfCulture
    180 ' Carr! ' Carr@ propfield: elfPanose
192 ;STRUCT

STRUCT: EMREXTCREATEFONTINDIRECTW DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihFont
    12 ' Carr! ' Carr@ propfield: elfw
332 ;STRUCT

STRUCT: EXTLOGPEN DROP
    0 ' ! ' @ propfield: elpPenStyle
    4 ' ! ' @ propfield: elpWidth
    8 ' ! ' @ propfield: elpBrushStyle
    12 ' ! ' @ propfield: elpColor
    16 ' ! ' @ propfield: elpHatch
    20 ' ! ' @ propfield: elpNumEntries
    24 ' ! ' @ propfield: elpStyleEntry
28 ;STRUCT

STRUCT: EMREXTCREATEPEN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihPen
    12 ' ! ' @ propfield: offBmi
    16 ' ! ' @ propfield: cbBmi
    20 ' ! ' @ propfield: offBits
    24 ' ! ' @ propfield: cbBits
    28 ' Carr! ' Carr@ propfield: elp
56 ;STRUCT

STRUCT: EMREXTFLOODFILL DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptlStart
    16 ' ! ' @ propfield: crColor
    20 ' ! ' @ propfield: iMode
24 ;STRUCT

STRUCT: EMREXTSELECTCLIPRGN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: cbRgnData
    12 ' ! ' @ propfield: iMode
    16 ' C! ' C@ propfield: RgnData
20 ;STRUCT

STRUCT: EMRTEXT DROP
    0 ' Carr! ' Carr@ propfield: ptlReference
    8 ' ! ' @ propfield: nChars
    12 ' ! ' @ propfield: offString
    16 ' ! ' @ propfield: fOptions
    20 ' Carr! ' Carr@ propfield: rcl
    36 ' ! ' @ propfield: offDx
40 ;STRUCT

STRUCT: EMREXTTEXTOUTA DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: iGraphicsMode
    28 ' ! ' @ propfield: exScale
    32 ' ! ' @ propfield: eyScale
    36 ' Carr! ' Carr@ propfield: emrtext
76 ;STRUCT

STRUCT: EMREXTTEXTOUTW DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: iGraphicsMode
    28 ' ! ' @ propfield: exScale
    32 ' ! ' @ propfield: eyScale
    36 ' Carr! ' Carr@ propfield: emrtext
76 ;STRUCT

STRUCT: EMRFILLPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
24 ;STRUCT

STRUCT: EMRSTROKEANDFILLPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
24 ;STRUCT

STRUCT: EMRSTROKEPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
24 ;STRUCT

STRUCT: EMRFILLRGN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cbRgnData
    28 ' ! ' @ propfield: ihBrush
    32 ' C! ' C@ propfield: RgnData
36 ;STRUCT

STRUCT: EMRFORMAT DROP
    0 ' ! ' @ propfield: dSignature
    4 ' ! ' @ propfield: nVersion
    8 ' ! ' @ propfield: cbData
    12 ' ! ' @ propfield: offData
16 ;STRUCT

STRUCT: SIZE DROP
    0 ' ! ' @ propfield: cx
    4 ' ! ' @ propfield: cy
8 ;STRUCT

STRUCT: SIZEL DROP
    0 ' ! ' @ propfield: cx
    4 ' ! ' @ propfield: cy
8 ;STRUCT

STRUCT: EMRFRAMERGN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cbRgnData
    28 ' ! ' @ propfield: ihBrush
    32 ' Carr! ' Carr@ propfield: szlStroke
    40 ' C! ' C@ propfield: RgnData
44 ;STRUCT

STRUCT: EMRGDICOMMENT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: cbData
    12 ' C! ' C@ propfield: Data
16 ;STRUCT

STRUCT: EMRINVERTRGN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cbRgnData
    28 ' C! ' C@ propfield: RgnData
32 ;STRUCT

STRUCT: EMRPAINTRGN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cbRgnData
    28 ' C! ' C@ propfield: RgnData
32 ;STRUCT

STRUCT: EMRLINETO DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptl
16 ;STRUCT

STRUCT: EMRMOVETOEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptl
16 ;STRUCT

STRUCT: EMRMASKBLT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: xDest
    28 ' ! ' @ propfield: yDest
    32 ' ! ' @ propfield: cxDest
    36 ' ! ' @ propfield: cyDest
    40 ' ! ' @ propfield: dwRop
    44 ' ! ' @ propfield: xSrc
    48 ' ! ' @ propfield: ySrc
    52 ' Carr! ' Carr@ propfield: xformSrc
    76 ' ! ' @ propfield: crBkColorSrc
    80 ' ! ' @ propfield: iUsageSrc
    84 ' ! ' @ propfield: offBmiSrc
    88 ' ! ' @ propfield: cbBmiSrc
    92 ' ! ' @ propfield: offBitsSrc
    96 ' ! ' @ propfield: cbBitsSrc
    100 ' ! ' @ propfield: xMask
    104 ' ! ' @ propfield: yMask
    108 ' ! ' @ propfield: iUsageMask
    112 ' ! ' @ propfield: offBmiMask
    116 ' ! ' @ propfield: cbBmiMask
    120 ' ! ' @ propfield: offBitsMask
    124 ' ! ' @ propfield: cbBitsMask
128 ;STRUCT

STRUCT: EMRMODIFYWORLDTRANSFORM DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: xform
    32 ' ! ' @ propfield: iMode
36 ;STRUCT

STRUCT: EMROFFSETCLIPRGN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptlOffset
16 ;STRUCT

STRUCT: EMRPLGBLT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' Carr! ' Carr@ propfield: aptlDest
    48 ' ! ' @ propfield: xSrc
    52 ' ! ' @ propfield: ySrc
    56 ' ! ' @ propfield: cxSrc
    60 ' ! ' @ propfield: cySrc
    64 ' Carr! ' Carr@ propfield: xformSrc
    88 ' ! ' @ propfield: crBkColorSrc
    92 ' ! ' @ propfield: iUsageSrc
    96 ' ! ' @ propfield: offBmiSrc
    100 ' ! ' @ propfield: cbBmiSrc
    104 ' ! ' @ propfield: offBitsSrc
    108 ' ! ' @ propfield: cbBitsSrc
    112 ' ! ' @ propfield: xMask
    116 ' ! ' @ propfield: yMask
    120 ' ! ' @ propfield: iUsageMask
    124 ' ! ' @ propfield: offBmiMask
    128 ' ! ' @ propfield: cbBmiMask
    132 ' ! ' @ propfield: offBitsMask
    136 ' ! ' @ propfield: cbBitsMask
140 ;STRUCT

STRUCT: EMRPOLYDRAW DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cptl
    28 ' Carr! ' Carr@ propfield: aptl
    36 ' C! ' C@ propfield: abTypes
40 ;STRUCT

STRUCT: EMRPOLYDRAW16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cpts
    28 ' Carr! ' Carr@ propfield: apts
    32 ' C! ' C@ propfield: abTypes
36 ;STRUCT

STRUCT: EMRPOLYLINE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cptl
    28 ' Carr! ' Carr@ propfield: aptl
36 ;STRUCT

STRUCT: EMRPOLYBEZIER DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cptl
    28 ' Carr! ' Carr@ propfield: aptl
36 ;STRUCT

STRUCT: EMRPOLYGON DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cptl
    28 ' Carr! ' Carr@ propfield: aptl
36 ;STRUCT

STRUCT: EMRPOLYBEZIERTO DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cptl
    28 ' Carr! ' Carr@ propfield: aptl
36 ;STRUCT

STRUCT: EMRPOLYLINETO DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cptl
    28 ' Carr! ' Carr@ propfield: aptl
36 ;STRUCT

STRUCT: EMRPOLYLINE16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cpts
    28 ' Carr! ' Carr@ propfield: apts
32 ;STRUCT

STRUCT: EMRPOLYBEZIER16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cpts
    28 ' Carr! ' Carr@ propfield: apts
32 ;STRUCT

STRUCT: EMRPOLYGON16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cpts
    28 ' Carr! ' Carr@ propfield: apts
32 ;STRUCT

STRUCT: EMRPOLYBEZIERTO16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cpts
    28 ' Carr! ' Carr@ propfield: apts
32 ;STRUCT

STRUCT: EMRPOLYLINETO16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: cpts
    28 ' Carr! ' Carr@ propfield: apts
32 ;STRUCT

STRUCT: EMRPOLYPOLYLINE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: nPolys
    28 ' ! ' @ propfield: cptl
    32 ' ! ' @ propfield: aPolyCounts
    36 ' Carr! ' Carr@ propfield: aptl
44 ;STRUCT

STRUCT: EMRPOLYPOLYGON DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: nPolys
    28 ' ! ' @ propfield: cptl
    32 ' ! ' @ propfield: aPolyCounts
    36 ' Carr! ' Carr@ propfield: aptl
44 ;STRUCT

STRUCT: EMRPOLYPOLYLINE16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: nPolys
    28 ' ! ' @ propfield: cpts
    32 ' ! ' @ propfield: aPolyCounts
    36 ' Carr! ' Carr@ propfield: apts
40 ;STRUCT

STRUCT: EMRPOLYPOLYGON16 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: nPolys
    28 ' ! ' @ propfield: cpts
    32 ' ! ' @ propfield: aPolyCounts
    36 ' Carr! ' Carr@ propfield: apts
40 ;STRUCT

STRUCT: EMRPOLYTEXTOUTA DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: iGraphicsMode
    28 ' ! ' @ propfield: exScale
    32 ' ! ' @ propfield: eyScale
    36 ' ! ' @ propfield: cStrings
    40 ' Carr! ' Carr@ propfield: aemrtext
80 ;STRUCT

STRUCT: EMRPOLYTEXTOUTW DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: iGraphicsMode
    28 ' ! ' @ propfield: exScale
    32 ' ! ' @ propfield: eyScale
    36 ' ! ' @ propfield: cStrings
    40 ' Carr! ' Carr@ propfield: aemrtext
80 ;STRUCT

STRUCT: EMRRESIZEPALETTE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihPal
    12 ' ! ' @ propfield: cEntries
16 ;STRUCT

STRUCT: EMRRESTOREDC DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iRelative
12 ;STRUCT

STRUCT: EMRROUNDRECT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBox
    24 ' Carr! ' Carr@ propfield: szlCorner
32 ;STRUCT

STRUCT: EMRSCALEVIEWPORTEXTEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: xNum
    12 ' ! ' @ propfield: xDenom
    16 ' ! ' @ propfield: yNum
    20 ' ! ' @ propfield: yDenom
24 ;STRUCT

STRUCT: EMRSCALEWINDOWEXTEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: xNum
    12 ' ! ' @ propfield: xDenom
    16 ' ! ' @ propfield: yNum
    20 ' ! ' @ propfield: yDenom
24 ;STRUCT

STRUCT: EMRSELECTCOLORSPACE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihCS
12 ;STRUCT

STRUCT: EMRDELETECOLORSPACE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihCS
12 ;STRUCT

STRUCT: EMRSELECTOBJECT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihObject
12 ;STRUCT

STRUCT: EMRDELETEOBJECT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihObject
12 ;STRUCT

STRUCT: EMRSELECTPALETTE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihPal
12 ;STRUCT

STRUCT: EMRSETARCDIRECTION DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iArcDirection
12 ;STRUCT

STRUCT: EMRSETBKCOLOR DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: crColor
12 ;STRUCT

STRUCT: EMRSETTEXTCOLOR DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: crColor
12 ;STRUCT

STRUCT: EMRSETCOLORADJUSTMENT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ColorAdjustment
32 ;STRUCT

STRUCT: EMRSETDIBITSTODEVICE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: xDest
    28 ' ! ' @ propfield: yDest
    32 ' ! ' @ propfield: xSrc
    36 ' ! ' @ propfield: ySrc
    40 ' ! ' @ propfield: cxSrc
    44 ' ! ' @ propfield: cySrc
    48 ' ! ' @ propfield: offBmiSrc
    52 ' ! ' @ propfield: cbBmiSrc
    56 ' ! ' @ propfield: offBitsSrc
    60 ' ! ' @ propfield: cbBitsSrc
    64 ' ! ' @ propfield: iUsageSrc
    68 ' ! ' @ propfield: iStartScan
    72 ' ! ' @ propfield: cScans
76 ;STRUCT

STRUCT: EMRSETMAPPERFLAGS DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: dwFlags
12 ;STRUCT

STRUCT: EMRSETMITERLIMIT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: eMiterLimit
12 ;STRUCT

STRUCT: EMRSETPALETTEENTRIES DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: ihPal
    12 ' ! ' @ propfield: iStart
    16 ' ! ' @ propfield: cEntries
    20 ' Carr! ' Carr@ propfield: aPalEntries
24 ;STRUCT

STRUCT: EMRSETPIXELV DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptlPixel
    16 ' ! ' @ propfield: crColor
20 ;STRUCT

STRUCT: EMRSETVIEWPORTEXTEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: szlExtent
16 ;STRUCT

STRUCT: EMRSETWINDOWEXTEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: szlExtent
16 ;STRUCT

STRUCT: EMRSETVIEWPORTORGEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptlOrigin
16 ;STRUCT

STRUCT: EMRSETWINDOWORGEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptlOrigin
16 ;STRUCT

STRUCT: EMRSETBRUSHORGEX DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: ptlOrigin
16 ;STRUCT

STRUCT: EMRSETWORLDTRANSFORM DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: xform
32 ;STRUCT

STRUCT: EMRSTRETCHBLT DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: xDest
    28 ' ! ' @ propfield: yDest
    32 ' ! ' @ propfield: cxDest
    36 ' ! ' @ propfield: cyDest
    40 ' ! ' @ propfield: dwRop
    44 ' ! ' @ propfield: xSrc
    48 ' ! ' @ propfield: ySrc
    52 ' Carr! ' Carr@ propfield: xformSrc
    76 ' ! ' @ propfield: crBkColorSrc
    80 ' ! ' @ propfield: iUsageSrc
    84 ' ! ' @ propfield: offBmiSrc
    88 ' ! ' @ propfield: cbBmiSrc
    92 ' ! ' @ propfield: offBitsSrc
    96 ' ! ' @ propfield: cbBitsSrc
    100 ' ! ' @ propfield: cxSrc
    104 ' ! ' @ propfield: cySrc
108 ;STRUCT

STRUCT: EMRSTRETCHDIBITS DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' ! ' @ propfield: xDest
    28 ' ! ' @ propfield: yDest
    32 ' ! ' @ propfield: xSrc
    36 ' ! ' @ propfield: ySrc
    40 ' ! ' @ propfield: cxSrc
    44 ' ! ' @ propfield: cySrc
    48 ' ! ' @ propfield: offBmiSrc
    52 ' ! ' @ propfield: cbBmiSrc
    56 ' ! ' @ propfield: offBitsSrc
    60 ' ! ' @ propfield: cbBitsSrc
    64 ' ! ' @ propfield: iUsageSrc
    68 ' ! ' @ propfield: dwRop
    72 ' ! ' @ propfield: cxDest
    76 ' ! ' @ propfield: cyDest
80 ;STRUCT

STRUCT: EMRABORTPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRBEGINPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRENDPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRCLOSEFIGURE DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRFLATTENPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRWIDENPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRSETMETARGN DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRSAVEDC DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRREALIZEPALETTE DROP
    0 ' Carr! ' Carr@ propfield: emr
8 ;STRUCT

STRUCT: EMRSELECTCLIPPATH DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iMode
12 ;STRUCT

STRUCT: EMRSETBKMODE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iMode
12 ;STRUCT

STRUCT: EMRSETMAPMODE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iMode
12 ;STRUCT

STRUCT: EMRSETPOLYFILLMODE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iMode
12 ;STRUCT

STRUCT: EMRSETROP2 DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iMode
12 ;STRUCT

STRUCT: EMRSETSTRETCHBLTMODE DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iMode
12 ;STRUCT

STRUCT: EMRSETTEXTALIGN DROP
    0 ' Carr! ' Carr@ propfield: emr
    8 ' ! ' @ propfield: iMode
12 ;STRUCT

STRUCT: NMHDR DROP
    0 ' ! ' @ propfield: hwndFrom
    4 ' ! ' @ propfield: idFrom
    8 ' ! ' @ propfield: code
12 ;STRUCT

STRUCT: ENCORRECTTEXT DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' Carr! ' Carr@ propfield: chrg
    20 ' W! ' W@ propfield: seltyp
24 ;STRUCT

STRUCT: ENDROPFILES DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' ! ' @ propfield: hDrop
    16 ' ! ' @ propfield: cp
    20 ' ! ' @ propfield: fProtected
24 ;STRUCT

STRUCT: ENSAVECLIPBOARD DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' ! ' @ propfield: cObjectCount
    16 ' ! ' @ propfield: cch
20 ;STRUCT

STRUCT: ENOLEOPFAILED DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' ! ' @ propfield: iob
    16 ' ! ' @ propfield: lOper
    20 ' ! ' @ propfield: hr
24 ;STRUCT

STRUCT: ENHMETAHEADER DROP
    0 ' ! ' @ propfield: iType
    4 ' ! ' @ propfield: nSize
    8 ' Carr! ' Carr@ propfield: rclBounds
    24 ' Carr! ' Carr@ propfield: rclFrame
    40 ' ! ' @ propfield: dSignature
    44 ' ! ' @ propfield: nVersion
    48 ' ! ' @ propfield: nBytes
    52 ' ! ' @ propfield: nRecords
    56 ' W! ' W@ propfield: nHandles
    58 ' W! ' W@ propfield: sReserved
    60 ' ! ' @ propfield: nDescription
    64 ' ! ' @ propfield: offDescription
    68 ' ! ' @ propfield: nPalEntries
    72 ' Carr! ' Carr@ propfield: szlDevice
    80 ' Carr! ' Carr@ propfield: szlMillimeters
100 ;STRUCT

STRUCT: ENHMETARECORD DROP
    0 ' ! ' @ propfield: iType
    4 ' ! ' @ propfield: nSize
    8 ' ! ' @ propfield: dParm
12 ;STRUCT

STRUCT: ENPROTECTED DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' ! ' @ propfield: msg
    16 ' ! ' @ propfield: wParam
    20 ' ! ' @ propfield: lParam
    24 ' Carr! ' Carr@ propfield: chrg
32 ;STRUCT

STRUCT: SERVICE_STATUS DROP
    0 ' ! ' @ propfield: dwServiceType
    4 ' ! ' @ propfield: dwCurrentState
    8 ' ! ' @ propfield: dwControlsAccepted
    12 ' ! ' @ propfield: dwWin32ExitCode
    16 ' ! ' @ propfield: dwServiceSpecificExitCode
    20 ' ! ' @ propfield: dwCheckPoint
    24 ' ! ' @ propfield: dwWaitHint
28 ;STRUCT

STRUCT: ENUM_SERVICE_STATUS DROP
    0 ' ! ' @ propfield: lpServiceName
    4 ' ! ' @ propfield: lpDisplayName
    8 ' Carr! ' Carr@ propfield: ServiceStatus
36 ;STRUCT

STRUCT: ENUMLOGFONT DROP
    0 ' Carr! ' Carr@ propfield: elfLogFont
    60 ' Carr! ' Carr@ propfield: elfFullName
    124 ' Carr! ' Carr@ propfield: elfStyle
156 ;STRUCT

STRUCT: ENUMLOGFONTEX DROP
    0 ' Carr! ' Carr@ propfield: elfLogFont
    60 ' Carr! ' Carr@ propfield: elfFullName
    124 ' Carr! ' Carr@ propfield: elfStyle
    156 ' Carr! ' Carr@ propfield: elfScript
188 ;STRUCT

STRUCT: EVENTLOGRECORD DROP
    0 ' ! ' @ propfield: Length
    4 ' ! ' @ propfield: Reserved
    8 ' ! ' @ propfield: RecordNumber
    12 ' ! ' @ propfield: TimeGenerated
    16 ' ! ' @ propfield: TimeWritten
    20 ' ! ' @ propfield: EventID
    24 ' W! ' W@ propfield: EventType
    26 ' W! ' W@ propfield: NumStrings
    28 ' W! ' W@ propfield: EventCategory
    30 ' W! ' W@ propfield: ReservedFlags
    32 ' ! ' @ propfield: ClosingRecordNumber
    36 ' ! ' @ propfield: StringOffset
    40 ' ! ' @ propfield: UserSidLength
    44 ' ! ' @ propfield: UserSidOffset
    48 ' ! ' @ propfield: DataLength
    52 ' ! ' @ propfield: DataOffset
56 ;STRUCT

STRUCT: EVENTMSG DROP
    0 ' ! ' @ propfield: message
    4 ' ! ' @ propfield: paramL
    8 ' ! ' @ propfield: paramH
    12 ' ! ' @ propfield: time
    16 ' ! ' @ propfield: hwnd
20 ;STRUCT

STRUCT: EXCEPTION_POINTERS DROP
    0 ' ! ' @ propfield: ExceptionRecord
    4 ' ! ' @ propfield: ContextRecord
8 ;STRUCT

STRUCT: EXT_BUTTON DROP
    0 ' W! ' W@ propfield: idCommand
    2 ' W! ' W@ propfield: idsHelp
    4 ' W! ' W@ propfield: fsStyle
6 ;STRUCT

STRUCT: FILTERKEYS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: iWaitMSec
    12 ' ! ' @ propfield: iDelayMSec
    16 ' ! ' @ propfield: iRepeatMSec
    20 ' ! ' @ propfield: iBounceMSec
24 ;STRUCT

STRUCT: FIND_NAME_BUFFER DROP
    0 ' C! ' C@ propfield: length
    1 ' C! ' C@ propfield: access_control
    2 ' C! ' C@ propfield: frame_control
    3 ' Carr! ' Carr@ propfield: destination_addr
    9 ' Carr! ' Carr@ propfield: source_addr
    15 ' Carr! ' Carr@ propfield: routing_info
33 ;STRUCT

STRUCT: FIND_NAME_HEADER DROP
    0 ' W! ' W@ propfield: node_count
    2 ' C! ' C@ propfield: reserved
    3 ' C! ' C@ propfield: unique_group
4 ;STRUCT

STRUCT: FINDREPLACE DROP
    0 ' ! ' @ propfield: lStructSize
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: hInstance
    12 ' ! ' @ propfield: Flags
    16 ' ! ' @ propfield: lpstrFindWhat
    20 ' ! ' @ propfield: lpstrReplaceWith
    24 ' W! ' W@ propfield: wFindWhatLen
    26 ' W! ' W@ propfield: wReplaceWithLen
    28 ' ! ' @ propfield: lCustData
    32 ' ! ' @ propfield: lpfnHook
    36 ' ! ' @ propfield: lpTemplateName
40 ;STRUCT

STRUCT: FINDTEXT DROP
    0 ' Carr! ' Carr@ propfield: chrg
    8 ' ! ' @ propfield: lpstrText
12 ;STRUCT

STRUCT: FINDTEXTEX DROP
    0 ' Carr! ' Carr@ propfield: chrg
    8 ' ! ' @ propfield: lpstrText
    12 ' Carr! ' Carr@ propfield: chrgText
20 ;STRUCT

STRUCT: FMS_GETDRIVEINFO DROP
    0 ' ! ' @ propfield: dwTotalSpace
    4 ' ! ' @ propfield: dwFreeSpace
    8 ' Carr! ' Carr@ propfield: szPath
    268 ' Carr! ' Carr@ propfield: szVolume
    282 ' Carr! ' Carr@ propfield: szShare
412 ;STRUCT

STRUCT: FMS_GETFILESEL DROP
    0 ' Carr! ' Carr@ propfield: ftTime
    8 ' ! ' @ propfield: dwSize
    12 ' C! ' C@ propfield: bAttr
    13 ' Carr! ' Carr@ propfield: szName
276 ;STRUCT

STRUCT: FMS_LOAD DROP
    0 ' ! ' @ propfield: dwSize
    4 ' Carr! ' Carr@ propfield: szMenuName
    44 ' ! ' @ propfield: hMenu
    48 ' ! ' @ propfield: wMenuDelta
52 ;STRUCT

STRUCT: FMS_TOOLBARLOAD DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: lpButtons
    8 ' W! ' W@ propfield: cButtons
    10 ' W! ' W@ propfield: cBitmaps
    12 ' W! ' W@ propfield: idBitmap
    16 ' ! ' @ propfield: hBitmap
20 ;STRUCT

STRUCT: FOCUS_EVENT_RECORD DROP
    0 ' ! ' @ propfield: bSetFocus
4 ;STRUCT

STRUCT: FORM_INFO_1 DROP
    0 ' ! ' @ propfield: Flags
    4 ' ! ' @ propfield: pName
    8 ' Carr! ' Carr@ propfield: Size
    16 ' Carr! ' Carr@ propfield: ImageableArea
32 ;STRUCT

STRUCT: FORMAT_PARAMETERS DROP
    0 ' ! ' @ propfield: MediaType
    4 ' ! ' @ propfield: StartCylinderNumber
    8 ' ! ' @ propfield: EndCylinderNumber
    12 ' ! ' @ propfield: StartHeadNumber
    16 ' ! ' @ propfield: EndHeadNumber
20 ;STRUCT

STRUCT: FORMATRANGE DROP
    0 ' ! ' @ propfield: hdc
    4 ' ! ' @ propfield: hdcTarget
    8 ' Carr! ' Carr@ propfield: rc
    24 ' Carr! ' Carr@ propfield: rcPage
    40 ' Carr! ' Carr@ propfield: chrg
48 ;STRUCT

STRUCT: GCP_RESULTS DROP
    0 ' ! ' @ propfield: lStructSize
    4 ' ! ' @ propfield: lpOutString
    8 ' ! ' @ propfield: lpOrder
    12 ' ! ' @ propfield: lpDx
    16 ' ! ' @ propfield: lpCaretPos
    20 ' ! ' @ propfield: lpClass
    24 ' ! ' @ propfield: lpGlyphs
    28 ' ! ' @ propfield: nGlyphs
    32 ' ! ' @ propfield: nMaxFit
36 ;STRUCT

STRUCT: GENERIC_MAPPING DROP
    0 ' ! ' @ propfield: GenericRead
    4 ' ! ' @ propfield: GenericWrite
    8 ' ! ' @ propfield: GenericExecute
    12 ' ! ' @ propfield: GenericAll
16 ;STRUCT

STRUCT: GLYPHMETRICS DROP
    0 ' ! ' @ propfield: gmBlackBoxX
    4 ' ! ' @ propfield: gmBlackBoxY
    8 ' Carr! ' Carr@ propfield: gmptGlyphOrigin
    16 ' W! ' W@ propfield: gmCellIncX
    18 ' W! ' W@ propfield: gmCellIncY
20 ;STRUCT

STRUCT: HANDLETABLE DROP
    0 ' ! ' @ propfield: objectHandle
4 ;STRUCT

STRUCT: HD_HITTESTINFO DROP
    0 ' Carr! ' Carr@ propfield: pt
    8 ' ! ' @ propfield: flags
    12 ' ! ' @ propfield: iItem
16 ;STRUCT

STRUCT: HD_ITEM DROP
    0 ' ! ' @ propfield: mask
    4 ' ! ' @ propfield: cxy
    8 ' ! ' @ propfield: pszText
    12 ' ! ' @ propfield: hbm
    16 ' ! ' @ propfield: cchTextMax
    20 ' ! ' @ propfield: fmt
    24 ' ! ' @ propfield: lParam
36 ;STRUCT

STRUCT: WINDOWPOS DROP
    0 ' ! ' @ propfield: hwnd
    4 ' ! ' @ propfield: hwndInsertAfter
    8 ' ! ' @ propfield: x
    12 ' ! ' @ propfield: y
    16 ' ! ' @ propfield: cx
    20 ' ! ' @ propfield: cy
    24 ' ! ' @ propfield: flags
28 ;STRUCT

STRUCT: HD_LAYOUT DROP
    0 ' ! ' @ propfield: prc
    4 ' ! ' @ propfield: pwpos
8 ;STRUCT

STRUCT: HD_NOTIFY DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' ! ' @ propfield: iItem
    16 ' ! ' @ propfield: iButton
    20 ' ! ' @ propfield: pitem
24 ;STRUCT

STRUCT: HELPINFO DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: iContextType
    8 ' ! ' @ propfield: iCtrlId
    12 ' ! ' @ propfield: hItemHandle
    16 ' ! ' @ propfield: dwContextId
    20 ' Carr! ' Carr@ propfield: MousePos
28 ;STRUCT

STRUCT: HELPWININFO DROP
    0 ' ! ' @ propfield: wStructSize
    4 ' ! ' @ propfield: x
    8 ' ! ' @ propfield: y
    12 ' ! ' @ propfield: dx
    16 ' ! ' @ propfield: dy
    20 ' ! ' @ propfield: wMax
    24 ' Carr! ' Carr@ propfield: rgchMember
28 ;STRUCT

STRUCT: HIGHCONTRAST DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: lpszDefaultScheme
12 ;STRUCT

STRUCT: HSZPAIR DROP
    0 ' ! ' @ propfield: hszSvc
    4 ' ! ' @ propfield: hszTopic
8 ;STRUCT

STRUCT: ICONINFO DROP
    0 ' ! ' @ propfield: fIcon
    4 ' ! ' @ propfield: xHotspot
    8 ' ! ' @ propfield: yHotspot
    12 ' ! ' @ propfield: hbmMask
    16 ' ! ' @ propfield: hbmColor
20 ;STRUCT

STRUCT: ICONMETRICS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: iHorzSpacing
    8 ' ! ' @ propfield: iVertSpacing
    12 ' ! ' @ propfield: iTitleWrap
    16 ' Carr! ' Carr@ propfield: lfFont
76 ;STRUCT

STRUCT: IMAGEINFO DROP
    0 ' ! ' @ propfield: hbmImage
    4 ' ! ' @ propfield: hbmMask
    8 ' ! ' @ propfield: Unused1
    12 ' ! ' @ propfield: Unused2
    16 ' Carr! ' Carr@ propfield: rcImage
32 ;STRUCT

STRUCT: KEY_EVENT_RECORD DROP
    0 ' ! ' @ propfield: bKeyDown
    4 ' W! ' W@ propfield: wRepeatCount
    6 ' W! ' W@ propfield: wVirtualKeyCode
    8 ' W! ' W@ propfield: wVirtualScanCode
    10 ' W! ' W@ propfield: uChar
    12 ' ! ' @ propfield: dwControlKeyState
16 ;STRUCT

STRUCT: MOUSE_EVENT_RECORD DROP
    0 ' Carr! ' Carr@ propfield: dwMousePosition
    4 ' ! ' @ propfield: dwButtonState
    8 ' ! ' @ propfield: dwControlKeyState
    12 ' ! ' @ propfield: dwEventFlags
16 ;STRUCT

STRUCT: WINDOW_BUFFER_SIZE_RECORD DROP
    0 ' Carr! ' Carr@ propfield: dwSize
4 ;STRUCT

STRUCT: MENU_EVENT_RECORD DROP
    0 ' ! ' @ propfield: dwCommandId
4 ;STRUCT

STRUCT: INPUT_RECORD DROP
    0 ' W! ' W@ propfield: EventType
    4 ' Carr! ' Carr@ propfield: Event
20 ;STRUCT

STRUCT: SYSTEMTIME DROP
    0 ' W! ' W@ propfield: wYear
    2 ' W! ' W@ propfield: wMonth
    4 ' W! ' W@ propfield: wDayOfWeek
    6 ' W! ' W@ propfield: wDay
    8 ' W! ' W@ propfield: wHour
    10 ' W! ' W@ propfield: wMinute
    12 ' W! ' W@ propfield: wSecond
    14 ' W! ' W@ propfield: wMilliseconds
16 ;STRUCT

STRUCT: JOB_INFO_1 DROP
    0 ' ! ' @ propfield: JobId
    4 ' ! ' @ propfield: pPrinterName
    8 ' ! ' @ propfield: pMachineName
    12 ' ! ' @ propfield: pUserName
    16 ' ! ' @ propfield: pDocument
    20 ' ! ' @ propfield: pDatatype
    24 ' ! ' @ propfield: pStatus
    28 ' ! ' @ propfield: Status
    32 ' ! ' @ propfield: Priority
    36 ' ! ' @ propfield: Position
    40 ' ! ' @ propfield: TotalPages
    44 ' ! ' @ propfield: PagesPrinted
    48 ' Carr! ' Carr@ propfield: Submitted
64 ;STRUCT

STRUCT: SID_IDENTIFIER_AUTHORITY DROP
    0 ' Carr! ' Carr@ propfield: Value
6 ;STRUCT

STRUCT: SID DROP
    0 ' C! ' C@ propfield: Revision
    1 ' C! ' C@ propfield: SubAuthorityCount
    2 ' Carr! ' Carr@ propfield: IdentifierAuthority
    8 ' ! ' @ propfield: SubAuthority
12 ;STRUCT

STRUCT: SECURITY_DESCRIPTOR DROP
    0 ' C! ' C@ propfield: Revision
    1 ' C! ' C@ propfield: Sbz1
    2 ' W! ' W@ propfield: Control
    4 ' ! ' @ propfield: Owner
    8 ' ! ' @ propfield: Group
    12 ' ! ' @ propfield: Sacl
    16 ' ! ' @ propfield: Dacl
20 ;STRUCT

STRUCT: JOB_INFO_2 DROP
    0 ' ! ' @ propfield: JobId
    4 ' ! ' @ propfield: pPrinterName
    8 ' ! ' @ propfield: pMachineName
    12 ' ! ' @ propfield: pUserName
    16 ' ! ' @ propfield: pDocument
    20 ' ! ' @ propfield: pNotifyName
    24 ' ! ' @ propfield: pDatatype
    28 ' ! ' @ propfield: pPrintProcessor
    32 ' ! ' @ propfield: pParameters
    36 ' ! ' @ propfield: pDriverName
    40 ' ! ' @ propfield: pDevMode
    44 ' ! ' @ propfield: pStatus
    48 ' ! ' @ propfield: pSecurityDescriptor
    52 ' ! ' @ propfield: Status
    56 ' ! ' @ propfield: Priority
    60 ' ! ' @ propfield: Position
    64 ' ! ' @ propfield: StartTime
    68 ' ! ' @ propfield: UntilTime
    72 ' ! ' @ propfield: TotalPages
    76 ' ! ' @ propfield: Size
    80 ' Carr! ' Carr@ propfield: Submitted
    96 ' ! ' @ propfield: Time
    100 ' ! ' @ propfield: PagesPrinted
104 ;STRUCT

STRUCT: KERNINGPAIR DROP
    0 ' W! ' W@ propfield: wFirst
    2 ' W! ' W@ propfield: wSecond
    4 ' ! ' @ propfield: iKernAmount
8 ;STRUCT

STRUCT: LANA_ENUM DROP
    0 ' C! ' C@ propfield: length
    1 ' Carr! ' Carr@ propfield: lana
256 ;STRUCT

STRUCT: LDT_ENTRY DROP
    0 ' W! ' W@ propfield: LimitLow
    2 ' W! ' W@ propfield: BaseLow
    4 ' 2! ' 2@ propfield: HighWord
8 ;STRUCT

STRUCT: LOCALESIGNATURE DROP
    0 ' arr! ' arr@ propfield: lsUsb
    16 ' arr! ' arr@ propfield: lsCsbDefault
    24 ' arr! ' arr@ propfield: lsCsbSupported
32 ;STRUCT

STRUCT: LOCALGROUP_MEMBERS_INFO_0 DROP
    0 ' ! ' @ propfield: lgrmi0_sid
4 ;STRUCT

STRUCT: LOCALGROUP_MEMBERS_INFO_3 DROP
    0 ' ! ' @ propfield: lgrmi3_domainandname
4 ;STRUCT

STRUCT: LUID_AND_ATTRIBUTES DROP
    0 ' Carr! ' Carr@ propfield: Luid
    8 ' ! ' @ propfield: Attributes
12 ;STRUCT

STRUCT: LV_COLUMN DROP
    0 ' ! ' @ propfield: mask
    4 ' ! ' @ propfield: fmt
    8 ' ! ' @ propfield: cx
    12 ' ! ' @ propfield: pszText
    16 ' ! ' @ propfield: cchTextMax
    20 ' ! ' @ propfield: iSubItem
32 ;STRUCT

STRUCT: LV_ITEM DROP
    0 ' ! ' @ propfield: mask
    4 ' ! ' @ propfield: iItem
    8 ' ! ' @ propfield: iSubItem
    12 ' ! ' @ propfield: state
    16 ' ! ' @ propfield: stateMask
    20 ' ! ' @ propfield: pszText
    24 ' ! ' @ propfield: cchTextMax
    28 ' ! ' @ propfield: iImage
    32 ' ! ' @ propfield: lParam
40 ;STRUCT

STRUCT: LV_DISPINFO DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' Carr! ' Carr@ propfield: item
52 ;STRUCT

STRUCT: LV_FINDINFO DROP
    0 ' ! ' @ propfield: flags
    4 ' ! ' @ propfield: psz
    8 ' ! ' @ propfield: lParam
    12 ' Carr! ' Carr@ propfield: pt
    20 ' ! ' @ propfield: vkDirection
24 ;STRUCT

STRUCT: LV_HITTESTINFO DROP
    0 ' Carr! ' Carr@ propfield: pt
    8 ' ! ' @ propfield: flags
    12 ' ! ' @ propfield: iItem
20 ;STRUCT

STRUCT: LV_KEYDOWN DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' W! ' W@ propfield: wVKey
    14 ' ! ' @ propfield: flags
18 ;STRUCT

STRUCT: MAT2 DROP
    0 ' Carr! ' Carr@ propfield: eM11
    4 ' Carr! ' Carr@ propfield: eM12
    8 ' Carr! ' Carr@ propfield: eM21
    12 ' Carr! ' Carr@ propfield: eM22
16 ;STRUCT

STRUCT: MDICREATESTRUCT DROP
    0 ' ! ' @ propfield: szClass
    4 ' ! ' @ propfield: szTitle
    8 ' ! ' @ propfield: hOwner
    12 ' ! ' @ propfield: x
    16 ' ! ' @ propfield: y
    20 ' ! ' @ propfield: cx
    24 ' ! ' @ propfield: cy
    28 ' ! ' @ propfield: style
    32 ' ! ' @ propfield: lParam
36 ;STRUCT

STRUCT: MEASUREITEMSTRUCT DROP
    0 ' ! ' @ propfield: CtlType
    4 ' ! ' @ propfield: CtlID
    8 ' ! ' @ propfield: itemID
    12 ' ! ' @ propfield: itemWidth
    16 ' ! ' @ propfield: itemHeight
    20 ' ! ' @ propfield: itemData
24 ;STRUCT

STRUCT: MEMORY_BASIC_INFORMATION DROP
    0 ' ! ' @ propfield: BaseAddress
    4 ' ! ' @ propfield: AllocationBase
    8 ' ! ' @ propfield: AllocationProtect
    12 ' ! ' @ propfield: RegionSize
    16 ' ! ' @ propfield: State
    20 ' ! ' @ propfield: Protect
    24 ' ! ' @ propfield: Type
28 ;STRUCT

STRUCT: MEMORYSTATUS DROP
    0 ' ! ' @ propfield: dwLength
    4 ' ! ' @ propfield: dwMemoryLoad
    8 ' ! ' @ propfield: dwTotalPhys
    12 ' ! ' @ propfield: dwAvailPhys
    16 ' ! ' @ propfield: dwTotalPageFile
    20 ' ! ' @ propfield: dwAvailPageFile
    24 ' ! ' @ propfield: dwTotalVirtual
    28 ' ! ' @ propfield: dwAvailVirtual
32 ;STRUCT

STRUCT: MENUITEMINFO DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: fMask
    8 ' ! ' @ propfield: fType
    12 ' ! ' @ propfield: fState
    16 ' ! ' @ propfield: wID
    20 ' ! ' @ propfield: hSubMenu
    24 ' ! ' @ propfield: hbmpChecked
    28 ' ! ' @ propfield: hbmpUnchecked
    32 ' ! ' @ propfield: dwItemData
    36 ' ! ' @ propfield: dwTypeData
    40 ' ! ' @ propfield: cch
44 ;STRUCT

STRUCT: MENUITEMTEMPLATE DROP
    0 ' W! ' W@ propfield: mtOption
    2 ' W! ' W@ propfield: mtID
    4 ' W! ' W@ propfield: mtString
6 ;STRUCT

STRUCT: MENUITEMTEMPLATEHEADER DROP
    0 ' W! ' W@ propfield: versionNumber
    2 ' W! ' W@ propfield: offset
4 ;STRUCT

STRUCT: METAFILEPICT DROP
    0 ' ! ' @ propfield: mm
    4 ' ! ' @ propfield: xExt
    8 ' ! ' @ propfield: yExt
    12 ' ! ' @ propfield: hMF
16 ;STRUCT

STRUCT: METAHEADER DROP
    0 ' W! ' W@ propfield: mtType
    2 ' W! ' W@ propfield: mtHeaderSize
    4 ' W! ' W@ propfield: mtVersion
    6 ' ! ' @ propfield: mtSize
    10 ' W! ' W@ propfield: mtNoObjects
    12 ' ! ' @ propfield: mtMaxRecord
    16 ' W! ' W@ propfield: mtNoParameters
18 ;STRUCT

STRUCT: METARECORD DROP
    0 ' ! ' @ propfield: rdSize
    4 ' W! ' W@ propfield: rdFunction
    6 ' W! ' W@ propfield: rdParm
8 ;STRUCT

STRUCT: MINIMIZEDMETRICS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: iWidth
    8 ' ! ' @ propfield: iHorzGap
    12 ' ! ' @ propfield: iVertGap
    16 ' ! ' @ propfield: iArrange
20 ;STRUCT

STRUCT: MINMAXINFO DROP
    0 ' Carr! ' Carr@ propfield: ptReserved
    8 ' Carr! ' Carr@ propfield: ptMaxSize
    16 ' Carr! ' Carr@ propfield: ptMaxPosition
    24 ' Carr! ' Carr@ propfield: ptMinTrackSize
    32 ' Carr! ' Carr@ propfield: ptMaxTrackSize
40 ;STRUCT

STRUCT: MODEMDEVCAPS DROP
    0 ' ! ' @ propfield: dwActualSize
    4 ' ! ' @ propfield: dwRequiredSize
    8 ' ! ' @ propfield: dwDevSpecificOffset
    12 ' ! ' @ propfield: dwDevSpecificSize
    16 ' ! ' @ propfield: dwModemProviderVersion
    20 ' ! ' @ propfield: dwModemManufacturerOffset
    24 ' ! ' @ propfield: dwModemManufacturerSize
    28 ' ! ' @ propfield: dwModemModelOffset
    32 ' ! ' @ propfield: dwModemModelSize
    36 ' ! ' @ propfield: dwModemVersionOffset
    40 ' ! ' @ propfield: dwModemVersionSize
    44 ' ! ' @ propfield: dwDialOptions
    48 ' ! ' @ propfield: dwCallSetupFailTimer
    52 ' ! ' @ propfield: dwInactivityTimeout
    56 ' ! ' @ propfield: dwSpeakerVolume
    60 ' ! ' @ propfield: dwSpeakerMode
    64 ' ! ' @ propfield: dwModemOptions
    68 ' ! ' @ propfield: dwMaxDTERate
    72 ' ! ' @ propfield: dwMaxDCERate
    76 ' C! ' C@ propfield: abVariablePortion
80 ;STRUCT

STRUCT: MODEMSETTINGS DROP
    0 ' ! ' @ propfield: dwActualSize
    4 ' ! ' @ propfield: dwRequiredSize
    8 ' ! ' @ propfield: dwDevSpecificOffset
    12 ' ! ' @ propfield: dwDevSpecificSize
    16 ' ! ' @ propfield: dwCallSetupFailTimer
    20 ' ! ' @ propfield: dwInactivityTimeout
    24 ' ! ' @ propfield: dwSpeakerVolume
    28 ' ! ' @ propfield: dwSpeakerMode
    32 ' ! ' @ propfield: dwPreferredModemOptions
    36 ' ! ' @ propfield: dwNegotiatedModemOptions
    40 ' ! ' @ propfield: dwNegotiatedDCERate
    44 ' C! ' C@ propfield: abVariablePortion
48 ;STRUCT

STRUCT: MONCBSTRUCT DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: dwTime
    8 ' ! ' @ propfield: hTask
    12 ' ! ' @ propfield: dwRet
    16 ' ! ' @ propfield: wType
    20 ' ! ' @ propfield: wFmt
    24 ' ! ' @ propfield: hConv
    28 ' ! ' @ propfield: hsz1
    32 ' ! ' @ propfield: hsz2
    36 ' ! ' @ propfield: hData
    40 ' ! ' @ propfield: dwData1
    44 ' ! ' @ propfield: dwData2
    48 ' Carr! ' Carr@ propfield: cc
    84 ' ! ' @ propfield: cbData
    88 ' arr! ' arr@ propfield: Data
120 ;STRUCT

STRUCT: MONCONVSTRUCT DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: fConnect
    8 ' ! ' @ propfield: dwTime
    12 ' ! ' @ propfield: hTask
    16 ' ! ' @ propfield: hszSvc
    20 ' ! ' @ propfield: hszTopic
    24 ' ! ' @ propfield: hConvClient
    28 ' ! ' @ propfield: hConvServer
32 ;STRUCT

STRUCT: MONERRSTRUCT DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: wLastError
    8 ' ! ' @ propfield: dwTime
    12 ' ! ' @ propfield: hTask
16 ;STRUCT

STRUCT: MONHSZSTRUCT DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: fsAction
    8 ' ! ' @ propfield: dwTime
    12 ' ! ' @ propfield: hsz
    16 ' ! ' @ propfield: hTask
    20 ' C! ' C@ propfield: str
24 ;STRUCT

STRUCT: MONITOR_INFO_1 DROP
    0 ' ! ' @ propfield: pName
4 ;STRUCT

STRUCT: MONITOR_INFO_2 DROP
    0 ' ! ' @ propfield: pName
    4 ' ! ' @ propfield: pEnvironment
    8 ' ! ' @ propfield: pDLLName
12 ;STRUCT

STRUCT: MONLINKSTRUCT DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: dwTime
    8 ' ! ' @ propfield: hTask
    12 ' ! ' @ propfield: fEstablished
    16 ' ! ' @ propfield: fNoData
    20 ' ! ' @ propfield: hszSvc
    24 ' ! ' @ propfield: hszTopic
    28 ' ! ' @ propfield: hszItem
    32 ' ! ' @ propfield: wFmt
    36 ' ! ' @ propfield: fServer
    40 ' ! ' @ propfield: hConvServer
    44 ' ! ' @ propfield: hConvClient
48 ;STRUCT

STRUCT: MONMSGSTRUCT DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: hwndTo
    8 ' ! ' @ propfield: dwTime
    12 ' ! ' @ propfield: hTask
    16 ' ! ' @ propfield: wMsg
    20 ' ! ' @ propfield: wParam
    24 ' ! ' @ propfield: lParam
    28 ' Carr! ' Carr@ propfield: dmhd
72 ;STRUCT

STRUCT: MOUSEHOOKSTRUCT DROP
    0 ' Carr! ' Carr@ propfield: pt
    8 ' ! ' @ propfield: hwnd
    12 ' ! ' @ propfield: wHitTestCode
    16 ' ! ' @ propfield: dwExtraInfo
20 ;STRUCT

STRUCT: MOUSEKEYS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: iMaxSpeed
    12 ' ! ' @ propfield: iTimeToMaxSpeed
    16 ' ! ' @ propfield: iCtrlSpeed
    20 ' ! ' @ propfield: dwReserved1
    24 ' ! ' @ propfield: dwReserved2
28 ;STRUCT

STRUCT: MSG DROP
    0 ' ! ' @ propfield: hwnd
    4 ' ! ' @ propfield: message
    8 ' ! ' @ propfield: wParam
    12 ' ! ' @ propfield: lParam
    16 ' ! ' @ propfield: time
    20 ' Carr! ' Carr@ propfield: pt
28 ;STRUCT

STRUCT: MSGBOXPARAMS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: hInstance
    12 ' ! ' @ propfield: lpszText
    16 ' ! ' @ propfield: lpszCaption
    20 ' ! ' @ propfield: dwStyle
    24 ' ! ' @ propfield: lpszIcon
    28 ' ! ' @ propfield: dwContextHelpId
    32 ' ! ' @ propfield: lpfnMsgBoxCallback
    36 ' ! ' @ propfield: dwLanguageId
40 ;STRUCT

STRUCT: MSGFILTER DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' ! ' @ propfield: msg
    16 ' ! ' @ propfield: wParam
    20 ' ! ' @ propfield: lParam
24 ;STRUCT

STRUCT: MULTIKEYHELP DROP
    0 ' ! ' @ propfield: mkSize
    4 ' C! ' C@ propfield: mkKeylist
    5 ' C! ' C@ propfield: szKeyphrase
8 ;STRUCT

STRUCT: NAME_BUFFER DROP
    0 ' Carr! ' Carr@ propfield: name
    16 ' C! ' C@ propfield: name_num
    17 ' C! ' C@ propfield: name_flags
18 ;STRUCT

STRUCT: NCB DROP
    0 ' C! ' C@ propfield: ncb_command
    1 ' C! ' C@ propfield: ncb_retcode
    2 ' C! ' C@ propfield: ncb_lsn
    3 ' C! ' C@ propfield: ncb_num
    4 ' ! ' @ propfield: ncb_buffer
    8 ' W! ' W@ propfield: ncb_length
    10 ' Carr! ' Carr@ propfield: ncb_callname
    26 ' Carr! ' Carr@ propfield: ncb_name
    42 ' C! ' C@ propfield: ncb_rto
    43 ' C! ' C@ propfield: ncb_sto
    44 ' ! ' @ propfield: ncb_post
    48 ' C! ' C@ propfield: ncb_lana_num
    49 ' C! ' C@ propfield: ncb_cmd_cplt
    50 ' Carr! ' Carr@ propfield: ncb_reserve
    60 ' ! ' @ propfield: ncb_event
64 ;STRUCT

STRUCT: NCCALCSIZE_PARAMS DROP
    0 ' Carr! ' Carr@ propfield: rgrc
    48 ' ! ' @ propfield: lppos
52 ;STRUCT

STRUCT: NDDESHAREINFO DROP
    0 ' ! ' @ propfield: lRevision
    4 ' ! ' @ propfield: lpszShareName
    8 ' ! ' @ propfield: lShareType
    12 ' ! ' @ propfield: lpszAppTopicList
    16 ' ! ' @ propfield: fSharedFlag
    20 ' ! ' @ propfield: fService
    24 ' ! ' @ propfield: fStartAppFlag
    28 ' ! ' @ propfield: nCmdShow
    32 ' arr! ' arr@ propfield: qModifyId
    40 ' ! ' @ propfield: cNumItems
    44 ' ! ' @ propfield: lpszItemList
48 ;STRUCT

STRUCT: NETRESOURCE DROP
    0 ' ! ' @ propfield: dwScope
    4 ' ! ' @ propfield: dwType
    8 ' ! ' @ propfield: dwDisplayType
    12 ' ! ' @ propfield: dwUsage
    16 ' ! ' @ propfield: lpLocalName
    20 ' ! ' @ propfield: lpRemoteName
    24 ' ! ' @ propfield: lpComment
    28 ' ! ' @ propfield: lpProvider
32 ;STRUCT

STRUCT: NEWCPLINFO DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: dwHelpContext
    12 ' ! ' @ propfield: lData
    16 ' ! ' @ propfield: hIcon
    20 ' Carr! ' Carr@ propfield: szName
    52 ' Carr! ' Carr@ propfield: szInfo
    116 ' Carr! ' Carr@ propfield: szHelpFile
244 ;STRUCT

STRUCT: NEWTEXTMETRIC DROP
    0 ' ! ' @ propfield: tmHeight
    4 ' ! ' @ propfield: tmAscent
    8 ' ! ' @ propfield: tmDescent
    12 ' ! ' @ propfield: tmInternalLeading
    16 ' ! ' @ propfield: tmExternalLeading
    20 ' ! ' @ propfield: tmAveCharWidth
    24 ' ! ' @ propfield: tmMaxCharWidth
    28 ' ! ' @ propfield: tmWeight
    32 ' ! ' @ propfield: tmOverhang
    36 ' ! ' @ propfield: tmDigitizedAspectX
    40 ' ! ' @ propfield: tmDigitizedAspectY
    44 ' C! ' C@ propfield: tmFirstChar
    45 ' C! ' C@ propfield: tmLastChar
    46 ' C! ' C@ propfield: tmDefaultChar
    47 ' C! ' C@ propfield: tmBreakChar
    48 ' C! ' C@ propfield: tmItalic
    49 ' C! ' C@ propfield: tmUnderlined
    50 ' C! ' C@ propfield: tmStruckOut
    51 ' C! ' C@ propfield: tmPitchAndFamily
    52 ' C! ' C@ propfield: tmCharSet
    56 ' ! ' @ propfield: ntmFlags
    60 ' ! ' @ propfield: ntmSizeEM
    64 ' ! ' @ propfield: ntmCellHeight
    68 ' ! ' @ propfield: ntmAvgWidth
72 ;STRUCT

STRUCT: NM_LISTVIEW DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' ! ' @ propfield: iItem
    16 ' ! ' @ propfield: iSubItem
    20 ' ! ' @ propfield: uNewState
    24 ' ! ' @ propfield: uOldState
    28 ' ! ' @ propfield: uChanged
    32 ' Carr! ' Carr@ propfield: ptAction
    40 ' ! ' @ propfield: lParam
44 ;STRUCT

STRUCT: TV_ITEM DROP
    0 ' ! ' @ propfield: mask
    4 ' ! ' @ propfield: hItem
    8 ' ! ' @ propfield: state
    12 ' ! ' @ propfield: stateMask
    16 ' ! ' @ propfield: pszText
    20 ' ! ' @ propfield: cchTextMax
    24 ' ! ' @ propfield: iImage
    28 ' ! ' @ propfield: iSelectedImage
    32 ' ! ' @ propfield: cChildren
    36 ' ! ' @ propfield: lParam
40 ;STRUCT

STRUCT: NM_TREEVIEW DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' ! ' @ propfield: action
    16 ' Carr! ' Carr@ propfield: itemOld
    56 ' Carr! ' Carr@ propfield: itemNew
    96 ' Carr! ' Carr@ propfield: ptDrag
104 ;STRUCT

STRUCT: NONCLIENTMETRICS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: iBorderWidth
    8 ' ! ' @ propfield: iScrollWidth
    12 ' ! ' @ propfield: iScrollHeight
    16 ' ! ' @ propfield: iCaptionWidth
    20 ' ! ' @ propfield: iCaptionHeight
    24 ' Carr! ' Carr@ propfield: lfCaptionFont
    84 ' ! ' @ propfield: iSmCaptionWidth
    88 ' ! ' @ propfield: iSmCaptionHeight
    92 ' Carr! ' Carr@ propfield: lfSmCaptionFont
    152 ' ! ' @ propfield: iMenuWidth
    156 ' ! ' @ propfield: iMenuHeight
    160 ' Carr! ' Carr@ propfield: lfMenuFont
    220 ' Carr! ' Carr@ propfield: lfStatusFont
    280 ' Carr! ' Carr@ propfield: lfMessageFont
340 ;STRUCT

STRUCT: SERVICE_ADDRESS DROP
    0 ' ! ' @ propfield: dwAddressType
    4 ' ! ' @ propfield: dwAddressFlags
    8 ' ! ' @ propfield: dwAddressLength
    12 ' ! ' @ propfield: dwPrincipalLength
    16 ' ! ' @ propfield: lpAddress
    20 ' ! ' @ propfield: lpPrincipal
24 ;STRUCT

STRUCT: SERVICE_ADDRESSES DROP
    0 ' ! ' @ propfield: dwAddressCount
    4 ' Carr! ' Carr@ propfield: Addresses
28 ;STRUCT

STRUCT: GUID DROP
    0 ' ! ' @ propfield: Data1
    4 ' W! ' W@ propfield: Data2
    6 ' W! ' W@ propfield: Data3
    8 ' Carr! ' Carr@ propfield: Data4
16 ;STRUCT

STRUCT: SERVICE_INFO DROP
    0 ' ! ' @ propfield: lpServiceType
    4 ' ! ' @ propfield: lpServiceName
    8 ' ! ' @ propfield: lpComment
    12 ' ! ' @ propfield: lpLocale
    16 ' ! ' @ propfield: dwDisplayHint
    20 ' ! ' @ propfield: dwVersion
    24 ' ! ' @ propfield: dwTime
    28 ' ! ' @ propfield: lpMachineName
    32 ' ! ' @ propfield: lpServiceAddress
    36 ' Carr! ' Carr@ propfield: ServiceSpecificInfo
44 ;STRUCT

STRUCT: NS_SERVICE_INFO DROP
    0 ' ! ' @ propfield: dwNameSpace
    4 ' Carr! ' Carr@ propfield: ServiceInfo
48 ;STRUCT

STRUCT: NUMBERFMT DROP
    0 ' ! ' @ propfield: NumDigits
    4 ' ! ' @ propfield: LeadingZero
    8 ' ! ' @ propfield: Grouping
    12 ' ! ' @ propfield: lpDecimalSep
    16 ' ! ' @ propfield: lpThousandSep
    20 ' ! ' @ propfield: NegativeOrder
24 ;STRUCT

STRUCT: OFSTRUCT DROP
    0 ' C! ' C@ propfield: cBytes
    1 ' C! ' C@ propfield: fFixedDisk
    2 ' W! ' W@ propfield: nErrCode
    4 ' W! ' W@ propfield: Reserved1
    6 ' W! ' W@ propfield: Reserved2
    8 ' Carr! ' Carr@ propfield: szPathName
136 ;STRUCT

STRUCT: OPENFILENAME DROP
    0 ' ! ' @ propfield: lStructSize
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: hInstance
    12 ' ! ' @ propfield: lpstrFilter
    16 ' ! ' @ propfield: lpstrCustomFilter
    20 ' ! ' @ propfield: nMaxCustFilter
    24 ' ! ' @ propfield: nFilterIndex
    28 ' ! ' @ propfield: lpstrFile
    32 ' ! ' @ propfield: nMaxFile
    36 ' ! ' @ propfield: lpstrFileTitle
    40 ' ! ' @ propfield: nMaxFileTitle
    44 ' ! ' @ propfield: lpstrInitialDir
    48 ' ! ' @ propfield: lpstrTitle
    52 ' ! ' @ propfield: Flags
    56 ' W! ' W@ propfield: nFileOffset
    58 ' W! ' W@ propfield: nFileExtension
    60 ' ! ' @ propfield: lpstrDefExt
    64 ' ! ' @ propfield: lCustData
    68 ' ! ' @ propfield: lpfnHook
    72 ' ! ' @ propfield: lpTemplateName
76 ;STRUCT

STRUCT: OFNOTIFY DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' ! ' @ propfield: lpOFN
    16 ' ! ' @ propfield: pszFile
20 ;STRUCT

STRUCT: OSVERSIONINFO DROP
    0 ' ! ' @ propfield: dwOSVersionInfoSize
    4 ' ! ' @ propfield: dwMajorVersion
    8 ' ! ' @ propfield: dwMinorVersion
    12 ' ! ' @ propfield: dwBuildNumber
    16 ' ! ' @ propfield: dwPlatformId
    20 ' Carr! ' Carr@ propfield: szCSDVersion
148 ;STRUCT

STRUCT: TEXTMETRIC DROP
    0 ' ! ' @ propfield: tmHeight
    4 ' ! ' @ propfield: tmAscent
    8 ' ! ' @ propfield: tmDescent
    12 ' ! ' @ propfield: tmInternalLeading
    16 ' ! ' @ propfield: tmExternalLeading
    20 ' ! ' @ propfield: tmAveCharWidth
    24 ' ! ' @ propfield: tmMaxCharWidth
    28 ' ! ' @ propfield: tmWeight
    32 ' ! ' @ propfield: tmOverhang
    36 ' ! ' @ propfield: tmDigitizedAspectX
    40 ' ! ' @ propfield: tmDigitizedAspectY
    44 ' C! ' C@ propfield: tmFirstChar
    45 ' C! ' C@ propfield: tmLastChar
    46 ' C! ' C@ propfield: tmDefaultChar
    47 ' C! ' C@ propfield: tmBreakChar
    48 ' C! ' C@ propfield: tmItalic
    49 ' C! ' C@ propfield: tmUnderlined
    50 ' C! ' C@ propfield: tmStruckOut
    51 ' C! ' C@ propfield: tmPitchAndFamily
    52 ' C! ' C@ propfield: tmCharSet
56 ;STRUCT

STRUCT: OUTLINETEXTMETRIC DROP
    0 ' ! ' @ propfield: otmSize
    4 ' Carr! ' Carr@ propfield: otmTextMetrics
    60 ' C! ' C@ propfield: otmFiller
    61 ' Carr! ' Carr@ propfield: otmPanoseNumber
    72 ' ! ' @ propfield: otmfsSelection
    76 ' ! ' @ propfield: otmfsType
    80 ' ! ' @ propfield: otmsCharSlopeRise
    84 ' ! ' @ propfield: otmsCharSlopeRun
    88 ' ! ' @ propfield: otmItalicAngle
    92 ' ! ' @ propfield: otmEMSquare
    96 ' ! ' @ propfield: otmAscent
    100 ' ! ' @ propfield: otmDescent
    104 ' ! ' @ propfield: otmLineGap
    108 ' ! ' @ propfield: otmsCapEmHeight
    112 ' ! ' @ propfield: otmsXHeight
    116 ' Carr! ' Carr@ propfield: otmrcFontBox
    132 ' ! ' @ propfield: otmMacAscent
    136 ' ! ' @ propfield: otmMacDescent
    140 ' ! ' @ propfield: otmMacLineGap
    144 ' ! ' @ propfield: otmusMinimumPPEM
    148 ' Carr! ' Carr@ propfield: otmptSubscriptSize
    156 ' Carr! ' Carr@ propfield: otmptSubscriptOffset
    164 ' Carr! ' Carr@ propfield: otmptSuperscriptSize
    172 ' Carr! ' Carr@ propfield: otmptSuperscriptOffset
    180 ' ! ' @ propfield: otmsStrikeoutSize
    184 ' ! ' @ propfield: otmsStrikeoutPosition
    188 ' ! ' @ propfield: otmsUnderscoreSize
    192 ' ! ' @ propfield: otmsUnderscorePosition
    196 ' ! ' @ propfield: otmpFamilyName
    200 ' ! ' @ propfield: otmpFaceName
    204 ' ! ' @ propfield: otmpStyleName
    208 ' ! ' @ propfield: otmpFullName
212 ;STRUCT

STRUCT: OVERLAPPED DROP
    0 ' ! ' @ propfield: Internal
    4 ' ! ' @ propfield: InternalHigh
    8 ' ! ' @ propfield: Offset
    12 ' ! ' @ propfield: OffsetHigh
    16 ' ! ' @ propfield: hEvent
20 ;STRUCT

STRUCT: PAGESETUPDLG DROP
    0 ' ! ' @ propfield: lStructSize
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: hDevMode
    12 ' ! ' @ propfield: hDevNames
    16 ' ! ' @ propfield: Flags
    20 ' Carr! ' Carr@ propfield: ptPaperSize
    28 ' Carr! ' Carr@ propfield: rtMinMargin
    44 ' Carr! ' Carr@ propfield: rtMargin
    60 ' ! ' @ propfield: hInstance
    64 ' ! ' @ propfield: lCustData
    68 ' ! ' @ propfield: lpfnPageSetupHook
    72 ' ! ' @ propfield: lpfnPagePaintHook
    76 ' ! ' @ propfield: lpPageSetupTemplateName
    80 ' ! ' @ propfield: hPageSetupTemplate
84 ;STRUCT

STRUCT: PAINTSTRUCT DROP
    0 ' ! ' @ propfield: hdc
    4 ' ! ' @ propfield: fErase
    8 ' Carr! ' Carr@ propfield: rcPaint
    24 ' ! ' @ propfield: fRestore
    28 ' ! ' @ propfield: fIncUpdate
    32 ' Carr! ' Carr@ propfield: rgbReserved
64 ;STRUCT

STRUCT: PARAFORMAT DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwMask
    8 ' W! ' W@ propfield: wNumbering
    10 ' W! ' W@ propfield: wEffects
    12 ' ! ' @ propfield: dxStartIndent
    16 ' ! ' @ propfield: dxRightIndent
    20 ' ! ' @ propfield: dxOffset
    24 ' W! ' W@ propfield: wAlignment
    26 ' W! ' W@ propfield: cTabCount
    28 ' arr! ' arr@ propfield: rgxTabs
156 ;STRUCT

STRUCT: PERF_COUNTER_BLOCK DROP
    0 ' ! ' @ propfield: ByteLength
4 ;STRUCT

STRUCT: PERF_COUNTER_DEFINITION DROP
    0 ' ! ' @ propfield: ByteLength
    4 ' ! ' @ propfield: CounterNameTitleIndex
    8 ' ! ' @ propfield: CounterNameTitle
    12 ' ! ' @ propfield: CounterHelpTitleIndex
    16 ' ! ' @ propfield: CounterHelpTitle
    20 ' ! ' @ propfield: DefaultScale
    24 ' ! ' @ propfield: DetailLevel
    28 ' ! ' @ propfield: CounterType
    32 ' ! ' @ propfield: CounterSize
    36 ' ! ' @ propfield: CounterOffset
40 ;STRUCT

STRUCT: PERF_DATA_BLOCK DROP
    0 ' Warr! ' Warr@ propfield: Signature
    8 ' ! ' @ propfield: LittleEndian
    12 ' ! ' @ propfield: Version
    16 ' ! ' @ propfield: Revision
    20 ' ! ' @ propfield: TotalByteLength
    24 ' ! ' @ propfield: HeaderLength
    28 ' ! ' @ propfield: NumObjectTypes
    32 ' ! ' @ propfield: DefaultObject
    36 ' Carr! ' Carr@ propfield: SystemTime
    56 ' Carr! ' Carr@ propfield: PerfTime
    64 ' Carr! ' Carr@ propfield: PerfFreq
    72 ' Carr! ' Carr@ propfield: PerfTime100nSec
    80 ' ! ' @ propfield: SystemNameLength
    84 ' ! ' @ propfield: SystemNameOffset
88 ;STRUCT

STRUCT: PERF_INSTANCE_DEFINITION DROP
    0 ' ! ' @ propfield: ByteLength
    4 ' ! ' @ propfield: ParentObjectTitleIndex
    8 ' ! ' @ propfield: ParentObjectInstance
    12 ' ! ' @ propfield: UniqueID
    16 ' ! ' @ propfield: NameOffset
    20 ' ! ' @ propfield: NameLength
24 ;STRUCT

STRUCT: PERF_OBJECT_TYPE DROP
    0 ' ! ' @ propfield: TotalByteLength
    4 ' ! ' @ propfield: DefinitionLength
    8 ' ! ' @ propfield: HeaderLength
    12 ' ! ' @ propfield: ObjectNameTitleIndex
    16 ' ! ' @ propfield: ObjectNameTitle
    20 ' ! ' @ propfield: ObjectHelpTitleIndex
    24 ' ! ' @ propfield: ObjectHelpTitle
    28 ' ! ' @ propfield: DetailLevel
    32 ' ! ' @ propfield: NumCounters
    36 ' ! ' @ propfield: DefaultCounter
    40 ' ! ' @ propfield: NumInstances
    44 ' ! ' @ propfield: CodePage
    48 ' Carr! ' Carr@ propfield: PerfTime
    56 ' Carr! ' Carr@ propfield: PerfFreq
64 ;STRUCT

STRUCT: POLYTEXT DROP
    0 ' ! ' @ propfield: x
    4 ' ! ' @ propfield: y
    8 ' ! ' @ propfield: n
    12 ' ! ' @ propfield: lpstr
    16 ' ! ' @ propfield: uiFlags
    20 ' Carr! ' Carr@ propfield: rcl
    36 ' ! ' @ propfield: pdx
40 ;STRUCT

STRUCT: PORT_INFO_1 DROP
    0 ' ! ' @ propfield: pName
4 ;STRUCT

STRUCT: PORT_INFO_2 DROP
    0 ' ! ' @ propfield: pPortName
    4 ' ! ' @ propfield: pMonitorName
    8 ' ! ' @ propfield: pDescription
    12 ' ! ' @ propfield: fPortType
    16 ' ! ' @ propfield: Reserved
20 ;STRUCT

STRUCT: PREVENT_MEDIA_REMOVAL DROP
    0 ' C! ' C@ propfield: PreventMediaRemoval
1 ;STRUCT

STRUCT: PRINTDLG DROP
    0 ' ! ' @ propfield: lStructSize
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: hDevMode
    12 ' ! ' @ propfield: hDevNames
    16 ' ! ' @ propfield: hDC
    20 ' ! ' @ propfield: Flags
    24 ' W! ' W@ propfield: nFromPage
    26 ' W! ' W@ propfield: nToPage
    28 ' W! ' W@ propfield: nMinPage
    30 ' W! ' W@ propfield: nMaxPage
    32 ' W! ' W@ propfield: nCopies
    34 ' ! ' @ propfield: hInstance
    38 ' ! ' @ propfield: lCustData
    42 ' ! ' @ propfield: lpfnPrintHook
    46 ' ! ' @ propfield: lpfnSetupHook
    50 ' ! ' @ propfield: lpPrintTemplateName
    54 ' ! ' @ propfield: lpSetupTemplateName
    58 ' ! ' @ propfield: hPrintTemplate
    62 ' ! ' @ propfield: hSetupTemplate
66 ;STRUCT

STRUCT: PRINTER_DEFAULTS DROP
    0 ' ! ' @ propfield: pDatatype
    4 ' ! ' @ propfield: pDevMode
    8 ' ! ' @ propfield: DesiredAccess
12 ;STRUCT

STRUCT: PRINTER_INFO_1 DROP
    0 ' ! ' @ propfield: Flags
    4 ' ! ' @ propfield: pDescription
    8 ' ! ' @ propfield: pName
    12 ' ! ' @ propfield: pComment
16 ;STRUCT

STRUCT: PRINTER_INFO_2 DROP
    0 ' ! ' @ propfield: pServerName
    4 ' ! ' @ propfield: pPrinterName
    8 ' ! ' @ propfield: pShareName
    12 ' ! ' @ propfield: pPortName
    16 ' ! ' @ propfield: pDriverName
    20 ' ! ' @ propfield: pComment
    24 ' ! ' @ propfield: pLocation
    28 ' ! ' @ propfield: pDevMode
    32 ' ! ' @ propfield: pSepFile
    36 ' ! ' @ propfield: pPrintProcessor
    40 ' ! ' @ propfield: pDatatype
    44 ' ! ' @ propfield: pParameters
    48 ' ! ' @ propfield: pSecurityDescriptor
    52 ' ! ' @ propfield: Attributes
    56 ' ! ' @ propfield: Priority
    60 ' ! ' @ propfield: DefaultPriority
    64 ' ! ' @ propfield: StartTime
    68 ' ! ' @ propfield: UntilTime
    72 ' ! ' @ propfield: Status
    76 ' ! ' @ propfield: cJobs
    80 ' ! ' @ propfield: AveragePPM
84 ;STRUCT

STRUCT: PRINTER_INFO_3 DROP
    0 ' ! ' @ propfield: pSecurityDescriptor
4 ;STRUCT

STRUCT: PRINTER_INFO_4 DROP
    0 ' ! ' @ propfield: pPrinterName
    4 ' ! ' @ propfield: pServerName
    8 ' ! ' @ propfield: Attributes
12 ;STRUCT

STRUCT: PRINTER_INFO_5 DROP
    0 ' ! ' @ propfield: pPrinterName
    4 ' ! ' @ propfield: pPortName
    8 ' ! ' @ propfield: Attributes
    12 ' ! ' @ propfield: DeviceNotSelectedTimeout
    16 ' ! ' @ propfield: TransmissionRetryTimeout
20 ;STRUCT

STRUCT: PRINTER_NOTIFY_INFO_DATA DROP
    0 ' W! ' W@ propfield: Type
    2 ' W! ' W@ propfield: Field
    4 ' ! ' @ propfield: Reserved
    8 ' ! ' @ propfield: Id
    12 ' arr! ' arr@ propfield: NotifyData
20 ;STRUCT

STRUCT: PRINTER_NOTIFY_INFO DROP
    0 ' ! ' @ propfield: Version
    4 ' ! ' @ propfield: Flags
    8 ' ! ' @ propfield: Count
    12 ' Carr! ' Carr@ propfield: aData
32 ;STRUCT

STRUCT: PRINTER_NOTIFY_OPTIONS_TYPE DROP
    0 ' W! ' W@ propfield: Type
    2 ' W! ' W@ propfield: Reserved0
    4 ' ! ' @ propfield: Reserved1
    8 ' ! ' @ propfield: Reserved2
    12 ' ! ' @ propfield: Count
    16 ' ! ' @ propfield: pFields
20 ;STRUCT

STRUCT: PRINTER_NOTIFY_OPTIONS DROP
    0 ' ! ' @ propfield: Version
    4 ' ! ' @ propfield: Flags
    8 ' ! ' @ propfield: Count
    12 ' ! ' @ propfield: pTypes
16 ;STRUCT

STRUCT: PRINTPROCESSOR_INFO_1 DROP
    0 ' ! ' @ propfield: pName
4 ;STRUCT

STRUCT: PRIVILEGE_SET DROP
    0 ' ! ' @ propfield: PrivilegeCount
    4 ' ! ' @ propfield: Control
    8 ' Carr! ' Carr@ propfield: Privilege
20 ;STRUCT

STRUCT: PROCESS_INFORMATION DROP
    0 ' ! ' @ propfield: hProcess
    4 ' ! ' @ propfield: hThread
    8 ' ! ' @ propfield: dwProcessId
    12 ' ! ' @ propfield: dwThreadId
16 ;STRUCT

STRUCT: PROPSHEETPAGE DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: hInstance
    12 ' ! ' @ propfield: pszTemplate
    12 ' ! ' @ propfield: pResource
    16 ' ! ' @ propfield: hIcon
    16 ' ! ' @ propfield: pszIcon
    20 ' ! ' @ propfield: pszTitle
    24 ' ! ' @ propfield: pfnDlgProc
    28 ' ! ' @ propfield: lParam
    32 ' ! ' @ propfield: pfnCallback
    36 ' ! ' @ propfield: pcRefParent
48 ;STRUCT

STRUCT: PROPSHEETHEADER DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: hwndParent
    12 ' ! ' @ propfield: hInstance
    16 ' ! ' @ propfield: hIcon
    16 ' ! ' @ propfield: pszIcon
    20 ' ! ' @ propfield: pszCaption
    24 ' ! ' @ propfield: nPages
    28 ' ! ' @ propfield: nStartPage
    28 ' ! ' @ propfield: pStartPage
    32 ' ! ' @ propfield: ppsp
    32 ' ! ' @ propfield: phpage
    36 ' ! ' @ propfield: pfnCallback
52 ;STRUCT

STRUCT: PROTOCOL_INFO DROP
    0 ' ! ' @ propfield: dwServiceFlags
    4 ' ! ' @ propfield: iAddressFamily
    8 ' ! ' @ propfield: iMaxSockAddr
    12 ' ! ' @ propfield: iMinSockAddr
    16 ' ! ' @ propfield: iSocketType
    20 ' ! ' @ propfield: iProtocol
    24 ' ! ' @ propfield: dwMessageSize
    28 ' ! ' @ propfield: lpProtocol
32 ;STRUCT

STRUCT: PROVIDOR_INFO_1 DROP
    0 ' ! ' @ propfield: pName
    4 ' ! ' @ propfield: pEnvironment
    8 ' ! ' @ propfield: pDLLName
12 ;STRUCT

STRUCT: PSHNOTIFY DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' ! ' @ propfield: lParam
16 ;STRUCT

STRUCT: PUNCTUATION DROP
    0 ' ! ' @ propfield: iSize
    4 ' ! ' @ propfield: szPunctuation
8 ;STRUCT

STRUCT: QUERY_SERVICE_CONFIG DROP
    0 ' ! ' @ propfield: dwServiceType
    4 ' ! ' @ propfield: dwStartType
    8 ' ! ' @ propfield: dwErrorControl
    12 ' ! ' @ propfield: lpBinaryPathName
    16 ' ! ' @ propfield: lpLoadOrderGroup
    20 ' ! ' @ propfield: dwTagId
    24 ' ! ' @ propfield: lpDependencies
    28 ' ! ' @ propfield: lpServiceStartName
    32 ' ! ' @ propfield: lpDisplayName
36 ;STRUCT

STRUCT: QUERY_SERVICE_LOCK_STATUS DROP
    0 ' ! ' @ propfield: fIsLocked
    4 ' ! ' @ propfield: lpLockOwner
    8 ' ! ' @ propfield: dwLockDuration
12 ;STRUCT

STRUCT: RASAMB DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwError
    8 ' Carr! ' Carr@ propfield: szNetBiosError
    25 ' C! ' C@ propfield: bLana
28 ;STRUCT

STRUCT: RASCONN DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: hrasconn
    8 ' Carr! ' Carr@ propfield: szEntryName
    265 ' Carr! ' Carr@ propfield: szDeviceType
    282 ' Carr! ' Carr@ propfield: szDeviceName
412 ;STRUCT

STRUCT: RASCONNSTATUS DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: rasconnstate
    8 ' ! ' @ propfield: dwError
    12 ' Carr! ' Carr@ propfield: szDeviceType
    29 ' Carr! ' Carr@ propfield: szDeviceName
160 ;STRUCT

STRUCT: RASDIALEXTENSIONS DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwfOptions
    8 ' ! ' @ propfield: hwndParent
    12 ' ! ' @ propfield: reserved
16 ;STRUCT

STRUCT: RASDIALPARAMS DROP
    0 ' ! ' @ propfield: dwSize
    4 ' Carr! ' Carr@ propfield: szEntryName
    261 ' Carr! ' Carr@ propfield: szPhoneNumber
    390 ' Carr! ' Carr@ propfield: szCallbackNumber
    519 ' Carr! ' Carr@ propfield: szUserName
    776 ' Carr! ' Carr@ propfield: szPassword
    1033 ' Carr! ' Carr@ propfield: szDomain
1052 ;STRUCT

STRUCT: RASENTRYNAME DROP
    0 ' ! ' @ propfield: dwSize
    4 ' Carr! ' Carr@ propfield: szEntryName
264 ;STRUCT

STRUCT: RASPPPIP DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwError
    8 ' Carr! ' Carr@ propfield: szIpAddress
40 ;STRUCT

STRUCT: RASPPPIPX DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwError
    8 ' Carr! ' Carr@ propfield: szIpxAddress
32 ;STRUCT

STRUCT: RASPPPNBF DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: dwError
    8 ' ! ' @ propfield: dwNetBiosError
    12 ' Carr! ' Carr@ propfield: szNetBiosError
    29 ' Carr! ' Carr@ propfield: szWorkstationName
    46 ' C! ' C@ propfield: bLana
48 ;STRUCT

STRUCT: RASTERIZER_STATUS DROP
    0 ' W! ' W@ propfield: nSize
    2 ' W! ' W@ propfield: wFlags
    4 ' W! ' W@ propfield: nLanguageID
6 ;STRUCT

STRUCT: REASSIGN_BLOCKS DROP
    0 ' W! ' W@ propfield: Reserved
    2 ' W! ' W@ propfield: Count
    4 ' ! ' @ propfield: BlockNumber
8 ;STRUCT

STRUCT: REMOTE_NAME_INFO DROP
    0 ' ! ' @ propfield: lpUniversalName
    4 ' ! ' @ propfield: lpConnectionName
    8 ' ! ' @ propfield: lpRemainingPath
12 ;STRUCT

STRUCT: REPASTESPECIAL DROP
    0 ' ! ' @ propfield: dwAspect
    4 ' ! ' @ propfield: dwParam
8 ;STRUCT

STRUCT: REQRESIZE DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' Carr! ' Carr@ propfield: rc
28 ;STRUCT

STRUCT: RGNDATAHEADER DROP
    0 ' ! ' @ propfield: dwSize
    4 ' ! ' @ propfield: iType
    8 ' ! ' @ propfield: nCount
    12 ' ! ' @ propfield: nRgnSize
    16 ' Carr! ' Carr@ propfield: rcBound
32 ;STRUCT

STRUCT: RGNDATA DROP
    0 ' Carr! ' Carr@ propfield: rdh
    32 ' C! ' C@ propfield: Buffer
36 ;STRUCT

STRUCT: SCROLLINFO DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: fMask
    8 ' ! ' @ propfield: nMin
    12 ' ! ' @ propfield: nMax
    16 ' ! ' @ propfield: nPage
    20 ' ! ' @ propfield: nPos
    24 ' ! ' @ propfield: nTrackPos
28 ;STRUCT

STRUCT: SECURITY_ATTRIBUTES DROP
    0 ' ! ' @ propfield: nLength
    4 ' ! ' @ propfield: lpSecurityDescriptor
    8 ' ! ' @ propfield: bInheritHandle
12 ;STRUCT

STRUCT: SELCHANGE DROP
    0 ' Carr! ' Carr@ propfield: nmhdr
    12 ' Carr! ' Carr@ propfield: chrg
    20 ' W! ' W@ propfield: seltyp
24 ;STRUCT

STRUCT: SERIALKEYS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: lpszActivePort
    12 ' ! ' @ propfield: lpszPort
    16 ' ! ' @ propfield: iBaudRate
    20 ' ! ' @ propfield: iPortState
28 ;STRUCT

STRUCT: SERVICE_TABLE_ENTRY DROP
    0 ' ! ' @ propfield: lpServiceName
    4 ' ! ' @ propfield: lpServiceProc
8 ;STRUCT

STRUCT: SERVICE_TYPE_VALUE_ABS DROP
    0 ' ! ' @ propfield: dwNameSpace
    4 ' ! ' @ propfield: dwValueType
    8 ' ! ' @ propfield: dwValueSize
    12 ' ! ' @ propfield: lpValueName
    16 ' ! ' @ propfield: lpValue
20 ;STRUCT

STRUCT: SERVICE_TYPE_INFO_ABS DROP
    0 ' ! ' @ propfield: lpTypeName
    4 ' ! ' @ propfield: dwValueCount
    8 ' Carr! ' Carr@ propfield: Values
28 ;STRUCT

STRUCT: SESSION_BUFFER DROP
    0 ' C! ' C@ propfield: lsn
    1 ' C! ' C@ propfield: state
    2 ' Carr! ' Carr@ propfield: local_name
    18 ' Carr! ' Carr@ propfield: remote_name
    34 ' C! ' C@ propfield: rcvs_outstanding
    35 ' C! ' C@ propfield: sends_outstanding
36 ;STRUCT

STRUCT: SESSION_HEADER DROP
    0 ' C! ' C@ propfield: sess_name
    1 ' C! ' C@ propfield: num_sess
    2 ' C! ' C@ propfield: rcv_dg_outstanding
    3 ' C! ' C@ propfield: rcv_any_outstanding
4 ;STRUCT

STRUCT: SET_PARTITION_INFORMATION DROP
    0 ' C! ' C@ propfield: PartitionType
1 ;STRUCT

STRUCT: SHFILEINFO DROP
    0 ' ! ' @ propfield: hIcon
    4 ' ! ' @ propfield: iIcon
    8 ' ! ' @ propfield: dwAttributes
    12 ' Carr! ' Carr@ propfield: szDisplayName
    272 ' Carr! ' Carr@ propfield: szTypeName
352 ;STRUCT

STRUCT: SHFILEOPSTRUCT DROP
    0 ' ! ' @ propfield: hwnd
    4 ' ! ' @ propfield: wFunc
    8 ' ! ' @ propfield: pFrom
    12 ' ! ' @ propfield: pTo
    16 ' W! ' W@ propfield: fFlags
    18 ' ! ' @ propfield: fAnyOperationsAborted
    22 ' ! ' @ propfield: hNameMappings
    26 ' ! ' @ propfield: lpszProgressTitle
30 ;STRUCT

STRUCT: SHNAMEMAPPING DROP
    0 ' ! ' @ propfield: pszOldPath
    4 ' ! ' @ propfield: pszNewPath
    8 ' ! ' @ propfield: cchOldPath
    12 ' ! ' @ propfield: cchNewPath
16 ;STRUCT

STRUCT: SID_AND_ATTRIBUTES DROP
    0 ' ! ' @ propfield: Sid
    4 ' ! ' @ propfield: Attributes
8 ;STRUCT

STRUCT: SINGLE_LIST_ENTRY DROP
    0 ' ! ' @ propfield: Next
4 ;STRUCT

STRUCT: SOUNDSENTRY DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: iFSTextEffect
    12 ' ! ' @ propfield: iFSTextEffectMSec
    16 ' ! ' @ propfield: iFSTextEffectColorBits
    20 ' ! ' @ propfield: iFSGrafEffect
    24 ' ! ' @ propfield: iFSGrafEffectMSec
    28 ' ! ' @ propfield: iFSGrafEffectColor
    32 ' ! ' @ propfield: iWindowsEffect
    36 ' ! ' @ propfield: iWindowsEffectMSec
    40 ' ! ' @ propfield: lpszWindowsEffectDLL
    44 ' ! ' @ propfield: iWindowsEffectOrdinal
48 ;STRUCT

STRUCT: STARTUPINFO DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: lpReserved
    8 ' ! ' @ propfield: lpDesktop
    12 ' ! ' @ propfield: lpTitle
    16 ' ! ' @ propfield: dwX
    20 ' ! ' @ propfield: dwY
    24 ' ! ' @ propfield: dwXSize
    28 ' ! ' @ propfield: dwYSize
    32 ' ! ' @ propfield: dwXCountChars
    36 ' ! ' @ propfield: dwYCountChars
    40 ' ! ' @ propfield: dwFillAttribute
    44 ' ! ' @ propfield: dwFlags
    48 ' W! ' W@ propfield: wShowWindow
    50 ' W! ' W@ propfield: cbReserved2
    52 ' ! ' @ propfield: lpReserved2
    56 ' ! ' @ propfield: hStdInput
    60 ' ! ' @ propfield: hStdOutput
    64 ' ! ' @ propfield: hStdError
68 ;STRUCT

STRUCT: STICKYKEYS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
8 ;STRUCT

STRUCT: STRRET DROP
    0 ' ! ' @ propfield: uType
    4 ' ! ' @ propfield: pOleStr
    4 ' ! ' @ propfield: pStr
    4 ' ! ' @ propfield: uOffset
    4 ' Carr! ' Carr@ propfield: cStr
264 ;STRUCT

STRUCT: STYLEBUF DROP
    0 ' ! ' @ propfield: dwStyle
    4 ' Carr! ' Carr@ propfield: szDescription
36 ;STRUCT

STRUCT: STYLESTRUCT DROP
    0 ' ! ' @ propfield: styleOld
    4 ' ! ' @ propfield: styleNew
8 ;STRUCT

STRUCT: SYSTEM_AUDIT_ACE DROP
    0 ' Carr! ' Carr@ propfield: Header
    4 ' ! ' @ propfield: Mask
    8 ' ! ' @ propfield: SidStart
12 ;STRUCT

STRUCT: SYSTEM_INFO DROP
    4 ' ! ' @ propfield: dwPageSize
    8 ' ! ' @ propfield: lpMinimumApplicationAddress
    12 ' ! ' @ propfield: lpMaximumApplicationAddress
    16 ' ! ' @ propfield: dwActiveProcessorMask
    20 ' ! ' @ propfield: dwNumberOfProcessors
    24 ' ! ' @ propfield: dwProcessorType
    28 ' ! ' @ propfield: dwAllocationGranularity
    32 ' W! ' W@ propfield: wProcessorLevel
    34 ' W! ' W@ propfield: wProcessorRevision
36 ;STRUCT

STRUCT: SYSTEM_POWER_STATUS DROP
    0 ' C! ' C@ propfield: ACLineStatus
    1 ' C! ' C@ propfield: BatteryFlag
    2 ' C! ' C@ propfield: BatteryLifePercent
    3 ' C! ' C@ propfield: Reserved1
    4 ' ! ' @ propfield: BatteryLifeTime
    8 ' ! ' @ propfield: BatteryFullLifeTime
12 ;STRUCT

STRUCT: TAPE_ERASE DROP
    0 ' ! ' @ propfield: Type
8 ;STRUCT

STRUCT: TAPE_GET_DRIVE_PARAMETERS DROP
    0 ' C! ' C@ propfield: ECC
    1 ' C! ' C@ propfield: Compression
    2 ' C! ' C@ propfield: DataPadding
    3 ' C! ' C@ propfield: ReportSetmarks
    4 ' ! ' @ propfield: DefaultBlockSize
    8 ' ! ' @ propfield: MaximumBlockSize
    12 ' ! ' @ propfield: MinimumBlockSize
    16 ' ! ' @ propfield: MaximumPartitionCount
    20 ' ! ' @ propfield: FeaturesLow
    24 ' ! ' @ propfield: FeaturesHigh
    28 ' ! ' @ propfield: EOTWarningZoneSize
32 ;STRUCT

STRUCT: TAPE_GET_MEDIA_PARAMETERS DROP
    0 ' Carr! ' Carr@ propfield: Capacity
    8 ' Carr! ' Carr@ propfield: Remaining
    16 ' ! ' @ propfield: BlockSize
    20 ' ! ' @ propfield: PartitionCount
    24 ' C! ' C@ propfield: WriteProtected
32 ;STRUCT

STRUCT: TAPE_GET_POSITION DROP
    0 ' ! ' @ propfield: Type
    4 ' ! ' @ propfield: Partition
16 ;STRUCT

STRUCT: TAPE_PREPARE DROP
    0 ' ! ' @ propfield: Operation
8 ;STRUCT

STRUCT: TAPE_SET_DRIVE_PARAMETERS DROP
    0 ' C! ' C@ propfield: ECC
    1 ' C! ' C@ propfield: Compression
    2 ' C! ' C@ propfield: DataPadding
    3 ' C! ' C@ propfield: ReportSetmarks
    4 ' ! ' @ propfield: EOTWarningZoneSize
8 ;STRUCT

STRUCT: TAPE_SET_MEDIA_PARAMETERS DROP
    0 ' ! ' @ propfield: BlockSize
4 ;STRUCT

STRUCT: TAPE_SET_POSITION DROP
    0 ' ! ' @ propfield: Method
    4 ' ! ' @ propfield: Partition
24 ;STRUCT

STRUCT: TAPE_WRITE_MARKS DROP
    0 ' ! ' @ propfield: Type
    4 ' ! ' @ propfield: Count
12 ;STRUCT

STRUCT: TBADDBITMAP DROP
    0 ' ! ' @ propfield: hInst
    4 ' ! ' @ propfield: nID
8 ;STRUCT

STRUCT: TBBUTTON DROP
    0 ' ! ' @ propfield: iBitmap
    4 ' ! ' @ propfield: idCommand
    8 ' C! ' C@ propfield: fsState
    9 ' C! ' C@ propfield: fsStyle
    12 ' ! ' @ propfield: dwData
    16 ' ! ' @ propfield: iString
20 ;STRUCT

STRUCT: TBNOTIFY DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' ! ' @ propfield: iItem
    16 ' Carr! ' Carr@ propfield: tbButton
    36 ' ! ' @ propfield: cchText
    40 ' ! ' @ propfield: pszText
44 ;STRUCT

STRUCT: TBSAVEPARAMS DROP
    0 ' ! ' @ propfield: hkr
    4 ' ! ' @ propfield: pszSubKey
    8 ' ! ' @ propfield: pszValueName
12 ;STRUCT

STRUCT: TC_HITTESTINFO DROP
    0 ' Carr! ' Carr@ propfield: pt
    8 ' ! ' @ propfield: flags
12 ;STRUCT

STRUCT: TC_ITEM DROP
    0 ' ! ' @ propfield: mask
    12 ' ! ' @ propfield: pszText
    16 ' ! ' @ propfield: cchTextMax
    20 ' ! ' @ propfield: iImage
    24 ' ! ' @ propfield: lParam
28 ;STRUCT

STRUCT: TC_ITEMHEADER DROP
    0 ' ! ' @ propfield: mask
    4 ' ! ' @ propfield: lpReserved1
    8 ' ! ' @ propfield: lpReserved2
    12 ' ! ' @ propfield: pszText
    16 ' ! ' @ propfield: cchTextMax
    20 ' ! ' @ propfield: iImage
24 ;STRUCT

STRUCT: TC_KEYDOWN DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' W! ' W@ propfield: wVKey
    14 ' ! ' @ propfield: flags
18 ;STRUCT

STRUCT: TEXTRANGE DROP
    0 ' Carr! ' Carr@ propfield: chrg
    8 ' ! ' @ propfield: lpstrText
12 ;STRUCT

STRUCT: TIME_ZONE_INFORMATION DROP
    0 ' ! ' @ propfield: Bias
    4 ' Warr! ' Warr@ propfield: StandardName
    68 ' Carr! ' Carr@ propfield: StandardDate
    84 ' ! ' @ propfield: StandardBias
    88 ' Warr! ' Warr@ propfield: DaylightName
    152 ' Carr! ' Carr@ propfield: DaylightDate
    168 ' ! ' @ propfield: DaylightBias
172 ;STRUCT

STRUCT: TOGGLEKEYS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: dwFlags
8 ;STRUCT

STRUCT: TOKEN_SOURCE DROP
    0 ' Carr! ' Carr@ propfield: SourceName
    8 ' Carr! ' Carr@ propfield: SourceIdentifier
16 ;STRUCT

STRUCT: TOKEN_CONTROL DROP
    0 ' Carr! ' Carr@ propfield: TokenId
    8 ' Carr! ' Carr@ propfield: AuthenticationId
    16 ' Carr! ' Carr@ propfield: ModifiedId
    24 ' Carr! ' Carr@ propfield: TokenSource
40 ;STRUCT

STRUCT: TOKEN_DEFAULT_DACL DROP
    0 ' ! ' @ propfield: DefaultDacl
4 ;STRUCT

STRUCT: TOKEN_GROUPS DROP
    0 ' ! ' @ propfield: GroupCount
    4 ' Carr! ' Carr@ propfield: Groups
12 ;STRUCT

STRUCT: TOKEN_OWNER DROP
    0 ' ! ' @ propfield: Owner
4 ;STRUCT

STRUCT: TOKEN_PRIMARY_GROUP DROP
    0 ' ! ' @ propfield: PrimaryGroup
4 ;STRUCT

STRUCT: TOKEN_PRIVILEGES DROP
    0 ' ! ' @ propfield: PrivilegeCount
    4 ' Carr! ' Carr@ propfield: Privileges
16 ;STRUCT

STRUCT: TOKEN_STATISTICS DROP
    0 ' Carr! ' Carr@ propfield: TokenId
    8 ' Carr! ' Carr@ propfield: AuthenticationId
    16 ' Carr! ' Carr@ propfield: ExpirationTime
    24 ' ! ' @ propfield: TokenType
    28 ' ! ' @ propfield: ImpersonationLevel
    32 ' ! ' @ propfield: DynamicCharged
    36 ' ! ' @ propfield: DynamicAvailable
    40 ' ! ' @ propfield: GroupCount
    44 ' ! ' @ propfield: PrivilegeCount
    48 ' Carr! ' Carr@ propfield: ModifiedId
56 ;STRUCT

STRUCT: TOKEN_USER DROP
    0 ' Carr! ' Carr@ propfield: User
8 ;STRUCT

STRUCT: TOOLINFO DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: uFlags
    8 ' ! ' @ propfield: hwnd
    12 ' ! ' @ propfield: uId
    16 ' Carr! ' Carr@ propfield: rect
    32 ' ! ' @ propfield: hinst
    36 ' ! ' @ propfield: lpszText
44 ;STRUCT

STRUCT: TOOLTIPTEXT DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' ! ' @ propfield: lpszText
    16 ' Carr! ' Carr@ propfield: szText
    96 ' ! ' @ propfield: hinst
    100 ' ! ' @ propfield: uFlags
108 ;STRUCT

STRUCT: TPMPARAMS DROP
    0 ' ! ' @ propfield: cbSize
    4 ' Carr! ' Carr@ propfield: rcExclude
20 ;STRUCT

STRUCT: TRANSMIT_FILE_BUFFERS DROP
    0 ' ! ' @ propfield: Head
    4 ' ! ' @ propfield: HeadLength
    8 ' ! ' @ propfield: Tail
    12 ' ! ' @ propfield: TailLength
16 ;STRUCT

STRUCT: TTHITTESTINFO DROP
    0 ' ! ' @ propfield: hwnd
    4 ' Carr! ' Carr@ propfield: pt
    12 ' Carr! ' Carr@ propfield: ti
56 ;STRUCT

STRUCT: TTPOLYCURVE DROP
    0 ' W! ' W@ propfield: wType
    2 ' W! ' W@ propfield: cpfx
    4 ' Carr! ' Carr@ propfield: apfx
12 ;STRUCT

STRUCT: TTPOLYGONHEADER DROP
    0 ' ! ' @ propfield: cb
    4 ' ! ' @ propfield: dwType
    8 ' Carr! ' Carr@ propfield: pfxStart
16 ;STRUCT

STRUCT: TV_DISPINFO DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' Carr! ' Carr@ propfield: item
52 ;STRUCT

STRUCT: TV_HITTESTINFO DROP
    0 ' Carr! ' Carr@ propfield: pt
    8 ' ! ' @ propfield: flags
    12 ' ! ' @ propfield: hItem
16 ;STRUCT

STRUCT: TV_INSERTSTRUCT DROP
    0 ' ! ' @ propfield: hParent
    4 ' ! ' @ propfield: hInsertAfter
52 ;STRUCT

STRUCT: TV_KEYDOWN DROP
    0 ' Carr! ' Carr@ propfield: hdr
    12 ' W! ' W@ propfield: wVKey
    14 ' ! ' @ propfield: flags
18 ;STRUCT

STRUCT: TV_SORTCB DROP
    0 ' ! ' @ propfield: hParent
    4 ' ! ' @ propfield: lpfnCompare
    8 ' ! ' @ propfield: lParam
12 ;STRUCT

STRUCT: UDACCEL DROP
    0 ' ! ' @ propfield: nSec
    4 ' ! ' @ propfield: nInc
8 ;STRUCT

STRUCT: ULARGE_INTEGER DROP
    0 ' ! ' @ propfield: LowPart
    4 ' ! ' @ propfield: HighPart
8 ;STRUCT

STRUCT: UNIVERSAL_NAME_INFO DROP
    0 ' ! ' @ propfield: lpUniversalName
4 ;STRUCT

STRUCT: USEROBJECTFLAGS DROP
    0 ' ! ' @ propfield: fInherit
    4 ' ! ' @ propfield: fReserved
    8 ' ! ' @ propfield: dwFlags
12 ;STRUCT

STRUCT: VALENT DROP
    0 ' ! ' @ propfield: ve_valuename
    4 ' ! ' @ propfield: ve_valuelen
    8 ' ! ' @ propfield: ve_valueptr
    12 ' ! ' @ propfield: ve_type
16 ;STRUCT

STRUCT: VERIFY_INFORMATION DROP
    0 ' Carr! ' Carr@ propfield: StartingOffset
    8 ' ! ' @ propfield: Length
16 ;STRUCT

STRUCT: VS_FIXEDFILEINFO DROP
    0 ' ! ' @ propfield: dwSignature
    4 ' ! ' @ propfield: dwStrucVersion
    8 ' ! ' @ propfield: dwFileVersionMS
    12 ' ! ' @ propfield: dwFileVersionLS
    16 ' ! ' @ propfield: dwProductVersionMS
    20 ' ! ' @ propfield: dwProductVersionLS
    24 ' ! ' @ propfield: dwFileFlagsMask
    28 ' ! ' @ propfield: dwFileFlags
    32 ' ! ' @ propfield: dwFileOS
    36 ' ! ' @ propfield: dwFileType
    40 ' ! ' @ propfield: dwFileSubtype
    44 ' ! ' @ propfield: dwFileDateMS
    48 ' ! ' @ propfield: dwFileDateLS
52 ;STRUCT

STRUCT: WIN32_FIND_DATA DROP
    0 ' ! ' @ propfield: dwFileAttributes
    4 ' Carr! ' Carr@ propfield: ftCreationTime
    12 ' Carr! ' Carr@ propfield: ftLastAccessTime
    20 ' Carr! ' Carr@ propfield: ftLastWriteTime
    28 ' ! ' @ propfield: nFileSizeHigh
    32 ' ! ' @ propfield: nFileSizeLow
    36 ' ! ' @ propfield: dwReserved0
    40 ' ! ' @ propfield: dwReserved1
    44 ' Carr! ' Carr@ propfield: cFileName
    304 ' Carr! ' Carr@ propfield: cAlternateFileName
320 ;STRUCT

STRUCT: WIN32_STREAM_ID DROP
    0 ' ! ' @ propfield: dwStreamId
    4 ' ! ' @ propfield: dwStreamAttributes
    8 ' Carr! ' Carr@ propfield: Size
    16 ' ! ' @ propfield: dwStreamNameSize
    20 ' ! ' @ propfield: cStreamName
24 ;STRUCT

STRUCT: WINDOWPLACEMENT DROP
    0 ' ! ' @ propfield: length
    4 ' ! ' @ propfield: flags
    8 ' ! ' @ propfield: showCmd
    12 ' Carr! ' Carr@ propfield: ptMinPosition
    20 ' Carr! ' Carr@ propfield: ptMaxPosition
    28 ' Carr! ' Carr@ propfield: rcNormalPosition
44 ;STRUCT

STRUCT: WNDCLASS DROP
    0 ' ! ' @ propfield: style
    4 ' ! ' @ propfield: lpfnWndProc
    8 ' ! ' @ propfield: cbClsExtra
    12 ' ! ' @ propfield: cbWndExtra
    16 ' ! ' @ propfield: hInstance
    20 ' ! ' @ propfield: hIcon
    24 ' ! ' @ propfield: hCursor
    28 ' ! ' @ propfield: hbrBackground
    32 ' ! ' @ propfield: lpszMenuName
    36 ' ! ' @ propfield: lpszClassName
40 ;STRUCT

STRUCT: WNDCLASSEX DROP
    0 ' ! ' @ propfield: cbSize
    4 ' ! ' @ propfield: style
    8 ' ! ' @ propfield: lpfnWndProc
    12 ' ! ' @ propfield: cbClsExtra
    16 ' ! ' @ propfield: cbWndExtra
    20 ' ! ' @ propfield: hInstance
    24 ' ! ' @ propfield: hIcon
    28 ' ! ' @ propfield: hCursor
    32 ' ! ' @ propfield: hbrBackground
    36 ' ! ' @ propfield: lpszMenuName
    40 ' ! ' @ propfield: lpszClassName
    44 ' ! ' @ propfield: hIconSm
48 ;STRUCT

STRUCT: CONNECTDLGSTRUCT DROP
    0 ' ! ' @ propfield: cbStructure
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: lpConnRes
    12 ' ! ' @ propfield: dwFlags
    16 ' ! ' @ propfield: dwDevNum
20 ;STRUCT

STRUCT: DISCDLGSTRUCT DROP
    0 ' ! ' @ propfield: cbStructure
    4 ' ! ' @ propfield: hwndOwner
    8 ' ! ' @ propfield: lpLocalName
    12 ' ! ' @ propfield: lpRemoteName
    16 ' ! ' @ propfield: dwFlags
20 ;STRUCT

STRUCT: NETINFOSTRUCT DROP
    0 ' ! ' @ propfield: cbStructure
    4 ' ! ' @ propfield: dwProviderVersion
    8 ' ! ' @ propfield: dwStatus
    12 ' ! ' @ propfield: dwCharacteristics
    16 ' ! ' @ propfield: dwHandle
    20 ' W! ' W@ propfield: wNetType
    24 ' ! ' @ propfield: dwPrinters
    28 ' ! ' @ propfield: dwDrives
32 ;STRUCT

STRUCT: NETCONNECTINFOSTRUCT DROP
    0 ' ! ' @ propfield: cbStructure
    4 ' ! ' @ propfield: dwFlags
    8 ' ! ' @ propfield: dwSpeed
    12 ' ! ' @ propfield: dwDelay
    16 ' ! ' @ propfield: dwOptDataSize
20 ;STRUCT

STRUCT: POINTFLOAT DROP
    0 ' ! ' @ propfield: x
    4 ' ! ' @ propfield: y
8 ;STRUCT

STRUCT: GLYPHMETRICSFLOAT DROP
    0 ' ! ' @ propfield: gmfBlackBoxX
    4 ' ! ' @ propfield: gmfBlackBoxY
    8 ' Carr! ' Carr@ propfield: gmfptGlyphOrigin
    16 ' ! ' @ propfield: gmfCellIncX
    20 ' ! ' @ propfield: gmfCellIncY
24 ;STRUCT

STRUCT: LAYERPLANEDESCRIPTOR DROP
    0 ' W! ' W@ propfield: nSize
    2 ' W! ' W@ propfield: nVersion
    4 ' ! ' @ propfield: dwFlags
    8 ' C! ' C@ propfield: iPixelType
    9 ' C! ' C@ propfield: cColorBits
    10 ' C! ' C@ propfield: cRedBits
    11 ' C! ' C@ propfield: cRedShift
    12 ' C! ' C@ propfield: cGreenBits
    13 ' C! ' C@ propfield: cGreenShift
    14 ' C! ' C@ propfield: cBlueBits
    15 ' C! ' C@ propfield: cBlueShift
    16 ' C! ' C@ propfield: cAlphaBits
    17 ' C! ' C@ propfield: cAlphaShift
    18 ' C! ' C@ propfield: cAccumBits
    19 ' C! ' C@ propfield: cAccumRedBits
    20 ' C! ' C@ propfield: cAccumGreenBits
    21 ' C! ' C@ propfield: cAccumBlueBits
    22 ' C! ' C@ propfield: cAccumAlphaBits
    23 ' C! ' C@ propfield: cDepthBits
    24 ' C! ' C@ propfield: cStencilBits
    25 ' C! ' C@ propfield: cAuxBuffers
    26 ' C! ' C@ propfield: iLayerPlane
    27 ' C! ' C@ propfield: bReserved
    28 ' ! ' @ propfield: crTransparent
32 ;STRUCT

STRUCT: PIXELFORMATDESCRIPTOR DROP
    0 ' W! ' W@ propfield: nSize
    2 ' W! ' W@ propfield: nVersion
    4 ' ! ' @ propfield: dwFlags
    8 ' C! ' C@ propfield: iPixelType
    9 ' C! ' C@ propfield: cColorBits
    10 ' C! ' C@ propfield: cRedBits
    11 ' C! ' C@ propfield: cRedShift
    12 ' C! ' C@ propfield: cGreenBits
    13 ' C! ' C@ propfield: cGreenShift
    14 ' C! ' C@ propfield: cBlueBits
    15 ' C! ' C@ propfield: cBlueShift
    16 ' C! ' C@ propfield: cAlphaBits
    17 ' C! ' C@ propfield: cAlphaShift
    18 ' C! ' C@ propfield: cAccumBits
    19 ' C! ' C@ propfield: cAccumRedBits
    20 ' C! ' C@ propfield: cAccumGreenBits
    21 ' C! ' C@ propfield: cAccumBlueBits
    22 ' C! ' C@ propfield: cAccumAlphaBits
    23 ' C! ' C@ propfield: cDepthBits
    24 ' C! ' C@ propfield: cStencilBits
    25 ' C! ' C@ propfield: cAuxBuffers
    26 ' C! ' C@ propfield: iLayerType
    27 ' C! ' C@ propfield: bReserved
    28 ' ! ' @ propfield: dwLayerMask
    32 ' ! ' @ propfield: dwVisibleMask
    36 ' ! ' @ propfield: dwDamageMask
40 ;STRUCT

STRUCT: USER_INFO_2 DROP
    0 ' ! ' @ propfield: usri2_name
    4 ' ! ' @ propfield: usri2_password
    8 ' ! ' @ propfield: usri2_password_age
    12 ' ! ' @ propfield: usri2_priv
    16 ' ! ' @ propfield: usri2_home_dir
    20 ' ! ' @ propfield: usri2_comment
    24 ' ! ' @ propfield: usri2_flags
    28 ' ! ' @ propfield: usri2_script_path
    32 ' ! ' @ propfield: usri2_auth_flags
    36 ' ! ' @ propfield: usri2_full_name
    40 ' ! ' @ propfield: usri2_usr_comment
    44 ' ! ' @ propfield: usri2_parms
    48 ' ! ' @ propfield: usri2_workstations
    52 ' ! ' @ propfield: usri2_last_logon
    56 ' ! ' @ propfield: usri2_last_logoff
    60 ' ! ' @ propfield: usri2_acct_expires
    64 ' ! ' @ propfield: usri2_max_storage
    68 ' ! ' @ propfield: usri2_units_per_week
    72 ' ! ' @ propfield: usri2_logon_hours
    76 ' ! ' @ propfield: usri2_bad_pw_count
    80 ' ! ' @ propfield: usri2_num_logons
    84 ' ! ' @ propfield: usri2_logon_server
    88 ' ! ' @ propfield: usri2_country_code
    92 ' ! ' @ propfield: usri2_code_page
96 ;STRUCT

STRUCT: USER_INFO_0 DROP
    0 ' ! ' @ propfield: usri0_name
4 ;STRUCT

STRUCT: USER_INFO_3 DROP
    0 ' ! ' @ propfield: usri3_name
    4 ' ! ' @ propfield: usri3_password
    8 ' ! ' @ propfield: usri3_password_age
    12 ' ! ' @ propfield: usri3_priv
    16 ' ! ' @ propfield: usri3_home_dir
    20 ' ! ' @ propfield: usri3_comment
    24 ' ! ' @ propfield: usri3_flags
    28 ' ! ' @ propfield: usri3_script_path
    32 ' ! ' @ propfield: usri3_auth_flags
    36 ' ! ' @ propfield: usri3_full_name
    40 ' ! ' @ propfield: usri3_usr_comment
    44 ' ! ' @ propfield: usri3_parms
    48 ' ! ' @ propfield: usri3_workstations
    52 ' ! ' @ propfield: usri3_last_logon
    56 ' ! ' @ propfield: usri3_last_logoff
    60 ' ! ' @ propfield: usri3_acct_expires
    64 ' ! ' @ propfield: usri3_max_storage
    68 ' ! ' @ propfield: usri3_units_per_week
    72 ' ! ' @ propfield: usri3_logon_hours
    76 ' ! ' @ propfield: usri3_bad_pw_count
    80 ' ! ' @ propfield: usri3_num_logons
    84 ' ! ' @ propfield: usri3_logon_server
    88 ' ! ' @ propfield: usri3_country_code
    92 ' ! ' @ propfield: usri3_code_page
    96 ' ! ' @ propfield: usri3_user_id
    100 ' ! ' @ propfield: usri3_primary_group_id
    104 ' ! ' @ propfield: usri3_profile
    108 ' ! ' @ propfield: usri3_home_dir_drive
    112 ' ! ' @ propfield: usri3_password_expired
116 ;STRUCT

STRUCT: GROUP_INFO_2 DROP
    0 ' ! ' @ propfield: grpi2_name
    4 ' ! ' @ propfield: grpi2_comment
    8 ' ! ' @ propfield: grpi2_group_id
    12 ' ! ' @ propfield: grpi2_attributes
16 ;STRUCT

STRUCT: LOCALGROUP_INFO_0 DROP
    0 ' ! ' @ propfield: lgrpi0_name
4 ;STRUCT

STRUCT: IMAGE_DOS_HEADER DROP
    0 ' W! ' W@ propfield: e_magic
    2 ' W! ' W@ propfield: e_cblp
    4 ' W! ' W@ propfield: e_cp
    6 ' W! ' W@ propfield: e_crlc
    8 ' W! ' W@ propfield: e_cparhdr
    10 ' W! ' W@ propfield: e_minalloc
    12 ' W! ' W@ propfield: e_maxalloc
    14 ' W! ' W@ propfield: e_ss
    16 ' W! ' W@ propfield: e_sp
    18 ' W! ' W@ propfield: e_csum
    20 ' W! ' W@ propfield: e_ip
    22 ' W! ' W@ propfield: e_cs
    24 ' W! ' W@ propfield: e_lfarlc
    26 ' W! ' W@ propfield: e_ovno
    28 ' Warr! ' Warr@ propfield: e_res
    36 ' W! ' W@ propfield: e_oemid
    38 ' W! ' W@ propfield: e_oeminfo
    40 ' Warr! ' Warr@ propfield: e_res2
    60 ' ! ' @ propfield: e_lfanew
64 ;STRUCT

STRUCT: IMAGE_OS2_HEADER DROP
    0 ' W! ' W@ propfield: ne_magic
    2 ' C! ' C@ propfield: ne_ver
    3 ' C! ' C@ propfield: ne_rev
    4 ' W! ' W@ propfield: ne_enttab
    6 ' W! ' W@ propfield: ne_cbenttab
    8 ' ! ' @ propfield: ne_crc
    12 ' W! ' W@ propfield: ne_flags
    14 ' W! ' W@ propfield: ne_autodata
    16 ' W! ' W@ propfield: ne_heap
    18 ' W! ' W@ propfield: ne_stack
    20 ' ! ' @ propfield: ne_csip
    24 ' ! ' @ propfield: ne_sssp
    28 ' W! ' W@ propfield: ne_cseg
    30 ' W! ' W@ propfield: ne_cmod
    32 ' W! ' W@ propfield: ne_cbnrestab
    34 ' W! ' W@ propfield: ne_segtab
    36 ' W! ' W@ propfield: ne_rsrctab
    38 ' W! ' W@ propfield: ne_restab
    40 ' W! ' W@ propfield: ne_modtab
    42 ' W! ' W@ propfield: ne_imptab
    44 ' ! ' @ propfield: ne_nrestab
    48 ' W! ' W@ propfield: ne_cmovent
    50 ' W! ' W@ propfield: ne_align
    52 ' W! ' W@ propfield: ne_cres
    54 ' C! ' C@ propfield: ne_exetyp
    55 ' C! ' C@ propfield: ne_flagsothers
    56 ' W! ' W@ propfield: ne_pretthunks
    58 ' W! ' W@ propfield: ne_psegrefbytes
    60 ' W! ' W@ propfield: ne_swaparea
    62 ' W! ' W@ propfield: ne_expver
64 ;STRUCT

STRUCT: IMAGE_VXD_HEADER DROP
    0 ' W! ' W@ propfield: e32_magic
    2 ' C! ' C@ propfield: e32_border
    3 ' C! ' C@ propfield: e32_worder
    4 ' ! ' @ propfield: e32_level
    8 ' W! ' W@ propfield: e32_cpu
    10 ' W! ' W@ propfield: e32_os
    12 ' ! ' @ propfield: e32_ver
    16 ' ! ' @ propfield: e32_mflags
    20 ' ! ' @ propfield: e32_mpages
    24 ' ! ' @ propfield: e32_startobj
    28 ' ! ' @ propfield: e32_eip
    32 ' ! ' @ propfield: e32_stackobj
    36 ' ! ' @ propfield: e32_esp
    40 ' ! ' @ propfield: e32_pagesize
    44 ' ! ' @ propfield: e32_lastpagesize
    48 ' ! ' @ propfield: e32_fixupsize
    56 ' ! ' @ propfield: e32_ldrsize
    60 ' ! ' @ propfield: e32_ldrsum
    64 ' ! ' @ propfield: e32_objtab
    68 ' ! ' @ propfield: e32_objcnt
    72 ' ! ' @ propfield: e32_objmap
    76 ' ! ' @ propfield: e32_itermap
    80 ' ! ' @ propfield: e32_rsrctab
    84 ' ! ' @ propfield: e32_rsrccnt
    88 ' ! ' @ propfield: e32_restab
    92 ' ! ' @ propfield: e32_enttab
    96 ' ! ' @ propfield: e32_dirtab
    100 ' ! ' @ propfield: e32_dircnt
    104 ' ! ' @ propfield: e32_fpagetab
    108 ' ! ' @ propfield: e32_frectab
    112 ' ! ' @ propfield: e32_impmod
    116 ' ! ' @ propfield: e32_impmodcnt
    120 ' ! ' @ propfield: e32_impproc
    124 ' ! ' @ propfield: e32_pagesum
    128 ' ! ' @ propfield: e32_datapage
    132 ' ! ' @ propfield: e32_preload
    136 ' ! ' @ propfield: e32_nrestab
    140 ' ! ' @ propfield: e32_cbnrestab
    144 ' ! ' @ propfield: e32_nressum
    148 ' ! ' @ propfield: e32_autodata
    152 ' ! ' @ propfield: e32_debuginfo
    156 ' ! ' @ propfield: e32_debuglen
    160 ' ! ' @ propfield: e32_instpreload
    164 ' ! ' @ propfield: e32_instdemand
    168 ' ! ' @ propfield: e32_heapsize
    172 ' Carr! ' Carr@ propfield: e32_res3
    184 ' ! ' @ propfield: e32_winresoff
    188 ' ! ' @ propfield: e32_winreslen
    192 ' W! ' W@ propfield: e32_devid
    194 ' W! ' W@ propfield: e32_ddkver
196 ;STRUCT

;MODULE
