# $Id$
#
# Build spf-linux distribution (beta)
# copy this Makefile somewhere, tweak paths and make

################################

spf_cvs=/home/ygrek/work/forth/spf-pub
spf4orig=/home/ygrek/work/forth/spf/spf4orig
out=spf4-19-linux-beta1

################################

target: pack

$(out):
	mkdir -p $@

dirs: $(out)
	cp -R $(spf_cvs)/src $(out)/src
	cp -R $(spf_cvs)/lib $(out)/lib
	cp $(spf4orig) $(out)/spf4orig
	find $(out) -wholename '*/CVS*' -delete

$(out)/spf.compile.ini:
	echo "TRUE TO UNIX-ENVIRONMENT" > $(out)/spf.compile.ini
	echo "TRUE TO TARGET-POSIX" >> $(out)/spf.compile.ini
	echo "FALSE TO USE-OPTIMIZER" >> $(out)/spf.compile.ini
	echo "FALSE TO BUILD-OPTIMIZER" >> $(out)/spf.compile.ini

$(out)/spf4: dirs $(out)/spf.compile.ini
	cd $(out)/src && ./compile

pack: $(out)/spf4
	tar -cvzf $(out).tar.gz $(out)

clean:
	rm -rf $(out)
