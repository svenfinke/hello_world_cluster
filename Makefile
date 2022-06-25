all: build run

build:
	docker build ./app -t hw_test
run:
	docker run -d hw_test