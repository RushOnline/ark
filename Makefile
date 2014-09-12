all: compile

compile:
	rebar compile

run: compile
	erl -pa deps/ranch/ebin -pa ebin -s ark_app

rel:
	rebar generate

rrun:
	rel/ark/bin/ark console

.PHONY: all run compile rel rrun
