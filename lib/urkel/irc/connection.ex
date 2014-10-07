defmodule Urkel.Irc.Connection do
  use GenServer

  require Logger

  alias Urkel.Irc.Connection, as: Self
  alias Urkel.Irc.Message, as: Message

  ###
  # External API

  def start_link(handlers) do
    Logger.info("Connecting...")
    {:ok, sock} = Socket.TCP.connect("irc.rizon.net", 6667, packet: :line)
    {:ok, pid}  = GenServer.start_link(__MODULE__, {sock, handlers})
    Logger.info("Connected!")

    Self.send(pid, %Message{command: "USER", params: ["urkel", "0", "*"], trailing: "urkel"})
    Self.send(pid, %Message{command: "NICK", params: ["urkel"]})

    for handler <- handlers, do: pid |> handler.init

    spawn_link(listen(pid, sock))

    {:ok, pid}
  end

  def add_handler(pid, handler) do
    GenServer.cast(pid, {:add, handler})
  end

  def send(pid, msg) do
    GenServer.cast(pid, {:send, msg})
  end

  defp listen(pid, sock) do
    {:ok, data} = sock |> Socket.Stream.recv
    GenServer.cast(pid, {:receive, data |> Urkel.Irc.Parser.parse})
    listen(pid, sock)
  end

  ###
  # GenServer Implementation

  def handle_cast({:add, plugin}, {sock, plugins}) do
    {:noreply, {sock, [plugin | plugins]}}
  end

  def handle_cast({:receive, msg}, {sock, plugins}) do
    Logger.info("< #{msg}")
    for plugin <- plugins do
      Task.start(plugin, :handle, [self, msg])
    end
    {:noreply, {sock, plugins}}
  end

  def handle_cast({:send, msg}, {sock, plugins}) do
    Logger.info("> #{msg}")
    Socket.Stream.send(sock, "#{msg}\r\n")
    {:noreply, {sock, plugins}}
  end
end
