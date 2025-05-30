install:
	which pre-commit &> /dev/null || pip3 install pre-commit
	pre-commit install
	bundle install

format:
	pre-commit run --all-files

test:
	bundle exec rspec

ex.%:
	cd examples && make $*

proxy.build:
	mkdir -p libexec/.local
	cd tools/xccache-proxy && make build CONFIGURATION=release
	cp tools/xccache-proxy/.build/release/xccache-proxy libexec/.local/
