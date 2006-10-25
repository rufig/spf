#
# Эти переменные отредактируйте по своим настройкам!
#

spf4_notitle=D:\WORK\FORTH\spf4\spf4_notitle.exe
#markdown=python D:\WORK\markdown\markdown-1-5.py
makensis="C:\Program Files\NSIS\makensis.exe"

spf_path=..\..
spf_tc=jpf375c.exe

#########################################

host=win
delete=del

ifneq ($(host),win)
delete=rm -f
endif

export srcdir=$(shell cd)

target: dist

spf.nsi: spf_cvs.f spf.src.nsi
	$(spf4_notitle) : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED T > spf_cvs.nsi BYE
	$(spf4_notitle) : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED S" SPF.src.nsi" EVAL-FILE TYPE BYE > spf.nsi

docs:
	$(MAKE) -C $(spf_path)/docs

$(spf_path)\spf4.exe: $(spf_path)\jpf375c.exe $(spf_path)\src\version.spf
	copy $(spf_path)\spf4root\* $(spf_path)
	cd $(spf_path) && $(spf_tc) src\spf.f

dist: docs $(spf_path)\spf4.exe spf.nsi
	$(makensis) spf.nsi

clean:
	$(MAKE) -C $(spf_path)/docs clean
	$(delete) spf.nsi
	$(delete) spf_cvs.nsi
	$(delete) spf-*-setup.exe
