# $Id$
# Automatic updating of website from CVS
#
# put this command in crontab (login via ssh and crontab -e)
# Dont forget to remove leading # sign
# http://sourceforge.net/docs/E07/#cron
#
# ----
# # update web pages from the cvs
# 24 * * * * cd /home/groups/s/sp/spf/spf/tools/website && cvs up -d -P -C && make
# ----
#
# 24 - this is random minute

path:=/home/groups/s/sp/spf
spf:=$(path)/spf
web:=$(path)/htdocs

# testing
#spf:=/home/ygrek/work/forth/spf
#web:=/home/ygrek/work/forth/spf/tools/website/htdocs

# Files copied to the web space unconditionally
# for now all files from docs/images
images:=$(notdir $(wildcard $(spf)/docs/images/*.png))
# those files with the full path at the web space
webimages:=$(addprefix $(web)/docs/images/, $(images))

target: www

update:
	cd $(spf)/docs && cvs up -d -P
	cd $(spf)/tools && cvs up -d -P

make_docs:
	$(MAKE) -C $(spf)/docs host=linux usage=web

$(web)/docs:
	if ! test -d "$@"; then mkdir $@; fi

$(web)/docs/images: $(web)/docs
	if ! test -d "$@"; then mkdir $@; fi

$(web)/index.html: $(spf)/tools/website/index.html
	cp $< $@

$(web)/index.css: $(spf)/tools/website/index.css
	cp $< $@

$(web)/favicon.ico: $(spf)/tools/website/favicon.ico
	cp $< $@

$(web)/spf.png: $(spf)/tools/website/spf.png
	cp $< $@

$(web)/docs/images/%: $(spf)/docs/images/%
	cp $< $@

www: update web_docs $(web)/index.html $(web)/favicon.ico $(web)/spf.png $(web)/docs/images $(webimages) $(web)/index.css

# copy to the web space only newly generated files
web_docs: $(web)/docs make_docs
	if test -f "$(spf)/docs/mark.new"; then \
	cd $(spf)/docs && cp $(shell cat $(spf)/docs/mark.new) $(web)/docs/; \
	fi
