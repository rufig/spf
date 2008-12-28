# $Id$
#
# Compile SP-Forth for linux
# Need src/compile.ini with correct options

target: install

spf4.o: *.f compiler/*.f posix/*.f compile.ini
	make -C posix
	cd .. && echo "Wait a bit while compiling..." && ./spf4orig src/spf.f

spf4: spf4.o forth.ld
	gcc -o $@ $< -Wl,forth.ld -ldl -lpthread -v

install: spf4
	cp spf4 ..

clean:
	rm -f spf4.o
	make -C posix clean
