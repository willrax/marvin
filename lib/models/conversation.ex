defmodule Marvin.Storage.Conversation do
  import String, only: [to_atom: 1]

  def complete(_conversation = %{user: user}) do
    ConCache.delete(:conversations, to_atom(user))
  end

  def exists?(message = %{user: user}) do
    ConCache.get(:conversations, to_atom(user)) != nil
  end

  def get(message = %{user: user}) do
    ConCache.get(:conversations, to_atom(user))
  end

  def set_step(step, conversation = %{user: user}) do
    conversation = Map.update(conversation, :step, step, &(&1 * step))

    ConCache.update(:conversations, to_atom(user), fn(_) ->
      {:ok, conversation}
    end)
  end
end
