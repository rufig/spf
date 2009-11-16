REQUIRE EnumConnectionPoints ~ac/lib/win/com/events.f

IID_IUnknown
Interface: IID_IGraphBuilder {56a868a9-0ad4-11ce-b03a-0020af0ba770}
        
  Method: ::AddFilter ( 
            IGraphBuilder * This,
            /* [in] */ IBaseFilter *pFilter,
            /* [string][in] */ LPCWSTR pName)
        
  Method: ::RemoveFilter ( 
            IGraphBuilder * This,
            /* [in] */ IBaseFilter *pFilter)
        
  Method: ::EnumFilters ( 
            IGraphBuilder * This,
            /* [out] */ IEnumFilters **ppEnum)
        
  Method: ::FindFilterByName ( 
            IGraphBuilder * This,
            /* [string][in] */ LPCWSTR pName,
            /* [out] */ IBaseFilter **ppFilter)
        
  Method: ::ConnectDirect ( 
            IGraphBuilder * This,
            /* [in] */ IPin *ppinOut,
            /* [in] */ IPin *ppinIn,
            /* [unique][in] */ const AM_MEDIA_TYPE *pmt)
        
  Method: ::Reconnect ( 
            IGraphBuilder * This,
            /* [in] */ IPin *ppin)
        
  Method: ::Disconnect ( 
            IGraphBuilder * This,
            /* [in] */ IPin *ppin)
        
  Method: ::SetDefaultSyncSource ( 
            IGraphBuilder * This)
        
  Method: ::Connect ( 
            IGraphBuilder * This,
            /* [in] */ IPin *ppinOut,
            /* [in] */ IPin *ppinIn)
        
  Method: ::Render ( 
            IGraphBuilder * This,
            /* [in] */ IPin *ppinOut)
        
  Method: ::RenderFile_gb ( 
            IGraphBuilder * This,
            /* [in] */ LPCWSTR lpcwstrFile,
            /* [unique][in] */ LPCWSTR lpcwstrPlayList)
        
  Method: ::AddSourceFilter_gb ( 
            IGraphBuilder * This,
            /* [in] */ LPCWSTR lpcwstrFileName,
            /* [unique][in] */ LPCWSTR lpcwstrFilterName,
            /* [out] */ IBaseFilter **ppFilter)
        
  Method: ::SetLogFile ( 
            IGraphBuilder * This,
            /* [in] */ DWORD_PTR hFile)
        
  Method: ::Abort ( 
            IGraphBuilder * This)
        
  Method: ::ShouldOperationContinue ( 
            IGraphBuilder * This)
        
Interface;


IID_IDispatch
Interface: IID_IMediaControl {56a868b1-0ad4-11ce-b03a-0020af0ba770}
  Method: ::Run ( void)
  Method: ::Pause ( void)
  Method: ::Stop_mc ( void)
  Method: ::GetState ( 
            /* [in] */ LONG msTimeout,
            /* [out] */ OAFilterState *pfs)
  Method: ::RenderFile ( 
            /* [in] */ BSTR strFilename)
  Method: ::AddSourceFilter ( 
            /* [in] */ BSTR strFilename,
            /* [out] */ IDispatch **ppUnk)
  Method: ::get_FilterCollection ( 
            /* [retval][out] */ IDispatch **ppUnk)
  Method: ::get_RegFilterCollection ( 
            /* [retval][out] */ IDispatch **ppUnk)
  Method: ::StopWhenReady ( void)
Interface;

IID_IDispatch
Interface: IID_IMediaEvent {56a868b6-0ad4-11ce-b03a-0020af0ba770}
  Method: ::GetEventHandle ( 
            /* [out] */ OAEVENT *hEvent)

  Method: ::GetEvent ( 
            /* [out] */ long *lEventCode,
            /* [out] */ LONG_PTR *lParam1,
            /* [out] */ LONG_PTR *lParam2,
            /* [in] */ long msTimeout)

  Method: ::WaitForCompletion ( 
            /* [in] */ long msTimeout,
            /* [out] */ long *pEvCode)
        
  Method: ::CancelDefaultHandling ( 
            /* [in] */ long lEvCode)
        
  Method: ::RestoreDefaultHandling ( 
            /* [in] */ long lEvCode)
        
  Method: ::FreeEventParams ( 
            /* [in] */ long lEvCode,
            /* [in] */ LONG_PTR lParam1,
            /* [in] */ LONG_PTR lParam2)
Interface;

: DsInit { \ pGraph -- pGraph }
  ComInit THROW
  \ S" Filter Graph" CreateObject
  ^ pGraph IID_IGraphBuilder CLSCTX_INPROC_SERVER 0
  S" {e436ebb3-524f-11ce-9f53-0020af0ba770}" >UNICODE String>CLSID THROW
  CoCreateInstance THROW
  pGraph
;
: PlayFile { a u \ pGraph pControl pEvent -- }
  DsInit -> pGraph
  ^ pControl IID_IMediaControl pGraph ::QueryInterface THROW
  ^ pEvent IID_IMediaEvent pGraph ::QueryInterface THROW
  0 a u >BSTR pGraph ::RenderFile_gb THROW
  pControl ::Run .
  PAD -1 pEvent ::WaitForCompletion THROW
  pControl ::Release DROP
  pEvent ::Release DROP
  pGraph ::Release DROP
  ComExit
;
\ S" D:\video\test.avi" PlayFile
