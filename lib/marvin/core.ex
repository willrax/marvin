defmodule Marvin.Core do
  use Slack

  @moduledoc """
  The core of Marvin. This module is responsible for interfacing
  with the underlying Slack dependency.
  """

  def handle_message(_message = %{type: "hello"}, slack, state) do
    IO.puts "Connected to #{slack.team.domain} as #{slack.me.name}"
    {:ok, state}
  end

  def handle_message(_message = %{type: "message", subtype: _}, _slack, state) do
    {:ok, state}
  end

  @doc """
  Receive incoming messages and cast them to each of the running
  bots. These bots are set in the applications configuration file.
  """
  def handle_message(message = %{type: "message"}, slack, state) do
    if message.user != slack.me.id do
      if String.match?(message.text, ~r/#{slack.me.id}/) do
        message
        |> scrub_indentifier(slack)
        |> dispatch_message(slack)
      end

      if String.match?(message.channel, ~r/^D/), do: dispatch_message(message, slack)
    end

    {:ok, state}
  end

  def handle_message(_message = %{type: "channel_joined"}, _slack, state) do
    {:ok, state}
  end

  def handle_message(_message, _slack, state), do: {:ok, state}

  defp dispatch_message(message, slack) do
    Application.get_env(:marvin, :bots)
    |> Enum.each(fn(bot) ->
      if bot.is_match?(message.text), do: bot.handle_event(message, slack)
    end)
  end

  defp scrub_indentifier(message, slack) do
    bot_identifier = "<@#{slack.me.id}>: "
    new_text = remove_prefix(message.text, bot_identifier)
    Map.put(message, :text, new_text)
  end

  defp remove_prefix(full, prefix) do
    base = byte_size(prefix)
    <<_ :: binary-size(base), rest :: binary>> = full
    rest
  end
end
