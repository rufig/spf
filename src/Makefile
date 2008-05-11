# $Id$

target: install

spf4.o: *.f compiler/*.f posix/*.f
	make -C posix
	cd .. && echo "Wait a bit while compiling..." && ./spf4orig src/spf.f

spf4: spf4.o
	cc $< -ldl -lpthread -D_REENTRANT -Xlinker -Tdefault.ld -Xlinker -Tforth.ld -v

install: spf4
	cp spf4 ..

clean:
	rm spf4.o
	make -C posix clean
