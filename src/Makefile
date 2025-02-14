#
# Compile SP-Forth for linux or Windows
# The default options can be overridden in ./compile.ini

# An alternative host Forth translator can be passed
# in the HOSTFORTH variable. By default it's spf4orig in Linux
# and jpf375c.exe in Windows (and Cygwin). The default translator
# is downloaded (using curl or wget) if it's missed.
# Example:
#   make HOSTFORTH=spf4 build

# The variable PLATFORM can be used to explicitly specify
# the 'win32' or 'posix' platform (otherwise it is selected automaticaly)
# Example:
#   make PLATFORM=win32 build

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.POSIX:
.DELETE_ON_ERROR:

.PHONY: clean build install


target: build

url-binaries-base   := https://github.com/rufig/spf4-cvs-archive/releases/download/v1.0/

orig-bin-lin    := spf4orig
orig-bin-win    := jpf375c.exe
shasum-bin-lin  := 3987f9b90257a0d49eda2cc39324b574e1b580dd
shasum-bin-win  := 1b1a244c615f8838ecd1bcd8a1f7907bae60664e

define download-binary
  @\
  { command -v curl >/dev/null && c="curl -L -o" ; } || \
  { command -v wget >/dev/null && c="wget --no-verbose -O" ; } || \
  { echo "Error, cannot download $@"; exit 1; } ;\
  cmd="$$c $@ $(url-binaries-base)$(notdir $@)";\
  echo "$$cmd" && $$cmd && chmod +x "$@"
endef

../$(orig-bin-lin) :
	$(download-binary)
	echo 'SHA1 ($@) = $(shasum-bin-lin)' | sha1sum --warn --check -

../$(orig-bin-win) :
	$(download-binary)
	echo 'SHA1 ($@) = $(shasum-bin-win)' | sha1sum --warn --check -


ifeq ($(OSTYPE),cygwin)
  platform := win32
else
ifeq ($(OS),Windows_NT)
  platform := win32
else
  platform := posix
endif
endif

PLATFORM ?= $(platform)

ifeq ($(PLATFORM),posix)
  target-bin := spf4
  orig-bin := $(orig-bin-lin)
else
  target-bin := spf4.exe
  orig-bin := $(orig-bin-win)
endif


maybe-check-orig-bin :=

ifeq ($(HOSTFORTH),)
  maybe-check-orig-bin := ../$(orig-bin)
  HOSTFORTH := ./$(orig-bin)
endif

common-sources := *.f *.F compiler/*.f $(wildcard compile.ini) $(maybe-check-orig-bin)


posix/config.auto.f : posix/config.h posix/config.c
	make -C posix

spf4.o: $(common-sources) posix/config.auto.f  posix/*.f
	cd .. && echo "Wait a bit while compiling..." && echo 1 HALT | $(HOSTFORTH) src/spf.f

../spf4: spf4.o forth.ld
	gcc -v 2>&1 | grep -F --silent -- '--enable-default-pie' && gcc_nopie="-no-pie" ; \
	gcc -o $@ $< -Wl,forth.ld -ldl -lpthread -v -m32 -fno-pie $$gcc_nopie


../spf4.exe: $(common-sources) win/*.f win/res/*
	cd .. ; echo 1 HALT | $(HOSTFORTH) src/tc-configure-lines.f src/spf.f


build: ../$(target-bin)

install: build


clean:
	rm -f spf4.o
	make -C posix clean
