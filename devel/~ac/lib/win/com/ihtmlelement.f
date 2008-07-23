\ ”правление встроенным браузером. ѕримеры см. в ~ac/lib/win/window/browser.f

REQUIRE CLSID,  ~ac/lib/win/com/com.f

IID_IDispatch
Interface: IID_IHTMLElementCollection {3050F21F-98B5-11CF-BB82-00AA00BDCE0B}
  Method: ::colToString ( THIS_ BSTR*) \ им€ изменено, чтобы не пересекатьс€ с более полезным IHTMLElement::toString
  Method: ::put_length ( THIS_ long)
  Method: ::get_length ( THIS_ long*)
  Method: ::get__newEnum ( THIS_ IUnknown**)
  Method: ::item ( THIS_ VARIANT,VARIANT,IDispatch**)
                 \ сами варианты на стеке (по 4 €чейки на каждый)
  Method: ::tags ( THIS_ VARIANT,IDispatch**)
Interface;


IID_IDispatch
Interface: IID_IHTMLElement {3050f1ff-98b5-11cf-bb82-00aa00bdce0b}
  Method: ::setAttribute (  
            /* [in] */ __RPC__in BSTR strAttributeName,
            /* [in] */ VARIANT AttributeValue,
            /* [in][defaultvalue] */ LONG lFlags = 1)
        
  Method: ::getAttribute (  
            /* [in] */ __RPC__in BSTR strAttributeName,
            /* [in][defaultvalue] */ LONG lFlags,
            /* [out][retval] */ __RPC__out VARIANT *AttributeValue)
        
  Method: ::removeAttribute (  
            /* [in] */ __RPC__in BSTR strAttributeName,
            /* [in][defaultvalue] */ LONG lFlags,
            /* [out][retval] */ __RPC__out VARIANT_BOOL *pfSuccess)
        
  Method: ::put_className (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_className (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::put_id (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_id (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::get_tagName (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::get_parentElement (  
            /* [out][retval] */ __RPC__deref_out_opt IHTMLElement **p)
        
  Method: ::get_style (  
            /* [out][retval] */ __RPC__deref_out_opt IHTMLStyle **p)
        
  Method: ::put_onhelp (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onhelp (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onclick (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onclick (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_ondblclick (  
            /* [in] */ VARIANT v)
        
  Method: ::get_ondblclick (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onkeydown (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onkeydown (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onkeyup (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onkeyup (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onkeypress (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onkeypress (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onmouseout (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onmouseout (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onmouseover (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onmouseover (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onmousemove (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onmousemove (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onmousedown (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onmousedown (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onmouseup (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onmouseup (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::get_document (  
            /* [out][retval] */ __RPC__deref_out_opt IDispatch **p)
        
  Method: ::put_title (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_title (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::put_language (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_language (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::put_onselectstart (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onselectstart (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::scrollIntoView (  
            /* [in][optional] */ VARIANT varargStart)
        
  Method: ::contains (  
            /* [in] */ __RPC__in_opt IHTMLElement *pChild,
            /* [out][retval] */ __RPC__out VARIANT_BOOL *pfResult)
        
  Method: ::get_sourceIndex (  
            /* [out][retval] */ __RPC__out long *p)
        
  Method: ::get_recordNumber (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_lang (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_lang (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::get_offsetLeft (  
            /* [out][retval] */ __RPC__out long *p)
        
  Method: ::get_offsetTop (  
            /* [out][retval] */ __RPC__out long *p)
        
  Method: ::get_offsetWidth (  
            /* [out][retval] */ __RPC__out long *p)
        
  Method: ::get_offsetHeight (  
            /* [out][retval] */ __RPC__out long *p)
        
  Method: ::get_offsetParent (  
            /* [out][retval] */ __RPC__deref_out_opt IHTMLElement **p)
        
  Method: ::put_innerHTML (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_innerHTML (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::put_innerText (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_innerText (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::put_outerHTML (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_outerHTML (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::put_outerText (  
            /* [in] */ __RPC__in BSTR v)
        
  Method: ::get_outerText (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *p)
        
  Method: ::insertAdjacentHTML (  
            /* [in] */ __RPC__in BSTR where,
            /* [in] */ __RPC__in BSTR html)
        
  Method: ::insertAdjacentText (  
            /* [in] */ __RPC__in BSTR where,
            /* [in] */ __RPC__in BSTR text)
        
  Method: ::get_parentTextEdit (  
            /* [out][retval] */ __RPC__deref_out_opt IHTMLElement **p)
        
  Method: ::get_isTextEdit (  
            /* [out][retval] */ __RPC__out VARIANT_BOOL *p)
        
  Method: ::click (  void)
        
  Method: ::get_filters (  
            /* [out][retval] */ __RPC__deref_out_opt IHTMLFiltersCollection **p)
        
  Method: ::put_ondragstart (  
            /* [in] */ VARIANT v)
        
  Method: ::get_ondragstart (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::toString (  
            /* [out][retval] */ __RPC__deref_out_opt BSTR *String)
        
  Method: ::put_onbeforeupdate (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onbeforeupdate (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onafterupdate (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onafterupdate (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onerrorupdate (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onerrorupdate (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onrowexit (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onrowexit (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onrowenter (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onrowenter (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_ondatasetchanged (  
            /* [in] */ VARIANT v)
        
  Method: ::get_ondatasetchanged (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_ondataavailable (  
            /* [in] */ VARIANT v)
        
  Method: ::get_ondataavailable (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_ondatasetcomplete (  
            /* [in] */ VARIANT v)
        
  Method: ::get_ondatasetcomplete (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::put_onfilterchange (  
            /* [in] */ VARIANT v)
        
  Method: ::get_onfilterchange (  
            /* [out][retval] */ __RPC__out VARIANT *p)
        
  Method: ::get_children (  
            /* [out][retval] */ __RPC__deref_out_opt IDispatch **p)
        
  Method: ::get_all (  
            /* [out][retval] */ __RPC__deref_out_opt IDispatch **p)
Interface;

IID_IDispatch
Interface: IID_IXMLDOMNodeList {2933BF82-7B36-11d2-B20E-00C04F983E60}
  Method: ::get_item ( 
            IXMLDOMNodeList * This,
            /* [in] */ long index,
            /* [retval][out] */ IXMLDOMNode **listItem)
        
  Method: ::get_lengthX ( 
            IXMLDOMNodeList * This,
            /* [retval][out] */ long *listLength)
        
  Method: ::nextNode ( 
            IXMLDOMNodeList * This,
            /* [retval][out] */ IXMLDOMNode **nextItem)
        
  Method: ::reset (  IXMLDOMNodeList * This)
        
  Method: ::get__newEnumX ( 
            IXMLDOMNodeList * This,
            /* [out][retval] */ IUnknown **ppUnk)
Interface;

IID_IDispatch
Interface: IID_IHTMLDOMChildrenCollection {3050f5ab-98b5-11cf-bb82-00aa00bdce0b}
  Method: ::get_lengthC (            IHTMLDOMChildrenCollection * This,
            /* [out][retval] */ __RPC__out long *p)
        
  Method: ::get__newEnumC ( 
            IHTMLDOMChildrenCollection * This,
            /* [out][retval] */ __RPC__deref_out_opt IUnknown **p)
        
  Method: ::itemC ( 
            IHTMLDOMChildrenCollection * This,
            /* [in] */ long index,
            /* [out][retval] */ __RPC__deref_out_opt IDispatch **ppItem)
Interface;
