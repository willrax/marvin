defmodule Marvin.Bot do
  @moduledoc """
    Bot is a module designed to be used in the bots built with Marvin.

    When you use this module you can make your bot respond to
    different types of messages from your Slack account.

    ## Example

    ```
    defmodule EchoBot do
      use Marvin.Bot

      match {:direct, ~r/^hello/}

      def handle_message(message, slack) do
        send_message(message.text, message.channel, slack)
      end
    end
    ```

    In this example the bot is listening for mentions that include
    the phrase "hello" (@yourbot / yourbot) and  and for direct
    messages. It then takes the text from the received message and
    sending it back to the channel it came in from.
  """

  defmacro __using__(_) do
    quote do
      import Slack

      import unquote(__MODULE__)

      def handle_message(_message, _slack), do: nil
      def match({_type, _pattern}), do: {:direct, ~r//}

      defoverridable [handle_message: 2, match: 1]
    end
  end

  def send_attachment(attachments, channel, slack) do
    body = [attachments: JSX.encode!(attachments), channel: channel]
    Marvin.WebAPI.api("/chat.postMessage", body)
  end

  defmacro match({type, message}) when is_bitstring(message)  do
    quote do
      def is_match?({incoming_type, incoming_message}) do
        unquote(type) == incoming_type && unquote(message) == incoming_message
      end

      def is_match?(_), do: false
    end
  end

  defmacro match(match_pair) when is_tuple(match_pair)  do
    quote do
      def is_match?({incoming_type, incoming_message}) do
        {type, pattern} = unquote(match_pair)
        type == incoming_type && String.match?(incoming_message, pattern)
      end

      def is_match?(_), do: false
    end
  end
end
