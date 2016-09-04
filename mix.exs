defmodule Marvin.Mixfile do
  use Mix.Project

  def project do
    [app: :marvin,
     version: "0.3.0",
     elixir: "~> 1.1",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [:logger, :slack, :httpoison],
      mod: {Marvin, []}
    ]
  end

  defp deps do
    [
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, "~> 0.10", only: :dev},
      {:slack, "0.6.0"},
      {:websocket_client, git: "https://github.com/jeremyong/websocket_client"},
      {:ibrowse, "~> 4.2"},
      {:httpotion, "~> 3.0"},
      {:poison, "~> 2.0"}
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
