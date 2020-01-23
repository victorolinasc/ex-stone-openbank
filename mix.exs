defmodule ExStoneOpenbank.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_stone_openbank,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      {:credo, "~> 1.1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:junit_formatter, "~> 3.0", only: :test},
      {:mox, "~> 0.5", only: :test}
    ]
  end

  defp docs do
    [
      main: "ExStoneOpenbank",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        "API Model": ~r/ExStoneOpenbank\.API\.Model*/,
        API: ~r/ExStoneOpenbank\.API.*/,
        Webhooks: ~r/ExStoneOpenbank\.Webhooks.*/,
        Consent: ~r/ExStoneOpenbank\.Consents.*/,
        Authenticator: ~r/ExStoneOpenbank\.Authenticator.*/
      ],
      nest_modules_by_prefix: [
        ExStoneOpenbank.API.Model,
        ExStoneOpenbank.API,
        ExStoneOpenbank.Webhooks,
        ExStoneOpenbank.Consents,
        ExStoneOpenbank.Authenticator
      ]
    ]
  end
end
