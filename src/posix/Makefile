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

message-multilib-missing := 'Error: cannot compile a 32-bit binary, "gcc-multilib" is missing'
# In Debian or Ubuntu, to install 32-bit libraries, run:
#   sudo sh -c 'dpkg --add-architecture i386 && apt update && apt install gcc-multilib'


config.auto.f: config.gen
		$(HOSTWRAPPER) ./$< > $@

config.gen: config.c
		$(CC) -m32 -print-file-name=libc.so | grep -q '^/' || { echo $(message-multilib-missing); false; }
		$(CC) -Wall -Werror -DSPF_SRC $< -o$@ -m32

clean:
		rm -f config.gen config.auto.f
