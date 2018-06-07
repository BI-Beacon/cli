all:	tests

tests:
	shellcheck -s ksh beaconcli.sh
	! bash beaconcli.sh > .output.bash 2>&1
	! ksh beaconcli.sh  > .output.ksh 2>&1
	! dash beaconcli.sh > .output.dash 2>&1
	diff3 .output.bash .output.ksh .output.dash

clean:
	rm -f .output.*

.PHONY: tests
