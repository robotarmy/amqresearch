{application, sender, [
	{description, ""},
	{vsn, "0.1.0"},
	{modules, ['amqp_example', 'sender_app', 'sender_sup', 'sender_worker']},
	{registered, []},
	{applications, [
		kernel,
		stdlib
	]},
	{mod, {sender_app, []}},
	{env, []}
]}.
