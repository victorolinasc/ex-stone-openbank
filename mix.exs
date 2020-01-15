defmodule ExStoneOpenbank.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_stone_openbank,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:brcpfcnpj, "~> 0.2"},
      {:jason, "~> 1.1"},
      {:tesla, "~> 1.3"},
      {:hackney, "~> 1.15"},
      {:joken, "~> 2.2"},
      {:joken_jwks, "~> 1.1"},
      {:ecto, "~> 3.3.0"},
      {:telemetry, "~> 0.4"},

      # Test, dev only deps
      {:credo, "~> 1.1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
