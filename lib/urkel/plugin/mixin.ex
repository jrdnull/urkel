defmodule Urkel.Plugin.Mixin do
  defmacro __using__(_) do
    quote do
      require Logger

      alias Urkel.Irc, as: Irc
      alias Irc.Prefix, as: Prefix
      alias Irc.Message, as: Message
      alias Irc.Connection, as: Conn

      def join(pid, channel) do
        Conn.send(pid, %Message{command: "JOIN", params: [channel]})
      end

      def part(pid, channel) do
        Conn.send(pid, %Message{command: "PART", params: [channel]})
      end

      def privmsg(pid, target, text) do
        Conn.send(pid, %Message{command: "PRIVMSG", params: [target], trailing: text})
      end
    end
  end
end
