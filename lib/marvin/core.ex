defmodule Marvin.Core do
  use Slack

  @moduledoc """
  The core of Marvin. This module is responsible for interfacing
  with the underlying Slack dependency.
  """

  def handle_message(message = %{type: "hello"}, slack, state) do
    IO.puts "Connected to #{slack.team.domain} as #{slack.me.name}"
    {:ok, state}
  end

  @doc """
  Receive incoming messages and cast them to each of the running
  bots. These bots are set in the applications configuration file.
  """
  def handle_message(message = %{type: "message"}, slack, state) do
    bots = Application.get_env(:marvin, :bots)

    Enum.each(bots, fn(bot) ->
      bot.handle_event(message, slack)
    end)

    {:ok, state}
  end

  def handle_message(message, _slack, state), do: {:ok, state}
end
