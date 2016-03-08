defmodule Marvin.Conversation do
  require IEx

  defmacro __using__(_) do
    quote do
      import Slack
      import Marvin.Bot, only: [match: 1]

      import unquote(__MODULE__)

      def handle_entry(_message, _slack, _conversation), do: nil
      def handle_step(_message, _slack, _conversation), do: nil

      defoverridable [handle_step: 3, handle_entry: 3]

      def handle_message(message, slack, conversation = %{step: step}) do
        handle_step({step, conversation}, message, slack)
        |> set_state
      end

      def handle_message(message, slack) do
        conversation = %{user: message.user, bot: __MODULE__}
        handle_entry(message, conversation, slack)
        |> set_state
      end
    end
  end

  defp set_state({:end, conversation}) do
    Marvin.Model.Conversation.complete(conversation)
  end

  defp set_state({step, conversation}) do
    Marvin.Model.Conversation.set_step(step, conversation)
  end
end
