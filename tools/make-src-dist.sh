#!/bin/sh
#
# $Id$
#
# Build spf-linux source distribution

################################

spf_cvs=/home/ygrek/work/forth/spf-pub
spf4orig=/home/ygrek/work/forth/spf/spf4orig
out=spf-4.19-cvs20080928

################################

if [ -e $out ]; then
  echo "Error: target path $out exists";
  exit 1;
fi

mkdir -p $out
for dir in src lib docs samples; do
  cp -R $spf_cvs/$dir $out/$dir
done
cp $spf_cvs/spf4root/* $out
cp $spf4orig $out/spf4orig

mkdir $out/tools
cp -R $spf_cvs/tools/doc $out/tools/doc

# create compile.ini 
echo "TRUE TO UNIX-ENVIRONMENT" > $out/src/compile.ini
echo "TRUE TO TARGET-POSIX" >> $out/src/compile.ini

# convert documentation
make -C $out/docs host=linux

# remove markdown files
rm -f $out/docs/*.md $out/docs/*.mdt

# remove CVS directories
find $out -wholename '*/CVS*' -delete

# remove tools directory
rm -rf $out/tools

# pack
tar -czf $out.tar.gz $out

rm -rf $out
