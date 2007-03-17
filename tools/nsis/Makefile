#
# Ёти переменные отредактируйте по своим настройкам!
#

spf4_notitle=D:\WORK\FORTH\spf4\spf4_notitle.exe
makensis="C:\Program Files\NSIS\makensis.exe"
winrar="C:\Program Files\WinRAR\rar.exe"

spf_path=..\..
spf_tc=jpf375c.exe

#########################################

spf_ver_major=4
spf_ver_minor=18

#########################################

host=win
delete=del

ifneq ($(host),win)
delete=rm -f
endif

exe=spf-$(spf_ver_major)$(spf_ver_minor)-setup.exe
arch=spf-$(spf_ver_major)$(spf_ver_minor).rar
spf_script=$(spf4_notitle) : SPF-VER-MAJOR S" $(spf_ver_major)" ; : SPF-VER-MINOR S" $(spf_ver_minor)" ; : SPF-PATH S" $(spf_path)" ; S" spf_cvs.f" INCLUDED

all: $(exe) $(arch)

.PHONY: all docs clean cleanall

spf_cvs.nsi: spf_cvs.f
	$(spf_script) NSI-LIST > $@ BYE

spf.nsi: spf.src.nsi spf_cvs.nsi spf_cvs.f
	$(spf_script) S" spf.src.nsi" EVAL-FILE TYPE BYE > $@

spf.lst: spf_cvs.f
	$(spf_script) RAR-LIST > $@ BYE

docs:
	$(MAKE) -C $(spf_path)/docs

$(spf_path)\spf4.exe: $(spf_path)\jpf375c.exe $(spf_path)\src\VERSION.SPF
	copy $(spf_path)\spf4root\* $(spf_path)
	echo $(spf_ver_major)$(spf_ver_minor)000 > $(spf_path)\src\VERSION.SPF
	cd $(spf_path) && $(spf_tc) src\spf.f
#	echo $(spf_ver_major)$(spf_ver_minor)000 > $(spf_path)\src\VERSION.SPF

# просто макрос дл€ ручного тестировани€
#spfexe:
#	$(MAKE) $(spf_path)\spf4.exe

$(exe): docs $(spf_path)\spf4.exe spf.nsi
	$(makensis) spf.nsi

$(arch): docs $(spf_path)\spf4.exe spf.lst
	$(winrar) a -m5 -s $(arch) @spf.lst

clean:
	$(MAKE) -C $(spf_path)/docs clean
	$(delete) spf.nsi spf.lst spf_cvs.nsi

cleanall: clean
	$(delete) $(exe) $(arch)
