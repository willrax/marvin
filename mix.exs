defmodule Marvin.Mixfile do
  use Mix.Project

  def project do
    [app: :marvin,
     version: "0.1.1",
     elixir: "~> 1.1",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:logger, :slack],
      mod: {Marvin, []}
    ]
  end

  defp deps do
    [
      {:slack, "0.3.0"},
      {:websocket_client, git: "https://github.com/jeremyong/websocket_client"}
    ]
  end

  defp description do
    """
    A Slack bot framework.
    """
  end

  defp package do
    [maintainers: ["Will Raxworthy"],
      licenses: ["MIT"],
      links: %{"GitHub": "https://github.com/willrax/marvin"}]
  end
end
