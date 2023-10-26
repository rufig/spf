## Some useful links

  - A set of documentaion files in [/docs/](https://github.com/rufig/spf/tree/master/docs), particularly:
    - [readme.en.md](https://github.com/rufig/spf/blob/master/docs/readme.en.md) - Overview
    - [intro.en.md](https://github.com/rufig/spf/blob/master/docs/intro.en.md) - SP-Forth specifics
  - The documentation online at https://spf.sourceforge.net/
  - Some additional hints in [Wiki](https://github.com/rufig/spf/wiki)
  - The sources in UTF-8 encoding in the repository [spf4-utf8](https://github.com/rufig/spf4-utf8)
    (since some files in the [spf](https://github.com/rufig/spf) repository
    are shown incorrectly via the GitHub online viewer)
  - https://github.com/yarus23/SPF.JS

## How to build from the sources

Clone the sources into your _spf4 working tree root_ directory, as
```
git clone https://github.com/rufig/spf/ ~/spf4 && cd ~/spf4/src/
```

or download the [ZIP archive](https://github.com/rufig/spf/archive/refs/heads/master.zip)
and unpack it into your arbitrary _spf4 working tree root_ forlder.

### In Windows

Run `src/compile.bat` — it will build `spf4.exe` in the _spf4 working tree root_.

Prerequisites: `powershell` to download the initial binary.

### In Linux

In the sub-directory `src/` run `make` — it will build `spf4` in the _spf4 working tree root_
(near to the directorory `src`).

Prerequisites (in Debian or Ubuntu, as an example):
```
dpkg --add-architecture i386
apt update
apt install  coreutils ca-certificates git wget build-essential gcc-multilib
```
