XCCACHE_ARGS := --verbose

cache.use:
	bundle exec xccache use $(XCCACHE_ARGS)

cache.build:
	bundle exec xccache build $(XCCACHE_ARGS)

cache.b_u: cache.build cache.use

cache.init:
	bundle exec xccache init $(XCCACHE_ARGS)

cache.rollback:
	bundle exec xccache rollback $(XCCACHE_ARGS)

build:
	cicd ios build

ex.%:
	make $*
