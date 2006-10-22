
path=/home/groups/s/sp/spf
spf=$(path)/spf
web=$(path)/htdocs

target: www

update:
	cd $(spf)/docs && cvs up
	cd $(spf)/tools && cvs up

docs:
	$(MAKE) -C $(spf)/docs/papers host=linux

www: update docs
	cp $(spf)/docs/papers/*.html $(web)/docs
