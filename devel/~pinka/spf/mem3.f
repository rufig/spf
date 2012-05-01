\ 2004,2010,2012  :)

: WITHIN-HEAP-GLOBAL-CATCH ( i*x  xt -- j*x ior )
  THREAD-HEAP @ >R
    GetProcessHeap THREAD-HEAP !
    CATCH
  R> THREAD-HEAP !
;

: WITHIN-HEAP-GLOBAL ( i*x  xt -- j*x  )
  WITHIN-HEAP-GLOBAL-CATCH THROW
;


\ see also: ~pinka/samples/2005/ext/mem.f
