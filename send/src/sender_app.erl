-module(sender_app).
-behaviour(application).

-export([start/2,start/0]).
-export([stop/1]).

start() ->
  application:start(sender).

start(_Type, _Args) ->
  io:format("start_app-> sender_sup~n"),
	sender_sup:start_link().

stop(_State) ->
	ok.


