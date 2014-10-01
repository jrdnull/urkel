defmodule Urkel.Plugin.Title do
  alias Urkel.Irc, as: Irc
  alias Irc.Message, as: Message
  alias Irc.Connection, as: Conn

  require Logger

  @url_re ~r/((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)/
  @title_re ~r/<title>(.*?)<\/title>/is

  # TODO: don't reply to self
  def handle(pid, msg = %Message{command: "PRIVMSG", trailing: text}) do
    case Regex.run(@url_re, text, capture: :first) do
      nil -> nil
      url ->
        Task.start_link fn ->
          case get_title(url) do
            nil ->
              Logger.info("[Title]: Failed to get title of #{url}")
            title ->
              Conn.send(pid, %Message{command: "PRIVMSG", params: [msg |> Irc.get_target], trailing: title})
          end
        end
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
        [title | _] -> "#{title |> String.replace(~r/[\r\n\t]+/, " ")} (#{url})"
      end
    end
  end
end
