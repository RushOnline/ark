all: compile run

compile:
	rebar compile

run:
	erl -pa deps/ranch/ebin -pa ebin

rel:
	rebar generate
	rel/ark/bin/ark console

.PHONY: all run compile rel
