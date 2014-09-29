defmodule Urkel.Plugin.Pong do
  alias Urkel.Irc.Message, as: Message
  alias Urkel.Irc.Connection, as: Conn

  def handle(pid, %Message{command: "PING", trailing: server}) do
    Conn.send(pid, %Message{command: "PONG", trailing: server})
  end

  def handle(_, _), do: :nothing
end
