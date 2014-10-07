defmodule Urkel.Plugin.Pong do
  use Urkel.Plugin.Mixin

  def init(_), do: :nothing

  def handle(pid, %Message{command: "PING", trailing: server}) do
    Conn.send(pid, %Message{command: "PONG", trailing: server})
  end

  def handle(_, _), do: :nothing
end
