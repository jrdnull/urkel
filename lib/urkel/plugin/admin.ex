defmodule Urkel.Plugin.Admin do
  use Urkel.Plugin.Mixin

  @admin %Prefix{host: "C86A9EBA.D4828085.69B3A1C0.IP"}

  def handle(pid, msg = %Message{
    command: "PRIVMSG",
    trailing: text,
    prefix: admin
  }) do
    cond do
      text =~ ~r/^:join/ ->
        join(pid, text |> String.split_at(6) |> elem(1))
      text =~ ~r/^:part/ ->
        part(pid, text |> String.split_at(6) |> elem(1))
      text =~ ~r/^:echo/ ->
        privmsg(
          pid,
          msg |> Irc.get_target,
          text |> String.split_at(6) |> elem(1)
        )
      true -> nil
    end
  end

  def handle(_, _), do: :nothing
end
