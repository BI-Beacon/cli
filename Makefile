all:	tests

TEST_SHELLS := posh bash dash ksh mksh zsh

tests:
	shellcheck -s ksh beaconcli.sh
	for SHELL in $(TEST_SHELLS) ; do \
	  echo "Running test suite using shell \`$${SHELL}'..." ; \
	  ! $$SHELL beaconcli.sh > .output.$$SHELL 2>&1 ; \
	  BATS_SHELL=$$SHELL bats ./tests ; \
    done
	sha1sum .output.* | awk '{print $$1}' | sort | uniq | wc -l | xargs test 1 ==

clean:
	rm -rf .output.* .conf *~ .*~ .\#* \#*\#

setup_tests:
	sudo apt install shellcheck bats curl posh dash ksh mksh zsh

print-%: ; @echo $($*)

.PHONY: tests clean print-%

