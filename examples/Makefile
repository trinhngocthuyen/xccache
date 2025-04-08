XCCACHE_ARGS := --verbose

cache.use:
	bundle exec xccache use $(XCCACHE_ARGS)

cache.build:
	bundle exec xccache build $(XCCACHE_ARGS)

cache.b_u:
	bundle exec xccache build --use $(XCCACHE_ARGS)

cache.init:
	bundle exec xccache init $(XCCACHE_ARGS)

cache.rollback:
	bundle exec xccache rollback $(XCCACHE_ARGS)

build:
	cicd ios build

check:
	rm -rf xccache/packages/umbrella/.build
	make cache.b_u build

ex.%:
	make $*
