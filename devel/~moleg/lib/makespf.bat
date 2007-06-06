@rem 31-05-2007 ~mOleg
@rem Copyright [C] 2007 mOleg mininoleg@yahoo.com
@rem сборка текущей версии СПФ из исходников для CVS

@copy jpf375c.exe ..\..\..\
@CD ..\..\..\src\
@CALL compile.bat
@del jpf375c.exe

