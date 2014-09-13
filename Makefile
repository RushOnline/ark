all: compile

compile:
	rebar compile

run: compile
	[ -f ~/.sshd/ssh_host_rsa_key ] || (mkdir -p ~/.sshd && ssh-keygen -t rsa -f ~/.sshd/ssh_host_rsa_key)
	erl -pa deps/ranch/ebin -pa ebin -s ark start $$HOME/.sshd $$HOME/.ssh

rel:
	rebar generate

rrun:
	rel/ark/bin/ark console


.PHONY: all run compile rel rrun
