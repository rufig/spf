# $Id$
#
# Makefile для сборки дистрибутивов spf
# см. readme.txt
#
# make - собрать полный дистр
# make devel-snap-rar - собрать снапшот devel в архив rar (на windows)
# make devel-snap-gz - собрать снапшот devel в архив gz (на nix)
# make clean - удалить промежуточные файлы
# make cleanall - удалить все результирующие файлы

#########################################

#
# Эти переменные отредактируйте по своим настройкам!
#

makensis := "C:\Program Files\NSIS\makensis.exe"
winrar := "C:\Program Files\WinRAR\rar.exe"
7z := "C:\Program Files\7-Zip\7z.exe"

#########################################

spf_path := ..\..
run_spf := $(spf_path)\spf4.exe

#########################################

datestamp = $(shell $(run_spf) util.f DATE_RAW TYPE BYE)
devel-snapshot = spf-devel-$(datestamp)
spf_script = $(run_spf) : SPF-VER-MAJOR VERSION 100000 / ; : SPF-VER-MINOR VERSION 1000 / 100 MOD ; : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED

spf_ver_major = $(shell $(spf_script) SPF-VER-MAJOR NUM_RAW TYPE BYE)
spf_ver_minor = $(shell $(spf_script) SPF-VER-MINOR NUM_RAW TYPE BYE)
dist-exe = spf$(spf_ver_major)-$(spf_ver_minor)-setup.exe
dist-rar = spf$(spf_ver_major)-$(spf_ver_minor).rar
dist-7z = spf$(spf_ver_major)-$(spf_ver_minor).7z

#########################################

default: $(dist-exe) $(dist-7z)

devel-snap-rar: $(devel-snapshot).rar
devel-snap-gz: $(devel-snapshot).tar.gz

.PHONY: default docs clean cleanall

spf_cvs.nsi: $(run_spf) spf_cvs.f
	$(spf_script) NSI-LIST > $@ BYE

spf.nsi: $(run_spf) spf.src.nsi spf_cvs.nsi spf_cvs.f
	$(spf_script) S" spf.src.nsi" EVAL-FILE TYPE BYE > $@

spf.lst: $(run_spf) spf_cvs.f
	$(spf_script) RAR-LIST > $@ BYE

spf.7z.lst: $(run_spf) spf_cvs.f
	$(spf_script) 7Z-LIST > $@ BYE

docs:
	$(MAKE) -C $(spf_path)/docs

$(dist-exe): docs $(run_spf) spf.nsi
	$(makensis) spf.nsi

$(dist-7z): docs $(run_spf) spf.7z.lst
	cd ..\\.. && $(7z) a tools/nsis/$@ @tools/nsis/spf.7z.lst

$(dist-rar): docs $(run_spf) spf.lst
	$(winrar) a -m5 -s $(dist-rar) @spf.lst

$(devel-snapshot).rar:
	$(winrar) a -x*\CVS -x*\CVS\* -m5 -s $@ ..\..\devel

$(devel-snapshot).7z:
	$(7z) a -x!*\CVS -x!*\CVS\* $@ ..\..\devel

$(devel-snapshot).tar.gz:
	gzip -cvzf $@ --exclude=CVS ../../devel

clean:
	$(MAKE) -C $(spf_path)/docs clean
	-del spf.nsi spf.lst spf.7z.lst spf_cvs.nsi

cleanall: clean
	-del $(dist-exe) $(dist-rar)
