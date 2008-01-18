
SP-Forth for Windows
====================

<title>SP-Forth for Windows</title>

<!-- Translation in sync with readme.ru.md r1.6 -->

ABOUT
-----

SP-Forth is a reliable and comfortable forth system producing optimized native
code for the Intel x86 processors. It runs on MS Windows 9x, NT
(Linux and Kolibri OS ports exist).

SP-Forth is free software, see COPYRIGHT section for more information.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.


INSTALLATION
------------

SP-Forth (SPF) for Windows is distributed as an archive or the self-installing
executable.

If you have an executable package - just run it. The wizard will guide you
through the setup process.

If you've got an archive - unpack it to the desired folder. It is ready to
use now. If you want to associate `*.f` and `*.spf` files with `spf4.exe` - run
`docs/install/install.bat` script, which will launch a GUI program for tweaking the
registry settings. Alternatively you can edit `docs/install/spf_path_install.reg`
manually (specify the correct path to your spf4.exe) and run it. Now you can
write your code, save it as the *.f file and execute it by simply
doubleclicking the source file.

See the [docs/whatsnew.en.txt](whatsnew.en.txt) file for the short overview of recent changes.

Directories:

* `/devel`   - additional contributed libraries and examples
* `/docs`    - documentation
* `/lib`     - standard libraries, ANS and non-ANS extensions like `float.f`, `locals.f` ...
* `/samples` - debugged GUI and console mode samples.
* `/src`     - full sources with comments and compile.bat file.

Files in the root directory:

* `help.fhlp`        - default include for the `lib/ext/help.f` extension
* `jpf375c.exe`      - an older version of SPF used to build itself
* `spf4.exe`         - SPF itself
* `spf4.ini`         - This file is automatically included by SPF at startup


DOCUMENTATION
-------------

See the `/docs` directory. The majority of the documentation is in Russian for
now. If you need an English version, contact us, the translation will be done.

1.  [SPF specifics](intro.en.html)

    If you are familiar with Forth, but not with SPF.

2.  [Short overview of libraries](devel.en.html)

    Additional libraries in SPF distribution


SPF extension (`lib/ext/help.f`) adds help support to the interpreter with the word `HELP`.

If you have more questions - ask them at spf-dev mailing list.


DEVELOPMENT
-----------

*   The latest version can be downloaded from SF.net :

    <http://spf.sourceforge.net>

    You can obtain the latest sources from CVS. The repository for the anonymous
    read-only access is
    `:pserver:anonymous@spf.cvs.sourceforge.net:/cvsroot/spf`

*   The first place to contact the developers is the spf-dev mailing list :

    <http://lists.sourceforge.net/lists/listinfo/spf-dev>

    Mailing list also is mirrored on: [SP-Forth - DEV (rus)](http://www.nabble.com/SP-Forth---DEV-(rus%29-f26012.html)
    (though title has 'rus' in it, you may write english)

*   Bugtracker (feature requests and bugreports welcome)

    <http://sourceforge.net/tracker/?group_id=17919>

    Please provide a comprehensive description of the bug behaviour and ways 
    to reproduce. Dont hesitate to report errors or omissions in the 
    documentation too. 

    Notifications on bugtracker activity go to spf-tickets mailing list

    <http://lists.sourceforge.net/lists/listinfo/spf-tickets>

*   Related projects (highly recommended) :

    <http://www.eserv.ru>        - HTTP/FTP/SMTP/POP3/IMAP server and proxy for Win32

    <http://www.delosoft.com>    - Forth systems for pocket computers

    <http://nncron.ru>           - scriptable unix-like cron scheduler for Windows

    <http://forth-script.sf.net> - SP-Forth as CGI

    <http://acweb.sf.net>        - web server for Win32

    <http://acfreeproxy.sf.net>  - http proxy server

    <http://acftp.sf.net>        - ftp server

*    Russian Forth Interest Group :

     <http://www.forth.org.ru>
     

COPYRIGHT
---------

You can modify and/or redistribute the core SP-Forth system (i.e. all files in `src`) 
under the terms of GNU General Public License. See [docs/license/gpl.en.txt](license/gpl.en.txt) 
for details. All other files, including contrubuted code in `devel`, are by default 
(if not stated anything else) licensed under GNU LGPL. 

Shortly speaking it means that :

*    You are prohibited to modify core SPF system and distribute the result of this modification without providing full sources.

*    You are allowed to compile and distribute closed-source projects with original SPF.

*    You are allowed to use unmodified code from `devel` in combination with your own code in closed-source projects.

*    You are obliged to contribute back your modifications to original code from `devel` if you modified and used it in closed-source project, 
     but you may leave your own code closed.


AUTHORS
-------

Russian Forth Interest Group with the help of many contributors.

Started by Andrey Cherezov in 1992

----
Last updated : $Date$
