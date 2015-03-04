TESTS=$(shell ls test/*.rb)

test:
	ruby -W2 bin/cutest $(TESTS)

.PHONY: test
