defmodule Urkel.Irc.Plugin.Mixin do
  defmacro __using__(_) do
    quote location: keep do
      def count(e) do
        reduce(e, 0, fn (_, acc) -> acc + 1 end)
      end
      def member?(e, x) do
        reduce(e, false, fn (v, acc) -> acc or x == v end)
      end
    end
  end
end
