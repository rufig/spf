REQUIRE DsInit           ~ac/lib/win/mm/directshow.f 

IID_IUnknown
Interface: IID_ICaptureGraphBuilder2 {93E5A4E0-2D50-11d2-ABFA-00A0C9C6E38D}

  Method: ::SetFiltergraph ( 
            /* [in] */ IGraphBuilder *pfg)
        
  Method: ::GetFiltergraph ( 
            /* [out] */ IGraphBuilder **ppfg)
        
  Method: ::SetOutputFileName ( 
            /* [in] */ const GUID *pType,
            /* [in] */ LPCOLESTR lpstrFile,
            /* [out] */ IBaseFilter **ppf,
            /* [out] */ IFileSinkFilter **ppSink)
        
  Method: ::FindInterface ( 
            /* [in] */ const GUID *pCategory,
            /* [in] */ const GUID *pType,
            /* [in] */ IBaseFilter *pf,
            /* [in] */ REFIID riid,
            /* [out] */ void **ppint)
        
  Method: ::RenderStream ( 
            /* [in] */ const GUID *pCategory,
            /* [in] */ const GUID *pType,
            /* [in] */ IUnknown *pSource,
            /* [in] */ IBaseFilter *pfCompressor,
            /* [in] */ IBaseFilter *pfRenderer)
        
  Method: ::ControlStream ( 
            /* [in] */ const GUID *pCategory,
            /* [in] */ const GUID *pType,
            /* [in] */ IBaseFilter *pFilter,
            /* [in] */ REFERENCE_TIME *pstart,
            /* [in] */ REFERENCE_TIME *pstop,
            /* [in] */ WORD wStartCookie,
            /* [in] */ WORD wStopCookie)
        
  Method: ::AllocCapFile ( 
            /* [in] */ LPCOLESTR lpstr,
            /* [in] */ DWORDLONG dwlSize)
        
  Method: ::CopyCaptureFile ( 
            /* [in] */ LPOLESTR lpwstrOld,
            /* [in] */ LPOLESTR lpwstrNew,
            /* [in] */ int fAllowEscAbort,
            /* [in] */ IAMCopyCaptureFileProgress *pCallback)
        
  Method: ::FindPin ( 
            /* [in] */ IUnknown *pSource,
            /* [in] */ PIN_DIRECTION pindir,
            /* [in] */ const GUID *pCategory,
            /* [in] */ const GUID *pType,
            /* [in] */ BOOL fUnconnected,
            /* [in] */ int num,
            /* [out] */ IPin **ppPin)
Interface;

IID_IUnknown
Interface: IID_ICreateDevEnum {29840822-5B84-11D0-BD3B-00A0C911CE86}
  Method: ::CreateClassEnumerator ( 
            /* [in] */ REFCLSID clsidDeviceClass,
            /* [out] */ IEnumMoniker **ppEnumMoniker,
            /* [in] */ DWORD dwFlags)
Interface;

IID_IEnumVariant
 \ те же методы, поэтому имитируем наследование
Interface: IID_IEnumMoniker {00000102-0000-0000-C000-000000000046}
Interface;


IID_IUnknown
Interface: IID_IPersist {0000010c-0000-0000-C000-000000000046}
  Method: ::GetClassID ( 
            /* [out] */ CLSID *pClassID)
Interface;

IID_IPersist
Interface: IID_IPersistStream {00000109-0000-0000-C000-000000000046}
  Method: ::IsDirty ( void)
        
  Method: ::Load ( 
            /* [unique][in] */ IStream *pStm)
        
  Method: ::Save ( 
            /* [unique][in] */ IStream *pStm,
            /* [in] */ BOOL fClearDirty)
        
  Method: ::GetSizeMax ( 
            /* [out] */ ULARGE_INTEGER *pcbSize)
Interface;

IID_IPersistStream
Interface: IID_IMoniker {0000000f-0000-0000-C000-000000000046}
  Method: ::BindToObject ( 
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [in] */ REFIID riidResult,
            /* [iid_is][out] */ void **ppvResult)
        
  Method: ::BindToStorage ( 
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObj)
        
  Method: ::Reduce ( 
            /* [unique][in] */ IBindCtx *pbc,
            /* [in] */ DWORD dwReduceHowFar,
            /* [unique][out][in] */ IMoniker **ppmkToLeft,
            /* [out] */ IMoniker **ppmkReduced)
        
  Method: ::ComposeWith ( 
            /* [unique][in] */ IMoniker *pmkRight,
            /* [in] */ BOOL fOnlyIfNotGeneric,
            /* [out] */ IMoniker **ppmkComposite)
        
  Method: ::Enum ( 
            /* [in] */ BOOL fForward,
            /* [out] */ IEnumMoniker **ppenumMoniker)
        
  Method: ::IsEqual ( 
            /* [unique][in] */ IMoniker *pmkOtherMoniker)
        
  Method: ::Hash ( 
            /* [out] */ DWORD *pdwHash)
        
  Method: ::IsRunning ( 
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [unique][in] */ IMoniker *pmkNewlyRunning)
        
  Method: ::GetTimeOfLastChange ( 
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [out] */ FILETIME *pFileTime)
        
  Method: ::Inverse ( 
            /* [out] */ IMoniker **ppmk)
        
  Method: ::CommonPrefixWith ( 
            /* [unique][in] */ IMoniker *pmkOther,
            /* [out] */ IMoniker **ppmkPrefix)
        
  Method: ::RelativePathTo ( 
            /* [unique][in] */ IMoniker *pmkOther,
            /* [out] */ IMoniker **ppmkRelPath)
        
  Method: ::GetDisplayName ( 
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [out] */ LPOLESTR *ppszDisplayName)
        
  Method: ::ParseDisplayName ( 
            /* [unique][in] */ IBindCtx *pbc,
            /* [unique][in] */ IMoniker *pmkToLeft,
            /* [in] */ LPOLESTR pszDisplayName,
            /* [out] */ ULONG *pchEaten,
            /* [out] */ IMoniker **ppmkOut)
        
  Method: ::IsSystemMoniker ( 
            /* [out] */ DWORD *pdwMksys)
Interface;

IID_IUnknown
Interface: IID_IPropertyBag {55272A00-42CB-11CE-8135-00AA004BB851}
  Method: ::Read ( 
            /* [in] */ LPCOLESTR pszPropName,
            /* [out][in] */ VARIANT *pVar,
            /* [in] */ IErrorLog *pErrorLog)
        
  Method: ::Write ( 
            /* [in] */ LPCOLESTR pszPropName,
            /* [in] */ VARIANT *pVar)
Interface;

IID_IPersist
Interface: IID_IMediaFilter {56a86899-0ad4-11ce-b03a-0020af0ba770}

  Method: ::Stop_mf ( void)
        
  Method: ::Pause_mf ( void)
        
  Method: ::Run_mf ( 
            REFERENCE_TIME tStart)
        
  Method: ::GetState_mf ( 
            /* [in] */ DWORD dwMilliSecsTimeout,
            /* [out] */ FILTER_STATE *State)
        
  Method: ::SetSyncSource_mf ( 
            /* [in] */ IReferenceClock *pClock)
        
  Method: ::GetSyncSource_mf ( 
            /* [out] */ IReferenceClock **pClock)
Interface;

IID_IMediaFilter
Interface: IID_IBaseFilter {56a86895-0ad4-11ce-b03a-0020af0ba770}
  Method: ::EnumPins ( 
            /* [out] */ IEnumPins **ppEnum)
        
  Method: ::FindPin ( 
            /* [string][in] */ LPCWSTR Id,
            /* [out] */ IPin **ppPin)
        
  Method: ::QueryFilterInfo ( 
            /* [out] */ FILTER_INFO *pInfo)
        
  Method: ::JoinFilterGraph ( 
            /* [in] */ IFilterGraph *pGraph,
            /* [string][in] */ LPCWSTR pName)
        
  Method: ::QueryVendorInfo ( 
            /* [string][out] */ LPWSTR *pVendorInfo)
Interface;

IID_IUnknown
Interface: IID_ISampleGrabber {6B652FFF-11FE-4fce-92AD-0266B5D7C78F}
  Method: ::SetOneShot ( 
            BOOL OneShot)
        
  Method: ::SetMediaType ( 
            const AM_MEDIA_TYPE *pType)
        
  Method: ::GetConnectedMediaType ( 
            AM_MEDIA_TYPE *pType)
        
  Method: ::SetBufferSamples ( 
            BOOL BufferThem)
        
  Method: ::GetCurrentBuffer ( 
            /* [out][in] */ long *pBufferSize,
            /* [out] */ long *pBuffer)
        
  Method: ::GetCurrentSample ( 
            /* [retval][out] */ IMediaSample **ppSample)
        
  Method: ::SetCallback ( 
            ISampleGrabberCB *pCallback,
            long WhichMethodToCallback)
Interface;

IID_IUnknown
Interface: IID_IVMRFilterConfig {9e5530c5-7034-48b4-bb46-0b8a6efc8e36}
  Method: ::SetImageCompositor ( 
            /* [in] */ IVMRImageCompositor *lpVMRImgCompositor)
        
  Method: ::SetNumberOfStreams ( 
            /* [in] */ DWORD dwMaxStreams)
        
  Method: ::GetNumberOfStreams ( 
            /* [out] */ DWORD *pdwMaxStreams)
        
  Method: ::SetRenderingPrefs ( 
            /* [in] */ DWORD dwRenderFlags)
        
  Method: ::GetRenderingPrefs ( 
            /* [out] */ DWORD *pdwRenderFlags)
        
  Method: ::SetRenderingMode ( 
            /* [in] */ DWORD Mode)
        
  Method: ::GetRenderingMode ( 
            /* [out] */ DWORD *pMode)
Interface;

IID_IUnknown
Interface: IID_IVMRWindowlessControl {0eb1088c-4dcd-46f0-878f-39dae86a51b7}
  Method: ::GetNativeVideoSize ( 
            /* [out] */ LONG *lpWidth,
            /* [out] */ LONG *lpHeight,
            /* [out] */ LONG *lpARWidth,
            /* [out] */ LONG *lpARHeight)
        
  Method: ::GetMinIdealVideoSize ( 
            /* [out] */ LONG *lpWidth,
            /* [out] */ LONG *lpHeight)
        
  Method: ::GetMaxIdealVideoSize ( 
            /* [out] */ LONG *lpWidth,
            /* [out] */ LONG *lpHeight)
        
  Method: ::SetVideoPosition ( 
            /* [in] */ const LPRECT lpSRCRect,
            /* [in] */ const LPRECT lpDSTRect)
        
  Method: ::GetVideoPosition ( 
            /* [out] */ LPRECT lpSRCRect,
            /* [out] */ LPRECT lpDSTRect)
        
  Method: ::GetAspectRatioMode ( 
            /* [out] */ DWORD *lpAspectRatioMode)
        
  Method: ::SetAspectRatioMode ( 
            /* [in] */ DWORD AspectRatioMode)
        
  Method: ::SetVideoClippingWindow ( 
            /* [in] */ HWND hwnd)
        
  Method: ::RepaintVideo ( 
            /* [in] */ HWND hwnd,
            /* [in] */ HDC hdc)
        
  Method: ::DisplayModeChanged ( void)
        
  Method: ::GetCurrentImage ( 
            /* [out] */ BYTE **lpDib)
        
  Method: ::SetBorderColor ( 
            /* [in] */ COLORREF Clr)
        
  Method: ::GetBorderColor ( 
            /* [out] */ COLORREF *lpClr)
        
  Method: ::SetColorKey ( 
            /* [in] */ COLORREF Clr)
        
  Method: ::GetColorKey ( 
            /* [out] */ COLORREF *lpClr)
Interface;

IID_IUnknown
Interface: IID_ISampleGrabberCB {0579154A-2B53-4994-B0D0-E773148EFF85}
\ CALLBACK !
  Method: ::SampleCB ( 
            double SampleTime,
            IMediaSample *pSample)
        
  Method: ::BufferCB ( 
            double SampleTime,
            BYTE *pBuffer,
            long BufferLen)
Interface;

 2 CONSTANT VMRMode_Windowless
16 CONSTANT /GUID

0
CELL -- R.left
CELL -- R.top
CELL -- R.right
CELL -- R.bottom
CONSTANT /RECT

0
/GUID -- AMT.majortype
/GUID -- AMT.subtype
 CELL -- AMT.bFixedSizeSamples
 CELL -- AMT.bTemporalCompression
 CELL -- AMT.lSampleSize
/GUID -- AMT.formattype
 CELL -- AMT.pUnk
 CELL -- AMT.cbFormat
 CELL -- AMT.pbFormat
CONSTANT /AM_MEDIA_TYPE


0
CELL -- BMI.biSize
CELL -- BMI.biWidth
CELL -- BMI.biHeight
   2 -- BMI.biPlanes
   2 -- BMI.biBitCount
CELL -- BMI.biCompression
CELL -- BMI.biSizeImage
CELL -- BMI.biXPelsPerMeter
CELL -- BMI.biYPelsPerMeter
CELL -- BMI.biClrUsed
CELL -- BMI.biClrImportant
CONSTANT /BITMAPINFOHEADER

0
/RECT -- VIH.rcSource
/RECT -- VIH.rcTarget
 CELL -- VIH.dwBitRate
 CELL -- VIH.dwBitErrorRate
    8 -- VIH.AvgTimePerFrame
/BITMAPINFOHEADER -- VIH.bmiHeader
CONSTANT /VIDEOINFOHEADER

: CapInit { \ pCaptureBuilder -- pCaptureBuilder }
  \ ComInit THROW
  ^ pCaptureBuilder IID_ICaptureGraphBuilder2 CLSCTX_INPROC_SERVER 0
  S" {BF87B6E1-8C27-11d0-B3F0-00AA003761C5}" >UNICODE String>CLSID THROW
  CoCreateInstance THROW
  pCaptureBuilder
;
: CapDevEnumInit { \ pCreateDevEnum -- pCreateDevEnum }
  ^ pCreateDevEnum IID_ICreateDevEnum CLSCTX_INPROC_SERVER 0
  S" {62BE5D10-60EB-11d0-BD3B-00A0C911CE86}" >UNICODE String>CLSID THROW \ CLSID_SystemDeviceEnum
  CoCreateInstance THROW
  pCreateDevEnum
;
: SampleGrabberInit { \ pSampleGrabberFilter -- pSampleGrabberFilter }
  \ требуется DX8, qedit.dll
  ^ pSampleGrabberFilter IID_IBaseFilter CLSCTX_INPROC_SERVER 0
  S" {C1F400A0-3F08-11d3-9F0B-006008039E37}" >UNICODE String>CLSID THROW \ CLSID_SampleGrabber
  CoCreateInstance THROW
  pSampleGrabberFilter
;
: VideoMixingRendererInit { \ pVMR9 -- pVMR9 }
  ^ pVMR9 IID_IBaseFilter CLSCTX_INPROC_SERVER 0
  S" {B87BEB7B-8D29-423f-AE4D-6582C10175AC}" >UNICODE String>CLSID THROW \ CLSID_VideoMixingRenderer
  CoCreateInstance THROW
  pVMR9
;

