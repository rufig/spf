# $Id$
#
# generate platform-specific config file

config.auto.f: config.gen
		./$< > $@

# build with debug info just in case
config.gen: config.c
		gcc -Wall -Werror -O0 -g $< -o$@

clean:
		rm -f config.gen config.auto.f
