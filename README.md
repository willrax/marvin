# Marvin

Slack bots using Elixir.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add Marvin to your list of dependencies in `mix.exs`:

        def deps do
          [{:marvin, "~> 0.1.0"}]
        end

  2. Ensure marvin is started before your application:

        def application do
          [applications: [:marvin]]
        end
