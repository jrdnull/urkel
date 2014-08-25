defmodule Urkel.Irc do
	defmodule Prefix, do: defstruct nick: nil, user: nil, host: nil
  defmodule Message, do: defstruct prefix: nil, command: nil, params: [], trailing: nil
end
