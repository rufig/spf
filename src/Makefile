# $Id$
#
# Compile SP-Forth for linux
# The default options can be overridden in ./compile.ini

.POSIX:
.DELETE_ON_ERROR:
.PHONY: clean install

target: install

url_spf4orig:="https://github.com/rufig/spf4-cvs-archive/releases/download/v1.0/spf4orig"

../spf4orig:
	@ { command -v curl >/dev/null && c="curl -L -o" ; } || { command -v wget >/dev/null && c="wget -O" ; } || exit 1;\
	cmd="$$c "$@" ${url_spf4orig}"; echo $$cmd; \
	$$cmd

spf4.o: *.f compiler/*.f posix/*.f compile.ini  ../spf4orig
	make -C posix
	cd .. && echo "Wait a bit while compiling..." && ./spf4orig src/spf.f

spf4: spf4.o forth.ld
	gcc -v 2>&1 | grep -F --silent -- '--enable-default-pie' && gcc_nopie="-no-pie" ; \
	gcc -o $@ $< -Wl,forth.ld -ldl -lpthread -v -m32 -fno-pie $$gcc_nopie

install: spf4
	cp spf4 ..

clean:
	rm -f spf4.o
	make -C posix clean
