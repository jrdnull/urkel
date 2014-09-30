defmodule Urkel.Plugin.Title do
  alias Urkel.Irc.Prefix, as: Prefix
  alias Urkel.Irc.Message, as: Message
  alias Urkel.Irc.Connection, as: Conn

  require Logger

  @url_re ~r/((https?:\/\/|www[.])[^\s()<>]+)/
  @title_re ~r/<title>(.*?)<\/title>/i

  # TODO: don't reply to self
  def handle(pid, %Message{command: "PRIVMSG", params: [target], trailing: msg}) do
    case Regex.run(@url_re, msg, capture: :first) do
      url ->
        Task.start_link fn ->
          case get_title(url) do
            nil ->
              Logger.info("[Title]: Failed to get title of #{url}")
            title ->
              Conn.send(pid, %Message{command: "PRIVMSG", params: [target], trailing: title})
          end
        end
      _ -> nil
    end
  end

  def handle(_, _), do: :nothing

  defp get_title(url), do: get_title(url, 0)
  defp get_title(url, tries) do
    resp = HTTPoison.get(url)
    if resp.status_code == 301 || resp.status_code == 302 do
      if tries < 5, do: get_title(resp.headers["Location"], tries + 1), else: nil
    else
      case Regex.run(@title_re, resp.body, capture: :all_but_first) do
        nil -> nil
        title -> "#{title} (#{url})"
      end
    end
  end
end
