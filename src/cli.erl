-module(cli).

%% api
-export([start_our_shell/2]).

%%% spawns out shell loop, we use plain io to input and output
%%% over ssh (the group module is our group leader, and takes
%%% care of sending input to the ssh_sample_cli server)
start_our_shell(User, Peer) ->
    spawn(fun() ->
		  cli_parser:start_link(), %% TODO: this must be somewhere in supervisor tree
		  io:setopts([{expand_fun, fun(Bef) -> cli_parser:expand(Bef) end}]),
		  io:format("Welcome Ark!\n"),
		  put(user, User),
		  put(peer_name, Peer),
		  our_shell_loop()
	  end).

%%% an ordinary Read-Eval-Print-loop
our_shell_loop() ->
    % Read
    Line = io:get_line("CLI> "),
    % Eval
    Result = cli_parser:evaluate(Line),
    % Print
    io:format("---> ~p\n", [Result]),
    case Result of
	done -> 
	    exit(normal);
	crash -> 
	    1 / 0;
	_ -> 
	    our_shell_loop()
    end.
