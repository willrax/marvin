defmodule Marvin.BotSupervisor do
  use Supervisor

  def start_link(bots) do
    Supervisor.start_link(__MODULE__, bots, [])
  end

  def init(bots) do
    bots
    |> Enum.map(fn(bot) -> worker(bot, []) end)
    |> supervise(strategy: :one_for_one)
  end
end
