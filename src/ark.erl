%% @author rush
%% @doc @todo Add description to ark.


-module(ark).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1, start/0]).

-ifndef(ETH_P_ALL).
-define(ETH_P_ALL, 3).
-endif.

-ifndef(AF_PACKET).
-define(AF_PACKET, 17).                     % Packet family.
-endif.

-ifndef(PF_PACKET).
-define(PF_PACKET, ?AF_PACKET).
-endif.

-ifndef(SOCK_RAW).
-define(SOCK_RAW, 3).       % Raw protocol interface.
-endif.

start() ->
	start(['/home/rush/.ssh', '/home/rush/.sshd']).

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
	Port = procket:socket(?AF_PACKET, ?SOCK_RAW, ?ETH_P_ALL), 
	io:format("* procket:socket -> ~p~n", [Port]),
	application:start(ark).

%% ====================================================================
%% Internal functions
%% ====================================================================
