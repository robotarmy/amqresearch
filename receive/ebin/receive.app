{application, receive, [
	{description, ""},
	{vsn, "0.1.0"},
	{modules, ['receive_app', 'receive_sup']},
	{registered, []},
	{applications, [
		kernel,
		stdlib
	]},
	{mod, {receive_app, []}},
	{env, []}
]}.
