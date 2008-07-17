\ ”правление встроенным браузером. ѕримеры см. в ~ac/lib/win/window/browser.f

REQUIRE CLSID,  ~ac/lib/win/com/com.f

IID_IDispatch
Interface: IID_IHTMLElementCollection {3050F21F-98B5-11CF-BB82-00AA00BDCE0B}
  Method: ::toString ( THIS_ BSTR*)
  Method: ::put_length ( THIS_ long)
  Method: ::get_length ( THIS_ long*)
  Method: ::get__newEnum ( THIS_ IUnknown**)
  Method: ::item ( THIS_ VARIANT,VARIANT,IDispatch**)
                 \ сами варианты на стеке (по 4 €чейки на каждый)
  Method: ::tags ( THIS_ VARIANT,IDispatch**)
Interface;
