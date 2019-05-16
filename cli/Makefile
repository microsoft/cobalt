.PHONY: test
PATH_TO_FILE = "./cli/Gopkg.toml"

build:
	go build -o cobalt -v

run:
	go build -o cobalt -v
	./cobalt -h
	rm cobalt

test: 
	go test ./test -v

deps:
ifeq ("$(wildcard $(PATH_TO_FILE))","")
	dep init
endif
	dep ensure