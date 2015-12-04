TESTS=$(shell ls test/*.rb)

test:
	ruby -W2 bin/cutest $(TESTS)

extras/cutest: lib/cutest.rb bin/cutest
	printf '#!/usr/bin/env ruby\n\n'                   >  ./extras/cutest
	cat ./lib/cutest.rb                                >> ./extras/cutest
	cat ./bin/cutest | sed '1,2d;/^require_relative/d' >> ./extras/cutest

	chmod +x ./extras/cutest

.PHONY: test
