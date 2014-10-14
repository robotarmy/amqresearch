-module(amqp_example).

-include("../deps/amqp_client-3.3.5/include/amqp_client.hrl").
-export([test/0]).

test() ->
  %% Start a network connection
  {ok, Connection} = amqp_connection:start(#amqp_params_network{}),
  %% Open a channel on the connection
  {ok, Channel} = amqp_connection:open_channel(Connection),

  %% Declare a queue
  #'queue.declare_ok'{queue = Q}
  = amqp_channel:call(Channel, #'queue.declare'{}),

  %% Publish a message
  Payload = <<"foobar">>,
  Publish = #'basic.publish'{exchange = <<>>, routing_key = Q},
  amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),

  %% Get the message back from the queue
  Get = #'basic.get'{queue = Q},
  {#'basic.get_ok'{delivery_tag = Tag},_}
  = amqp_channel:call(Channel, Get),

  %% Do something with the message payload
  %% (some work here)

  %% Ack the message
  amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),

  %% Close the channel
  amqp_channel:close(Channel),
  %% Close the connection
  amqp_connection:close(Connection),

  ok.

