defmodule Urkel do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
        worker(Urkel.Irc.Connection, [[Urkel.Plugin.Pong, Urkel.Plugin.Title]])
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  end
end
