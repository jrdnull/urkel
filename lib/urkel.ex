defmodule Urkel do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Urkel.Irc.Connection, [plugins])
    ]

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp plugins do
    [
      Urkel.Plugin.Pong,
      Urkel.Plugin.Admin,
      Urkel.Plugin.Title
    ]
  end
end
