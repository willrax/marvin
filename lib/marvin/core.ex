defmodule Marvin.Core do
  use Slack
  require Logger

  @moduledoc """
  The core of Marvin. This module is responsible for interfacing
  with the underlying Slack dependency.
  """

  @doc "Handle and print connection details."
  def handle_message(_message = %{type: "hello"}, slack, state) do
    Logger.info("Connected to #{slack.team.domain} as #{slack.me.name}")
    {:ok, state}
  end

  def handle_message(_message = %{type: "message", subtype: _}, _slack, state), do: {:ok, state}
  def handle_message(message = %{type: "message"}, slack, state) do
    if message.user != slack.me.id do
      cond do
        String.match?(message.text, ~r/#{slack.me.id}/) ->
          scrubbed_message = message |> scrub_indentifier(slack)
          dispatch_message(:direct, scrubbed_message, slack)
        String.match?(message.channel, ~r/^D/) ->
          dispatch_message(:direct, message, slack)
        true ->
          dispatch_message(:ambient, message, slack)
      end
    end

    {:ok, state}
  end

  @doc "Capture and dispatch reaction_<added||removed>"
  def handle_message(message = %{type: "reaction_" <> _type }, slack, state) do
    dispatch_message(:reaction, message, slack)
    {:ok, state}
  end

  def handle_message(_message = %{type: "channel_joined"}, _slack, state), do: {:ok, state}
  def handle_message(_message, _slack, state), do: {:ok, state}

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

  defp dispatch_message(:direct, message, slack) do
    Application.get_env(:marvin, :bots)
    |> Enum.each(fn(bot) ->
      if bot.is_match?({:direct, message.text}), do: start_recipe(bot, message, slack)
    end)
  end

  defp dispatch_message(:ambient, message, slack) do
    Application.get_env(:marvin, :bots)
    |> Enum.each(fn(bot) ->
      if bot.is_match?({:ambient, message.text}), do: start_recipe(bot, message, slack)
    end)
  end

  defp dispatch_message(:reaction, message, slack) do
    Application.get_env(:marvin, :bots)
    |> Enum.each(fn(bot) ->
      if bot.is_match?({:reaction, message.reaction}), do: start_recipe(bot, message, slack)
    end)
  end

  defp start_recipe(bot, message, slack) do
    spawn fn -> bot.handle_message(message, slack) end
  end
end
