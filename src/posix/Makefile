# $Id$
#
# generate platform-specific config file

config.auto.f: config.gen
		./$< > $@

config.gen: config.c
		gcc $< -o$@

clean:
		rm -f config.gen config.auto.f
