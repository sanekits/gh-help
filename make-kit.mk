# make-kit.mk for gh-help
#  This makefile is included by the root shellkit Makefile
#  It defines values that are kit-specific.
#  You should edit it and keep it source-controlled.

# TODO: update kit_depends to include anything which
#   might require the kit version to change as seen
#   by the user -- i.e. the files that get installed,
#   or anything which generates those files.
kit_depends := \
    bin/gh-help.bashrc \
    bin/gh-help.sh

publish_extra_files:=foobar

foobar:
	touch foobar

publish: pre-publish
	@# TODO: you can customize publication by adding steps here (before publish-common)
	make publish-common
	@# (After common publication)
	@echo publish complete OK
