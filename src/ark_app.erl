-module(ark_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
	start(normal, []).

start(_StartType, _StartArgs) ->
	application:start(sasl),
	application:start(ranch),
	{ok, _} = ranch:start_listener(tcp_echo, 1,
				ranch_tcp, [{port, 5555}], echo_protocol, []),
    ark_sup:start_link().

stop(_State) ->
    ok.
