%% Feel free to use, reuse and abuse the code in this file.

-module(echo_protocol).
-behaviour(gen_server).
-behaviour(ranch_protocol).

%% API.
-export([start_link/4]).

%% gen_server.
-export([init/1]).
-export([init/4]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-define(TIMEOUT, 5000).

-record(state, {socket, transport}).

%% API.

start_link(Ref, Socket, Transport, Opts) ->
	proc_lib:start_link(?MODULE, init, [Ref, Socket, Transport, Opts]).

%% gen_server.

%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
init([]) -> {ok, undefined}.

init(Ref, Socket, Transport, _Opts = []) ->
	error_logger:info_report([{module, ?MODULE}, {connected, Socket}]),
	ok = proc_lib:init_ack({ok, self()}),
	ok = ranch:accept_ack(Ref),
	ok = Transport:setopts(Socket, [{active, once}]),
	gen_server:enter_loop(?MODULE, [],
		#state{socket=Socket, transport=Transport},
		?TIMEOUT).

handle_info({tcp, Socket, Data}, State=#state{
		socket=Socket, transport=Transport}) ->
	error_logger:info_report([{message, Data}	]),
	Transport:setopts(Socket, [{active, once}]),
	Transport:send(Socket, Data),
	{noreply, State, ?TIMEOUT};
handle_info({tcp_closed, _Socket}, State) ->
	{stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
	{stop, Reason, State};
handle_info(timeout, State) ->
	error_logger:info_report([{module, ?MODULE}, {timeout, State}]),
	{stop, normal, State};
handle_info(_Info, State) ->
	{stop, normal, State}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% Internal.
