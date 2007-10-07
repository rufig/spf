
# put this command in crontab (login via ssh and crontab -e)
# Dont forget to remove leading # sign
# http://sourceforge.net/docs/E07/#cron
#
# ----
# # update web pages from the cvs
# 24 * * * * cd /home/groups/s/sp/spf/spf/tools/website && cvs up -d -P -C && make
# ----

# 24 - this is random minute

#path=/home/groups/s/sp/spf
#spf=$(path)/spf
#web=$(path)/htdocs
web=~/work/forth/spf/tools/website/qu
spf=../..

target: www

update:
	cd $(spf)/docs && cvs up -d -P
	cd $(spf)/tools && cvs up -d -P

make_docs:
	$(MAKE) -C $(spf)/docs host=linux usage=web

$(web)/index.html: index.html
	cp index.html $(web)

$(web)/favicon.ico: favicon.ico
	cp favicon.ico $(web)

$(web)/docs/images: $(web)/docs
	if ! test -d "$@"; then mkdir $@; fi

$(web)/docs/images/%.png: $(spf)/docs/images/%.png $(web)/docs/images 
	cp $< $@

images: $(web)/docs/images $(web)/docs/images/wrap.png $(web)/docs/images/doc.png $(web)/docs/images/example.png

www: update web_docs $(web)/index.html $(web)/favicon.ico 

$(web)/docs:
	if ! test -d "$@"; then mkdir $@; fi

# copy to the web space only newly generated files
web_docs: $(web)/docs make_docs images
	if test -f "$(spf)/docs/mark.new"; then \
	cd $(spf)/docs && cp $(shell cat $(spf)/docs/mark.new) $(web)/docs; \
	fi
