%% Feel free to use, reuse and abuse the code in this file.

-module(echo_protocol).
-behaviour(gen_server).
-behaviour(ranch_protocol).

-include("telnet.hrl").

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

-record(state, {socket, transport, hbuf = <<>>, tbuf = <<>>}).

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
	welcome(Transport, Socket),
	gen_server:enter_loop(?MODULE, [],
		#state{socket=Socket, transport=Transport},
		?TIMEOUT).

handle_info({tcp, Socket, Data}, State=#state{
		socket=Socket, transport=Transport, hbuf=HBuf, tbuf=TBuf}) ->
	error_logger:info_report([{recv, Data}]),
	Transport:setopts(Socket, [{active, once}]),
	{ok, Echo, NewHBuf, NewTBuf} = keypress(Data, HBuf, TBuf),
	Transport:send(Socket, Echo),
	error_logger:info_report([{send, Echo}]),
	% Transport:send(Socket, Data),
	{noreply, State#state{hbuf=NewHBuf, tbuf=NewTBuf}, ?TIMEOUT};
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

welcome(Transport, Socket) ->
    Transport:send(Socket, <<?IAC, ?WILL, ?ECHO>>),
    Transport:send(Socket, <<?IAC, ?WILL, ?SUPPRESS_GO_AHEAD>>),
    Transport:send(Socket, <<?IAC, ?DONT, ?LINE_MODE>>),
    Transport:send(Socket, <<?IAC, ?DO, ?WINDOW_SIZE>>), % Do window size negotiation
    Transport:send(Socket,<<?CR, ?LF>>),
    Transport:send(Socket,<<"Welcome to Ark!", ?CR, ?LF>>),
    Transport:send(Socket,<<"$ ">>).

keypress(<<?IAC, _Rest/binary>>, HBuf, TBuf) ->
    {ok, "", HBuf, TBuf};
keypress(<<?CR,0>>, HBuf, TBuf) ->
    {ok, [ <<?CR, ?LF>>, "command: ", HBuf, TBuf, <<?CR, ?LF>>, "$ " ], <<>>, <<>>};
keypress(Data, HBuf, TBuf) ->
	{ok, Data, append(HBuf, Data), TBuf}.

append(Acc, Tail) ->
	binary:list_to_bin([ binary:bin_to_list(Acc), binary:bin_to_list(Tail) ]).