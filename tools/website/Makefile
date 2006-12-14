
path=/home/groups/s/sp/spf
spf=$(path)/spf
web=$(path)/htdocs

target: www

update:
	cd $(spf)/docs && cvs up
	cd $(spf)/tools && cvs up

docs:
	$(MAKE) -C $(spf)/docs host=linux

www: update docs web

# copy to the web space only newly generated files
web:
	if test -f "$(spf)/docs/mark.new"; then \
	cd $(spf)/docs && cp $(shell cat $(spf)/docs/mark.new) $(web)/docs; \
	fi
