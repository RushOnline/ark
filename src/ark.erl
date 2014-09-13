%% @author rush
%% @doc @todo Add description to ark.


-module(ark).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1]).

start([ServerSshDir, UserSshDir]) ->
	application:start(sasl),
	ssh:start(),
	ssh:daemon(any, 2222, [
		{system_dir, atom_to_list(ServerSshDir)},
		{user_dir, atom_to_list(UserSshDir)},
% start erlang shell
%		{shell, {shell, start, []}}

% bug in ssh, we can't use function in 17.1
% patch location: https://github.com/erlang/otp/commit/375e6da4a0daa6592a418ecb53afa37aa186f38f
%		{shell, fun(User, Peer) -> shell(User, Peer) end}

		% So we just start shell from ssh examples
		{shell, {cli, start_our_shell, [nouser, nopeer]}}
					 ]),
	application:start(ranch),
	application:start(ark).

%% ====================================================================
%% Internal functions
%% ====================================================================
