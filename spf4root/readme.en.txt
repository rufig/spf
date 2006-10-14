
SP-Forth for Windows
====================


ABOUT
=====

  SP-FORTH is a reliable and comfortable forth system producing optimized native
code for the Intel x86 processors. Runs on MS Windows 9x, NT (there are also
ports to Linux, Kolibri OS).

SP-Forth is free software, you can redistribute and/or modify it under the
terms of the GNU General Public License. See docs\license\gpl.en.txt for
details.

SP-Forth is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.


INSTALLATION
============

  SP-Forth for Windows is distributed as the RAR archive or the self-installing
executable.
  If you've got an archive - unpack it to the desired folder. It is ready to
use now. If you want to associate *.f and *.spf files with spf4.exe - run
docs\install\install.bat script, which will launch a GUI program for tweaking the
registry settings. Alternatively you can edit \docs\install\spf_path_install.reg
manually (specify the correct path to your spf4.exe) and run it. Now you can
write your code, save it as the *.f file and execute it by simply
doubleclicking the source file.
  If you have an executable package - just run it. The wizard will guide you
through the setup process.
  See the docs\whatsnew.eng.txt file for the short overview of recent changes.

  Directories:

 \devel   - additional contributed libraries and examples
 \docs    - documentation
 \lib     - standard libraries, common ANS and non ANS extensions like float.f, locals.f ...
 \samples - debugged GUI and console mode samples.
 \src     - full sources with comments and compile.bat file.

  Files in the root directory:

 envir.spf        - this file specifies the spf environment queried with the ENVIRONMENT? word
 help.fhlp        - default include for the lib/ext/help.f extension
 jpf375c.exe      - an older version of SPF used to build itself
 spf.err          - this file is used by SPF to display the error (THROW) description, if
                    it is absent you'll end up only with an error code if exception occurs
 spf.eng.err      - the same file in English
 spf4.exe         - SPF itself ;)
 spf.ini          - This file can be customized and copied to spf4.ini which will be
                    included by SPF at startup


DOCUMENTATION
=============

  See the \docs\papers folder. The majority of the documentation is in Russian
now. If you need an English version, contact us, maybe the translation will be
done. SPF extension (lib/ext/help.f) adds help support to the interpreter. It
uses fhlp files, which can be converted to HTML for standalone use. If you have
more questions - ask them at spf-dev mailing list.


DEVELOPMENT
===========

The latest version can be downloaded from :

  https://spf.sourceforge.net

  You can obtain the latest sources from CVS. The repository for the anonymous
  read-only access via pserver is ":pserver:anonymous@spf.cvs.sourceforge.net:/cvsroot/spf"

The first place to contact the developers is the spf-dev mailing list :

  https://lists.sourceforge.net/lists/listinfo/spf-dev

A bugtracker is maintained at

  http://activekitten.com/trac/spf/

  You can report found bugs there. Please provide a comprehensive description
  of the bug behaviour and ways to reproduce. Any errors or omissions in the
  documentation can also be reported to the same address.

Related projects (highly recommended) :

  http://www.delosoft.com    - Forth systems for pocket computers
  http://forth-script.sf.net - SP-Forth as CGI
  http://acweb.sf.net        - web server for Win32
  http://acfreeproxy.sf.net  - http proxy server
  http://acftp.sf.net        - ftp server
  http://nncron.ru           - scriptable unix-like cron scheduler

Russian Forth Interest Group :

  http://www.forth.org.ru


AUTHORS
=======

Russian Forth Interest Group with the help of many contributors.
Started by Andrey Cherezov in 1992

----
Last updated : $Date$
