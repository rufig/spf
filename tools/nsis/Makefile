#
# Эти переменные отредактируйте по своим настройкам!
#

export spf4_notitle=D:\WORK\FORTH\spf4\spf4_notitle.exe
export markdown=python D:\WORK\markdown\markdown-1-5.py
export makensis="C:\Program Files\NSIS\makensis.exe"

export spf_path=spf

#########################################

export srcdir=$(shell cd)

target: dist

nsi: spf.nsi

spf.nsi: spf_cvs.f spf.src.nsi
	$(spf4_notitle) : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED T > spf_cvs.nsi BYE
	$(spf4_notitle) : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED S" SPF.src.nsi" EVAL-FILE TYPE BYE > spf.nsi

docs:
	$(MAKE) -C $(spf_path)/docs/papers

dist: docs nsi spf.nsi
	$(makensis) spf.nsi

clean:
	$(MAKE) -C $(spf_path)/docs/papers clean