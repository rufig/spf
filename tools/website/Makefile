
# put this command in crontab (login via ssh and crontab -e)
# Dont forget to remove leading # sign
# http://sourceforge.net/docs/E07/#cron
#
# ----
# # update web pages from the cvs
# 24 * * * * cd /home/groups/s/sp/spf/spf/tools/website && cvs up -d -P -C && make
# ----

# 24 - this is random minute

path=/home/groups/s/sp/spf
spf=$(path)/spf
web=$(path)/htdocs

target: www

update:
	cd $(spf)/docs && cvs up
	cd $(spf)/tools && cvs up

docs:
	$(MAKE) -C $(spf)/docs host=linux usage=web

$(web)/index.html: index.html
	cp index.html $(web)

www: update docs web_docs $(web)/index.html

# copy to the web space only newly generated files
web_docs:
	if test -f "$(spf)/docs/mark.new"; then \
	cd $(spf)/docs && cp $(shell cat $(spf)/docs/mark.new) $(web)/docs; \
	fi
