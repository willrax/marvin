defmodule Marvin.Core do
  use Slack

  def handle_message(message = %{type: "hello"}, slack, state) do
    IO.puts "Connected to #{slack.team.domain} as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    Enum.each([EchoBot], fn(bot) ->
      bot.handle_event(message, slack)
    end)

    {:ok, state}
  end

  def handle_message(message, _slack, state), do: {:ok, state}
end
