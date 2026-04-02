# $Id$
#
# generate platform-specific config file

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.POSIX:
.DELETE_ON_ERROR:

# HOSTWRAPPER is an optional wrapper (e.g. "wsl") to run the target binary "config.gen"

ifeq ($(origin CC),default)
  CC := $(HOSTWRAPPER) gcc
endif



config.auto.f: config.gen
		$(HOSTWRAPPER) ./$< > $@

config.gen: config.c
		$(CC) -Wall -Werror -DSPF_SRC $< -o$@ -m32

clean:
		rm -f config.gen config.auto.f
