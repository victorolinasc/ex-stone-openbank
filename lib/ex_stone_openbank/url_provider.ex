defmodule ExStoneOpenbank.URLProvider do
  @moduledoc """
  URL provider for different environments
  """

  @type t :: %__MODULE__{
          accounts_url: String.t(),
          api_url: String.t(),
          conta_url: String.t()
        }
  @enforce_keys [:accounts_url, :api_url, :conta_url]
  defstruct [:accounts_url, :api_url, :conta_url]

  @spec build(environment :: atom(), params :: keyword()) :: __MODULE__.t()
  def build(environment, params \\ [])

  def build(:sandbox, _params) do
    do_build(
      accounts_url: "https://sandbox-accounts.openbank.stone.com.br",
      api_url: "https://sandbox-api.openbank.stone.com.br",
      conta_url: "https://sandbox.conta.stone.com.br"
    )
  end

  def build(:production, _params) do
    do_build(
      accounts_url: "https://accounts.openbank.stone.com.br",
      api_url: "https://api.openbank.stone.com.br",
      conta_url: "https://conta.stone.com.br"
    )
  end

  def build(_env, params), do: do_build(params)

  defp do_build(params) when is_list(params) do
    %__MODULE__{
      accounts_url: fetch_url(params, :accounts_url),
      api_url: fetch_url(params, :api_url),
      conta_url: fetch_url(params, :conta_url)
    }
  end

  defp fetch_url(params, url) do
    params
    |> Keyword.fetch!(url)
    |> URI.parse()
    |> URI.to_string()
  end
end
