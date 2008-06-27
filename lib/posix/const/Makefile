# $Id$

target: linux.const clean

%.auto.f: %.gen
		./$< > $@

consts.gen: consts.c
		gcc -Wall -Werror $< -o$@

linux.const: consts.auto.f compile.f
		spf compile.f

clean:
		rm -f consts.gen consts.auto.f
