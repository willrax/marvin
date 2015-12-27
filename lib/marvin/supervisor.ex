defmodule Marvin.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    bots = Application.get_env(:marvin, :bots)
    token = Application.get_env(:marvin, :slack_token)

    children = [
      worker(Marvin.Core, [token, []]),
      worker(Marvin.BotSupervisor, [bots])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
