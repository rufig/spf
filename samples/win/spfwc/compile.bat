if exist spf4wc.fres goto fres_done
if exist spf4wc.res goto res_done
REM �������������� ���� ��������. ������� ����� ����������� ���������� RC ������.
REM �������� rc.exe �� �������� MS Visual Studio, brcc32.exe �� �������� Borland ���������, etc
windres spf4wc.rc spf4wc.res
:res_done
if exist ..\..\..\devel\~yz\prog\fres\fres.exe goto fres_exe_done
cd ..\..\..\devel\~yz\prog\fres
..\..\..\..\spf4.exe fres.f
cd ..\..\..\..\samples\win\spfwc
:fres_exe_done
if exist spf4wc.fres goto fres_done rem this comment is to avoid the error "The system cannot find the batch label specified"
..\..\..\devel\~yz\prog\fres\fres.exe spf4wc.res
:fres_done
..\..\..\spf4.exe spf4wc.f

@if exist spf4wc.exe move /Y spf4wc.exe ..\..\..\spf4wc.exe && echo (!) NB: spf4wc.exe is placed near spf4.exe & pause
