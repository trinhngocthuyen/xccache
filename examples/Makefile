XCCACHE_ARGS := --verbose

format:
	cd .. && make format

cache.use:
	bundle exec xccache use $(XCCACHE_ARGS)

cache.build:
	bundle exec xccache build $(TARGET) $(XCCACHE_ARGS)

cache.init:
	bundle exec xccache init $(XCCACHE_ARGS)

cache.rollback:
	bundle exec xccache rollback $(XCCACHE_ARGS)

cache.viz:
	bundle exec xccache viz --out=xccache $(XCCACHE_ARGS)

build:
	cicd ios build

test:
	cicd ios test

check:
	rm -rf xccache/packages/umbrella/.build xccache/cachemap.json
	make cache.build build

ex.%:
	make $*
