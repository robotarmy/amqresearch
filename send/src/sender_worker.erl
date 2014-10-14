-module(sender_worker).

-include("../deps/amqp_client-3.3.5/include/amqp_client.hrl").

-export([sending_loop/3,boot_send/0]).


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


sending_loop(Channel,Q,Count) ->
  io:format("loop ~p", [Count]),
  %% Publish a message
  Payload = erlang:list_to_binary(io_lib:format("~s ~b",[<<"Foobar ">>,Count])),
  io:format("~n ~p ~p~n",[Payload,Q]),
  Publish = #'basic.publish'{exchange = <<>>, routing_key = Q},
  What =  amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),
  io:format("~p ~n",[What]),
  % wait a few seconds before pushing in another message
  timer:sleep(1000),
  Next = Count + 1,

  sending_loop(Channel,Q,Next).

boot_send() ->
  Loop = fun() -> start_sending() end,
  Pid = spawn(Loop),
  {ok, Pid}.

