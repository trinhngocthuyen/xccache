install:
	which pre-commit &> /dev/null || pip3 install pre-commit
	pre-commit install
	bundle install

format:
	pre-commit run --all-files

test:
	bundle exec rspec
