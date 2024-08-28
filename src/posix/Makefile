# $Id$
#
# generate platform-specific config file

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.POSIX:
.DELETE_ON_ERROR:

config.auto.f: config.gen
		./$< > $@

config.gen: config.c
		gcc -Wall -Werror -DSPF_SRC $< -o$@ -m32

clean:
		rm -f config.gen config.auto.f
