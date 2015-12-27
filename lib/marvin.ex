defmodule Marvin do
  use Application

  def start(_type, _args) do
    Marvin.Supervisor.start_link
  end
end
