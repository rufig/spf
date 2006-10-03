#
# Эти переменные отредактируйте по своим настройкам!
#

export spf4_notitle=D:\WORK\FORTH\spf4\spf4_notitle.exe
export markdown=lua D:\WORK\markdown\markdown.lua --charset windows1251 --inline-style --style
export makensis="C:\Program Files\NSIS\makensis.exe"

export spf_path=spf

#########################################

export srcdir=$(shell cd)

target: dist

nsi: spf.nsi

spf.nsi: spf_cvs.f spf.src.nsi
	$(spf4_notitle) : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED T BYE > spf_cvs.nsi
	$(spf4_notitle) : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED S" SPF.src.nsi" EVAL-FILE TYPE BYE > spf.nsi

docs:
	$(MAKE) -C $(spf_path)\docs\papers

dist: docs nsi spf.nsi
	$(makensis) spf.nsi
