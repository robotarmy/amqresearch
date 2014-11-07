-module(sender_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  StartMod = sender_worker,
  ChildSpec = {StartMod, {StartMod, boot_send, []}, permanent, 4, worker, [StartMod]},
  {ok, {{one_for_one, 1, 5}, [ChildSpec]}}.
  %{ok, Pid} = sender_worker:boot_send(),
  %link(Pid),
  %Pids = [],
  %{ok, {{one_for_one, 1, 5}, Pids}}.
