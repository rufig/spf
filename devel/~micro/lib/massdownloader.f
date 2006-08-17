REQUIRE PushWindow ~micro/autopush/add.f

MODULE: MassDownloader

  : Window ( -- h )
    S" Mass Downloader" DROP S" TApplication" DROP 0 desktop FindWindowExA
  ;

  : ToolBar ( -- h )
    S" Mass Downloader" DROP S" TMainForm" DROP 0 desktop FindWindowExA
    >R 0 S" TToolBar" DROP 0 R> FindWindowExA
  ;



EXPORT
  : Download
    490 20 ToolBar ?DUP IF PushWindow ELSE 2DROP THEN
  ;
  : Stop
    550 20 ToolBar ?DUP IF PushWindow ELSE 2DROP THEN
  ;

;MODULE
