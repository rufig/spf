\ Scripting
REQUIRE DEBUG? ~nn/lib/qdebug.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
REQUIRE { ~nn/lib/locals.f
REQUIRE StartAppWait ~nn/lib/process.f

VECT StartScriptApp

C" GetCurrentThreadId" FIND NIP 0= [IF] WINAPI: GetCurrentThreadId KERNEL32.DLL [THEN]
C" GetTickCount" FIND NIP 0= [IF] WINAPI: GetTickCount KERNEL32.DLL [THEN]

USER-CREATE SCR-EXT 2 CELLS USER-ALLOT
USER-CREATE SCR-FNAME 2 CELLS USER-ALLOT
USER-CREATE SCR-END-TXT 2 CELLS USER-ALLOT
USER SCR-SAV-PRE
USER SCR-BEG
USER SCR-XT

:NONAME ( a u -- ) 0 ROT ROT StartAppWait DROP ;
TO StartScriptApp

: script-exec ( a u a1 u1 --)
    SCR-EXT 2!
    S" %GetCurrentThreadId ABS%_%GetTickCount%.%SCR-EXT 2@%" EVAL-SUBST SCR-FNAME 2!
    SCR-FNAME 2@ R/W CREATE-FILE 0=
    IF >R
       EVAL-SUBST R@ WRITE-FILE THROW
       R> CLOSE-FILE DROP
       S" wscript %SCR-FNAME 2@%" EVAL-SUBST StartScriptApp
       SCR-FNAME 2@ DELETE-FILE THROW
    ELSE
        2DROP
    THEN
;

: vbs-exec ( a u -- )  S" VBS" script-exec ;

: js-exec ( a u -- )   S" JS" script-exec  ;

: (XS")
    R> DUP @ SWAP CELL+ SWAP
    2DUP + 1+ >R ;

: SCR-END (  -- ) HERE SCR-BEG @ - 1 CELLS - SCR-BEG @ ! 0 C, ;

: SCR-PRE
    SOURCE SCR-END-TXT 2@ SEARCH NIP NIP
    SOURCE S" </SCRIPT>" SEARCH NIP NIP OR
    SOURCE S" </script>" SEARCH NIP NIP OR
    IF
       SCR-END
       SCR-SAV-PRE @ TO <PRE>
       SCR-XT @ COMPILE,
    ELSE
       SOURCE HERE SWAP DUP ALLOT CMOVE
       13 C, 10 C,
    THEN
    1 PARSE 2DROP
;
: <script> ( xt a u -- )
    SCR-END-TXT 2! SCR-XT !
    POSTPONE (XS")
    HERE SCR-BEG ! 0 ,
    ['] <PRE> BEHAVIOR SCR-SAV-PRE !
    ['] SCR-PRE TO <PRE>
;

: <VBScript> ['] vbs-exec S" </VBScript>" <script> ; IMMEDIATE

: <JScript>  ['] js-exec  S" </JScript>" <script>  ; IMMEDIATE

\EOF

: TEST
<VBScript>
Function ShowFolderList(folderspec)
  Dim fso, f, f1, fc, s
  Set fso = CreateObject("Scripting.FileSystemObject")
  Set f = fso.GetFolder(folderspec)
  Set fc = f.SubFolders
  For Each f1 in fc
    s = s & f1.name
    s = s &  chr(13) & chr(10)
  Next
  ShowFolderList = s
End Function

Function ShowFileList(folderspec)
  Dim fso, f, f1, fc, s
  Set fso = CreateObject("Scripting.FileSystemObject")
  Set f = fso.GetFolder(folderspec)
  Set fc = f.Files
  For Each f1 in fc
    s = s & f1.name
    s = s &  chr(13) & chr(10)
  Next
  ShowFileList = s
End Function


MsgBox ScriptEngine & " V " & ScriptEngineMajorVersion & "." & ScriptEngineMinorVersion & "." & ScriptEngineBuildVersion
MsgBox ShowFolderList(".")
MsgBox ShowFileList(".")
</VBScript>
;

TEST