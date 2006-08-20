
                        SP-Forth for Windows readme


ABOUT

  SP-FORTH is a reliable and comfortable forth system producing optimized native
code for the Intel x86 processors. Runs on MS Windows 9x, NT (there are also
ports to Linux, Kolibri OS). SP-Forth is distributed under the terms of the GNU
General Public License. Read GPL.html for details.


INSTALLATION

  SP-Forth for Windows is distributed as the RAR archive or the self-installing
executable.
  If you've got an archive - unpack it to the desired folder. It is ready to
use now. If you want to associate *.f and *.spf files with spf4.exe - run
manage.bat script, which will launch a GUI program for tweaking the
registry settings. Alternatively you can edit \docs\install\spf_path_install.reg
manually (specify the correct path to your spf4.exe) and run it. Now you can
write your code, save it as the *.f file and execute it by simply
doubleclicking the source file.
  If you have an SFX package - just run it. The wizard will guide you through
the setup process.
  See the whatsnew.txt file for the version history.

  Directories:

 \devel   - additional libraries and examples
 \docs    - documentation
 \lib     - standard libraries, common ANS and non ANS extensions like float.f, locals.f ...
 \samples - debugged GUI and console mode samples.
 \src     - full sources with comments and compile.bat file.

  Files in the root directory:

 del_cvs.cmd      - the batch script to delete the CVS-specific files from the
                    distribution. Dont use it unless you know what you're doing.
 envir.spf        - this file specifies the spf environment queried with the ENVIRONMENT? word
 GPL.html         - license file
 help.fhlp        - default include for the lib/ext/help.f extension
 manage.bat       - batch script to set/modify/erase SPF registry settings
 jpf375c.exe      - an older version of SPF used to build itself
 spf.err          - this file is used by SPF to display the error (THROW) description, if
                    it is absent you'll end up only with an error code if exception occurs
 spf.eng.err      - the same file in English
 spf4.exe         - SPF itself ;)
 spf4.ini         - this file is included as a forth code at SPF startup. Place your
                    custom initialization here.
 whatsnew.txt     - version history
 whatsnew.eng.txt - same file in English


DOCUMENTATION

  See the \docs\papers folder. The majority of the documentation is in Russian
now. If you need an English version, contact us, maybe the translation will be
done. SPF extension (lib/ext/help.f) adds help support to the interpreter. It
uses fhlp files, which can be converted to HTML for standalone use with
manage.bat. If you have more questions - ask the at spf-dev mailing list.


DEVELOPMENT

  The latest version can be downloaded from :

    http://sourceforge.net/projects/spf/

    There you can also subscribe to the mailing list spf-dev, obtain latest
    sources from CVS, post a bugreport.

  SPF projects (strongly recommended) :

    http://www.delosoft.com
    http://forth-script.sf.net
    http://acweb.sf.net
    http://acfreeproxy.sf.net
    http://acftp.sf.net

  Russian Forth Interest Group :

    http://www.forth.org.ru

--
Last updated : 20.Aug.2006