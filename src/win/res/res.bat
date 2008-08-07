REM $Id$
REM Create spf.fres
REM You can use any resource compiler instead of rc

rc spf.rc
..\..\..\spf4 ~yz/prog/fres/fres.f
fres spf.res