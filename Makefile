all:	tests

tests:
	shellcheck -s ksh beaconcli.sh

.PHONY: tests
