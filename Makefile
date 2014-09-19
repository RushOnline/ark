all: compile

compile:
	rebar compile

run: compile
	[ -f ~/.sshd/ssh_host_rsa_key ] || (mkdir -p ~/.sshd && ssh-keygen -t rsa -f ~/.sshd/ssh_host_rsa_key)
	erl -pa deps/*/ebin -pa ebin -s ark start $$HOME/.sshd $$HOME/.ssh

rel:
	rebar generate

rrun:
	rel/ark/bin/ark console

setcaps:
	sudo setcap cap_net_raw=ep /usr/lib/erlang/erts-*/bin/beam.smp
	getcap /usr/lib/erlang/erts-*/bin/beam.smp

.PHONY: all run compile rel rrun setcaps
