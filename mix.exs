defmodule HMACDaddy.Mixfile do
  use Mix.Project

  def project do
    [
      app: :hmac_daddy,
      version: "0.0.1",
      elixir: "~> 1.1",
      description: description,
      package: package,
      deps: deps
    ]
  end

  def application do
    [applications: [:logger]]
  end

  def description do
    """
    A plug to validate and parse HMAC-signed JSON
    """
  end

  defp package do
    [
      files:      ~w[ lib README.md mix.exs LICENSE ],
      contributors: ["Solomon White"],
      licenses:     ["The MIT License (MIT)"],
      links: %{
        "GitHub" => "https://github.com/rubysolo/hmac_daddy",
        "Docs"   => "http://hexdocs.pm/hmac_daddy/"
      }
    ]
  end

  defp deps do
    [
      {:plug, "> 0.8.0"}
    ]
  end
end
