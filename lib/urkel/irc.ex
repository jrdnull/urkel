defmodule Urkel.Irc do
	defmodule Prefix, do: defstruct nick: nil, user: nil, host: nil
  defimpl String.Chars, for: Prefix do
    def to_string(%Prefix{nick: nil, user: nil, host: h}), do: h
    def to_string(%Prefix{nick: n, user: u, host: h}), do: "#{n}!#{u}@#{h}"
  end

  defmodule Message, do: defstruct prefix: nil, command: nil, params: [], trailing: nil
  defimpl String.Chars, for: Message do
    def to_string(msg) do
      buf = if msg.prefix, do: ":#{msg.prefix} #{msg.command}", else: "#{msg.command}"
      buf = if msg.params != [], do: "#{buf} #{Enum.join(msg.params," ")}", else: buf
      buf = if msg.trailing, do: "#{buf} :#{msg.trailing}", else: buf
      buf
    end
  end

  def get_target(%Message{params: [param], prefix: %Prefix{nick: nick}}) do
    if param |> String.at(0) == "#", do: param, else: nick
  end
end
