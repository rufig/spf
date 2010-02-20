REQUIRE CapInit          ~ac/lib/win/mm/capture.f 
REQUIRE GetDesktopWindow ~ac/lib/win/window/enumwindows.f 

:NONAME 
  \ ." QueryInterface " на практике не вызывается, поэтому не проверено
  { ppv riid this -- x }
  
  riid 16 IID_IUnknown 16 COMPARE 0=
  riid 16 IID_ISampleGrabberCB 16 COMPARE 0= OR
  IF this ppv ! 0
  ELSE E_NOINTERFACE THEN
; 3 CELLS CALLBACK: (CB::QueryInterface)

:NONAME ( this -- x )
  \ ." AddRef " вызывается
  DROP 2
; 1 CELLS CALLBACK: (CB::AddRef)

:NONAME ( this -- x )
  \ ." Release "
  DROP 1
; 1 CELLS CALLBACK: (CB::Release)

:NONAME { pSample SampleTime2 SampleTime1 this -- x }
  \ ." SampleCB "
  0
; 4 CELLS CALLBACK: (CB::SampleCB)

:NONAME ( lBufferSize pBuffer dblSampleTime2 dblSampleTime1 this -- x )
  \ ." BufferCB " вызывается
  DUP @ CB.xt @ ?DUP IF EXECUTE ELSE DROP 2DROP 2DROP THEN
  0
; 5 CELLS CALLBACK: (CB::BufferCB)

WINAPI: CoTaskMemFree OLE32.DLL
WINAPI: SetRect USER32.DLL
VARIABLE pCB

: CapOpen { xt \ pGraph pCaptureBuilder pControl pDevEnum pEnumMoniker moniker fetched n property vax1 vav vax2 var pSrcFilter pSampleGrabberFilter pSampleGrabber mt pMediaControl pVMR9 pFilterConfig pWindowssCtrl cb sr dr -- pControl }

  \ инициализация процесса получения кадров, подключение к камере.
  \ xt - фортовый колбэк, которому передаются параметры BufferCB с данными кадра

  DsInit -> pGraph ( GraphBilder)

  CapInit -> pCaptureBuilder
  pGraph pCaptureBuilder ::SetFiltergraph THROW
  ^ pControl IID_IMediaControl pGraph ::QueryInterface THROW
  CapDevEnumInit -> pDevEnum

  0 ^ pEnumMoniker
  S" {860BB310-5D01-11d0-BD3B-00A0C911CE86}" >UNICODE String>CLSID THROW \ CLSID_VideoInputDeviceCategory
  pDevEnum ::CreateClassEnumerator 1 = IF ." Нет видеокамеры." EXIT THEN
  \  ['] .. pEnumMoniker EnumVariant . \ универсальный enum не очень подходит, т.к. тип значений не variant

  \ активация последней камеры в списке
  BEGIN
    ^ fetched ^ moniker 1 pEnumMoniker ::Next 0=
  WHILE
    ^ property IID_IPropertyBag 0 0 moniker ::BindToStorage THROW
    0 ^ var S" FriendlyName" >BSTR property ::Read 0=
    IF var 8 = IF vav UASCIIZ> UNICODE> TYPE CR THEN THEN
    property ::Release DROP
    ^ pSrcFilter IID_IBaseFilter 0 0 moniker ::BindToObject THROW
    n 1+ -> n
  REPEAT
  pEnumMoniker ::Release DROP  pDevEnum ::Release DROP
  n 0= IF ." Нет видеокамеры?" EXIT THEN
  pSrcFilter 0= IF ." Не удалось подключиться к видеокамере." EXIT THEN

  S" Capture Filter" >BSTR pSrcFilter pGraph ::AddFilter THROW

  SampleGrabberInit DUP -> pSampleGrabberFilter
  0= IF ." Требуется DirectX 8 и регистрация qedit.dll." EXIT THEN

  ^ pSampleGrabber IID_ISampleGrabber pSampleGrabberFilter ::QueryInterface THROW

  /AM_MEDIA_TYPE ALLOCATE THROW -> mt
  ( MEDIATYPE_Video) S" {73646976-0000-0010-8000-00AA00389B71}" >UNICODE String>CLSID THROW mt AMT.majortype 16 MOVE
  ( MEDIASUBTYPE_RGB24) S" {e436eb7d-524f-11ce-9f53-0020af0ba770}" >UNICODE String>CLSID THROW mt AMT.subtype 16 MOVE
\  ( FORMAT_VideoInfo) S" {05589f80-c356-11ce-bf01-00aa0055595a}" >UNICODE String>CLSID THROW mt AMT.formattype 16 MOVE
  mt pSampleGrabber ::SetMediaType THROW

  S" Sample Grabber" >BSTR pSampleGrabberFilter pGraph ::AddFilter THROW

  VideoMixingRendererInit -> pVMR9
  S" Video Mixing Renderer" >BSTR pVMR9 pGraph ::AddFilter THROW

  ^ pFilterConfig IID_IVMRFilterConfig pVMR9 ::QueryInterface THROW
  VMRMode_Windowless pFilterConfig ::SetRenderingMode THROW

  ^ pWindowssCtrl IID_IVMRWindowlessControl pVMR9 ::QueryInterface THROW
  GetDesktopWindow pWindowssCtrl ::SetVideoClippingWindow THROW

  \ если вместо pVMR9 передать 0, то появится окно ActiveMovie
  pVMR9 pSampleGrabberFilter pSrcFilter
  ( MEDIATYPE_Video) S" {73646976-0000-0010-8000-00AA00389B71}" >UNICODE String>CLSID THROW
  ( PIN_CATEGORY_PREVIEW) S" {fb6c4282-0353-11d1-905f-0000c0cc16ba}" >UNICODE String>CLSID THROW
  pCaptureBuilder ::RenderStream DROP \ ( 4027E) HEX . DECIMAL CR

  /CB ALLOCATE THROW -> cb
  mt pSampleGrabber ::GetConnectedMediaType ?DUP IF HEX U. ." Камера занята?" EXIT THEN \ VFW_E_NOT_CONNECTED=0x80040209
  mt AMT.pbFormat @ VIH.bmiHeader BMI.biWidth @ DUP cb CB.width ! . ." x "
  mt AMT.pbFormat @ VIH.bmiHeader BMI.biHeight @ DUP cb CB.height ! . ." @"
  mt AMT.pbFormat @ VIH.bmiHeader BMI.biBitCount W@ . CR
  mt AMT.cbFormat @ IF mt AMT.pbFormat @ CoTaskMemFree DROP mt AMT.cbFormat 0! mt AMT.pbFormat 0! THEN
  mt AMT.pUnk @ ?DUP IF ::Release DROP mt AMT.pUnk 0! THEN

  0 pSampleGrabber ::SetBufferSamples DROP
  0 pSampleGrabber ::SetOneShot DROP

  ['] (CB::QueryInterface) cb CB.QueryInterface !
  ['] (CB::AddRef) cb CB.AddRef !
  ['] (CB::Release) cb CB.Release !
  ['] (CB::SampleCB) cb CB.SampleCB !
  ['] (CB::BufferCB) cb CB.BufferCB !
  xt cb CB.xt !
\  1 ^ cb pSampleGrabber ::SetCallback DROP
  cb pCB ! \ указатель продолжает использоваться grabber'ом и после
           \ выхода из функции, поэтому нельзя оставлять его указателем на стек возвратов
  1 pCB pSampleGrabber ::SetCallback DROP

  /RECT ALLOCATE THROW -> sr
  cb CB.height @ cb CB.width @ 0 0 sr SetRect DROP

  /RECT ALLOCATE THROW -> dr
  cb CB.height @ cb CB.width @ 0 0 dr SetRect DROP

  dr sr pWindowssCtrl ::SetVideoPosition DROP
  pControl
;
: CapStart ( pControl -- )
  ::Run ( 1) DROP
\  PAD 1000 pControl ::GetState .
;
: CapStop ( pControl -- )
  ::Stop_mc ( 0) DROP
\  pCaptureBuilder ::Release .
;

