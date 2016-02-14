defmodule Marvin.Core do
  use Slack

  @moduledoc """
  The core of Marvin. This module is responsible for interfacing
  with the underlying Slack dependency.
  """

  @doc "Handle and print connection details."
  def handle_message(_message = %{type: "hello"}, slack, state) do
    IO.puts "Connected to #{slack.team.domain} as #{slack.me.name}."
    {:ok, state}
  end

  @doc "Handle all message subtypes."
  def handle_message(_message = %{type: "message", subtype: _}, _slack, state) do
    {:ok, state}
  end

  @doc """
  Handle a normal message. Decide whether it's a
  direct or mention type message.
  """
  def handle_message(message = %{type: "message"}, slack, state) do
    if message.user != slack.me.id do
      if String.match?(message.text, ~r/#{slack.me.id}/) do
        scrubbed_message = message |> scrub_indentifier(slack)
        dispatch_message(:direct, scrubbed_message, slack)
      end

      if String.match?(message.channel, ~r/^D/), do: dispatch_message(:direct, message, slack)
    end

    {:ok, state}
  end

  @doc "Handle channel joined message."
  def handle_message(_message = %{type: "channel_joined"}, _slack, state) do
    {:ok, state}
  end

  @doc "Capture and dispatch reaction_<added||removed>"
  def handle_message(message = %{type: "reaction_" <> _type }, slack, state) do
    dispatch_message(:reaction, message, slack)
    {:ok, state}
  end

  @doc "Handle any uncaptured messages."
  def handle_message(_message, _slack, state), do: {:ok, state}

  defp dispatch_message(:direct, message, slack) do
    Application.get_env(:marvin, :bots)
    |> Enum.each(fn(bot) ->
      if bot.is_match?({:direct, message.text}), do: bot.handle_event(message, slack)
    end)
  end

  defp dispatch_message(:reaction, message, slack) do
    Application.get_env(:marvin, :bots)
    |> Enum.each(fn(bot) ->
      if bot.is_match?(:reaction), do: bot.handle_event(message, slack)
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
