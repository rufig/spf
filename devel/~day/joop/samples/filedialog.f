REQUIRE OpenDialog ~day\joop\win\filedialogs.f

 \ Sample

FILTER: fTest

  NAME" all files" EXT" *.*"
  NAME" exe files" EXT" *.exe"

;FILTER


OpenDialog :new VALUE tt

: title1
     S" This is just an example. You can leave this field blank"
;

fTest tt :setFilter
title1 tt :setTitle
tt :execute DROP
CR CR
tt :fileName  TYPE
