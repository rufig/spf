# $Id$
#
# generate platform-specific config file

config.auto.f: config.gen
		./$< > $@

config.gen: config.c
		gcc -Wall -Werror -DSPF_SRC $< -o$@ -m32

clean:
		rm -f config.gen config.auto.f
