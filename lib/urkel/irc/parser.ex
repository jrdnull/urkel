defmodule Urkel.Irc.Parser do
  alias Urkel.Irc.Prefix, as: Prefix
  alias Urkel.Irc.Message, as: Message

  def to_string(msg) do
    buf = if msg.prefix, do: ":#{msg.prefix} #{msg.command}", else: "#{msg.command}"
    buf = if msg.params != [], do: "#{buf} #{Enum.join(msg.params," ")}", else: buf
    buf = if msg.trailing, do: "#{buf} :#{msg.trailing}", else: buf
    "#{buf}\r\n"
  end

  def parse(raw) do
    no_crlf = String.replace(raw, "\r\n", "")
    %Message{prefix: extract_prefix(no_crlf),
             command: extract_command(no_crlf),
             params: extract_params(no_crlf),
             trailing: extract_trailing(no_crlf)}
  end

  defp extract_prefix(raw) do
    if has_prefix?(raw) do
      raw |> String.split(" ") |> List.first |> String.slice(1, 500) |> parse_prefix
    else
      nil
    end
  end

  defp parse_prefix(prefix) do
    case String.split(prefix, ~r{(!|@)}) do
      [n, u, h] -> %Prefix{nick: n, user: u, host: h}
      [server]  -> %Prefix{host: server}
    end
  end

  defp extract_command(raw) do
    raw |> String.split(" ") |> Enum.at(if has_prefix?(raw), do: 1, else: 0)
  end

  defp extract_params(raw) do
    parts = if has_prefix?(raw), do: 3, else: 2
    split = raw |> String.split(" :") |> List.first |> String.split(" ", parts: parts) 
    if Enum.count(split) < parts, do: [], else: String.split(List.last(split), " ")
  end

  defp extract_trailing(raw) do
    case String.split(raw, " :") do
      [_, trailing] -> trailing
      _ -> nil
    end
  end

  defp has_prefix?(raw), do: String.first(raw) == ":"
end
