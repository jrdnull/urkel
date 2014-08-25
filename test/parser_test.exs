defmodule ParserTest do
  use ExUnit.Case

  alias Urkel.Irc.Parser, as: Parser
  alias Urkel.Irc.Prefix, as: Prefix
  alias Urkel.Irc.Message, as: Message

  test "PRIVMSG" do
    raw = ":Angel!wings@irc.org PRIVMSG Wiz :Are you receiving this message ?\r\n"
    msg =  %Message{prefix: %Prefix{nick: "Angel", user: "wings", host: "irc.org"},
                    command: "PRIVMSG",
                    params: ["Wiz"],
                    trailing: "Are you receiving this message ?"}

    assert msg == Parser.parse(raw)
  end

  test "PING" do
    raw = "PING :irc.funet.fi"
    msg = %Message{command: "PING", trailing: "irc.funet.fi"}

    assert msg == Parser.parse(raw)
  end

  test "SQUIT" do
    raw = ":Trillian SQUIT cm22.eng.umd.edu :Server out of control"
    msg = %Message{prefix: %Prefix{host: "Trillian"},
                    command: "SQUIT",
                    params: ["cm22.eng.umd.edu"],
                    trailing: "Server out of control"}

    assert msg == Parser.parse(raw)
  end

  test "PASS" do
    raw = "PASS secretpasswordhere"
    msg = %Message{command: "PASS", params: ["secretpasswordhere"]}

    assert msg == Parser.parse(raw)
  end

  test "to_string" do
    raw = "PRIVMSG #elixir-lang :Hello, #elixir-lang!\r\n"
    msg = %Message{command: "PRIVMSG",
                   params: ["#elixir-lang"],
                   trailing: "Hello, #elixir-lang!"}

    assert raw == Parser.to_string(msg)
  end
end
