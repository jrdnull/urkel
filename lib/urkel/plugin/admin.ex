defmodule Urkel.Plugin.Admin do
  alias Urkel.Irc.Prefix, as: Prefix
  alias Urkel.Irc.Message, as: Message
  alias Urkel.Irc.Connection, as: Conn

  require Logger

  def handle(pid, %Message{command: "PRIVMSG", trailing: msg, prefix: %Prefix{host: "C86A9EBA.D4828085.69B3A1C0.IP"}}) do
    cond do
      msg =~ ~r/^:join/ ->
        Conn.send(pid, %Message{command: "JOIN", params: [String.split(msg, " ") |> List.last]})
      true -> nil
    end
  end

  def handle(_, _), do: :nothing
end
