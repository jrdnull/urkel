defmodule Urkel.Plugin.Mixin do
  defmacro __using__(_) do
    quote do
      alias Urkel.Irc, as: Irc
      alias Irc.Prefix, as: Prefix
      alias Irc.Message, as: Message
      alias Irc.Connection, as: Conn

      require Logger
    end
  end
end
