.PHONY: test

test:
	nvim --headless -u test/minimal.vim -c "PlenaryBustedDirectory test/automated { minimal_init = './test/minimal.vim' }"
