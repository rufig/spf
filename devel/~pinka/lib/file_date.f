\ 20.Jul.2002 Sat 14:02
\ $Id$

REQUIRE FILE-FILETIME-A ~pinka/lib/win/file-info-time.f

: FILE-CTIME ( h -- ftime-lo ftime-hi ior )
  FILE-FILETIME-C
;
: FILE-WTIME ( h -- ftime-lo ftime-hi ior )
  FILE-FILETIME-W
;
: FILE-ATIME ( h -- ftime-lo ftime-hi ior )
  FILE-FILETIME-A
;

\ -- for the backward compatibility
