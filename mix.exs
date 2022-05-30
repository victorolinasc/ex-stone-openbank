defmodule ExStoneOpenbank.MixProject do
  use Mix.Project

  @version "0.1.2"
  @description "Stone Openbank APIs Elixir SDK"
  @github_link "https://github.com/victorolinasc/ex-stone-openbank"

  def project do
    [
      app: :ex_stone_openbank,
      name: "ExStoneOpenbank",
      version: @version,
      description: @description,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      source_url: @github_link,
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application, do: [extra_applications: [:logger]]

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
      {:ecto, "~> 3.4"},
      {:telemetry, "~> 0.4"},

      # Test, dev only deps
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:junit_formatter, "~> 3.0", only: :test},
      {:mox, "~> 0.5", only: :test},
      {:excoveralls, "~> 0.12", only: :test}
    ]
  end

  defp docs do
    [
      main: "ExStoneOpenbank",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @github_link,
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

  defp package do
    [
      maintainers: ["Victor Oliveira Nascimento"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_link}
    ]
  end
end
