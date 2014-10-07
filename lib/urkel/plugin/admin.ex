defmodule Urkel.Plugin.Admin do
  use Urkel.Plugin.Mixin

  @password "password" # TODO: use Mix.config instead

  def init(_), do: Agent.start_link(fn -> [] end, name: __MODULE__)

  def handle(pid, msg = %Message{command: "PRIVMSG", trailing: text}) do
    target = msg |> Irc.get_target
    cond do
      text =~ ~r/^:auth/ ->
        if text |> String.split_at(6) |> elem(1) == @password do
          Agent.update(__MODULE__, fn admins -> [msg.prefix | admins] end)
          privmsg(pid, target, "Welcome!")
        else
          privmsg(pid, target, "Denied!")
        end
      text =~ ~r/^:admins/ ->
        privmsg(pid, target, "Bot Adminsitrators:")
        for admin <- admins, do: privmsg(pid, target, admin)
      true -> nil
    end

    if is_admin(msg.prefix), do: handle_admin(pid, msg)
  end

  def handle(_, _), do: :nothing

  defp handle_admin(pid, msg = %Message{trailing: text}) do
    cond do
      text =~ ~r/^:join/ ->
        join(pid, text |> String.split_at(6) |> elem(1))
      text =~ ~r/^:part/ ->
        part(pid, text |> String.split_at(6) |> elem(1))
      true -> nil
    end
  end

  defp admins() do
    Agent.get(__MODULE__, fn admins -> admins end)
  end

  defp is_admin(prefix),
  do: Agent.get(__MODULE__, fn admins -> prefix in admins end)
end
