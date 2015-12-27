defmodule Marvin.Bot do
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
        handle_direct_message(message, slack)
      end

      def dispatch_message(message, slack) do
        me = slack.me.id

        if String.match?(message.text, ~r/#{me}/) do
          handle_mention(message, slack)
        else
          handle_message(message, slack)
        end
      end

      def handle_message(_message, _slack), do: nil
      def handle_mention(_message, _slack), do: nil
      def handle_direct_message(_message, _slack), do: nil

      defoverridable [
        handle_direct_message: 2,
        handle_message: 2,
        handle_mention: 2
      ]
    end
  end
end
