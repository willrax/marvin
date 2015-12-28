defmodule Marvin.Bot do
  @moduledoc """
    Bot is a module designed to be used in the bots built with Marvin.

    When you use this module you can make your bot respond to
    different types of messages from your Slack account.

    ## Example

    ```
    defmodule EchoBot do
      use Marvin.Bot

      def handle_direct(message, slack) do
        send_message(message.text, message.channel, slack)
      end

      def handle_mention(message, slack) do
        send_message(message.text, message.channel, slack)
      end
    end
    ```

    In this example the bot is listening for mentions (@yourbot
    / yourbot) and  and for direct messages. It then takes the text
    from the received message and sending it back to the channel it
    came in from.
  """

  defmacro __using__(_) do
    quote do
      use GenServer
      import Slack

      def start_link() do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
      end

      def handle_event(message, slack) do
        GenServer.cast(__MODULE__, {:handle_event, {message, slack}})
      end

      def handle_cast({:handle_event, {message, slack}}, state) do
        dispatch_message(message, slack)
        {:noreply, state}
      end

      def dispatch_message(message = %{channel: "D" <> code}, slack) do
        handle_direct(message, slack)
      end

      def dispatch_message(message, slack) do
        me = slack.me.id

        if String.match?(message.text, ~r/#{me}/) do
          handle_mention(message, slack)
        else
          handle_ambient(message, slack)
        end
      end

      def handle_direct(_message, _slack), do: nil
      def handle_ambient(_message, _slack), do: nil
      def handle_mention(_message, _slack), do: nil

      defoverridable [handle_ambient: 2,
        handle_direct: 2,
        handle_mention: 2]
    end
  end
end
