-module(sender_sup).
-behaviour(supervisor).

-include("../deps/amqp_client-3.3.5/include/amqp_client.hrl").


-export([sending_loop/3,start_sending/0]).
-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).



start_sending() ->
  %% Start a network connection
  {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
  %% Open a channel on the connection
  {ok, Channel} = amqp_connection:open_channel(Connection),

  %% Declare a queue with a generated name
  % #'queue.declare_ok'{queue = Q}
  %= amqp_channel:call(Channel, #'queue.declare'),
  %
  % Declare a queue with a name
  %
  Q = <<"transactions-completed">>,
  Declare = #'queue.declare'{queue = Q},

  #'queue.declare_ok'{} = amqp_channel:call(Channel, Declare),

  Ret = sending_loop(Channel,Q,0),

  %% Close the channel
  amqp_channel:close(Channel),
  %% Close the connection
  amqp_connection:close(Connection),

  {ok, Ret}.


% stop after 100 messages
sending_loop(_,_,10) ->
  {ok, loop_terminated};

sending_loop(Channel,Q,Count) ->
  %% Publish a message
  Payload = erlang:list_to_binary(io_lib:format("~s ~b",[<<"Foobar ">>,Count])),
  Publish = #'basic.publish'{exchange = <<>>, routing_key = Q},
  amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),
  % wait a few seconds before pushing in another message
  timer:sleep(1000),
  Next = Count + 1,

  sending_loop(Channel,Publish,Next).

init([]) ->
  start_sending().
