# Marvin

Slack bots using Elixir.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add Marvin to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:marvin, "~> 0.1.0"},
    {:websocket_client, git: "https://github.com/jeremyong/websocket_client"}
  ]
end
```

2. Ensure marvin is started before your application:

```elixir
def application do
  [applications: [:marvin]]
end
```

You'll need to set your bots Slack token in your applications config file.

```elixir
config :marvin, slack_token: "secret"
```

## Creating Bots

Bots are simple to create and can respond to mentions, direct messages and ambient conversation.

```elixir
defmodule EchoBot do
  use Marvin.Bot

  def handle_direct_message(message, slack) do
    send_message(message.text, message.channel, slack)
  end

  def handle_mention(message, slack) do
    send_message(message.text, message.channel, slack)
  end
end
```

Next you'll need to tell Marvin to start your bots by adding them to your config file.

```elixir
config :marvin, bots: [EchoBot]
```
