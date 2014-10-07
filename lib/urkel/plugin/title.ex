defmodule Urkel.Plugin.Title do
  use Urkel.Plugin.Mixin

  @url_re ~r/((https?:\/\/)?[\w-]+(\.[\w-]+)+(:\d+)?(\/\S*)?)/
  @title_re ~r/<title>(.*?)<\/title>/is

  def init(_), do: :nothing

  def handle(pid, msg = %Message{command: "PRIVMSG", trailing: text}) do
    if url = text |> extract_url, do: Task.start_link fn ->
      if title = url |> get_title do
        privmsg(pid, msg |> Irc.get_target, title)
      else
        Logger.info("[Title]: Failed to get title of #{url}")
      end
    end
  end

  def handle(_, _), do: :nothing

  defp extract_url(text), do: Regex.run(@url_re, text, capture: :first)

  defp get_title(url), do: get_title(url, 0)
  defp get_title(url, tries) do
    resp = HTTPoison.get(url)
    if resp.status_code == 301 || resp.status_code == 302 do
      if tries < 5, do: get_title(resp.headers["Location"], tries + 1), else: nil
    else
      case Regex.run(@title_re, resp.body, capture: :all_but_first) do
        nil -> nil
        [title | _] ->
          "#{title |> String.replace(~r/[\r\n]+/, " ") |> String.strip} (#{url})"
      end
    end
  end
end
