
if exist spf4wc.res goto res_done
REM Скомпилировать файл ресурсов. Подойдёт любой стандартный компилятор RC файлов.
REM Например rc.exe из поставки MS Visual Studio, brcc32.exe из поставки Borland продуктов, etc
windres spf4wc.rc spf4wc.res
:res_done
if exist ..\..\..\devel\~yz\prog\fres\fres.exe goto fres_exe_done
cd ..\..\..\devel\~yz\prog\fres
..\..\..\..\spf4.exe fres.f
cd ..\..\..\..\samples\win\spfwc
:fres_exe_done
if exist spf4wc.fres goto fres_done
..\..\..\devel\~yz\prog\fres\fres.exe spf4wc.res
:fres_done
..\..\..\spf4.exe spf4wc.f
