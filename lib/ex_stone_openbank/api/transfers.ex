defmodule ExStoneOpenbank.API.Transfers do
  @moduledoc """
  Transfers operations.
  """
  alias ExStoneOpenbank.API.Model.{TransferInput, TransferResponse}
  alias ExStoneOpenbank.{HTTP, Model}

  @doc """
  Dry run a transfer.

  This is needed in order to understand the details of the payment and show it up front to users.
  """
  @spec dry_run_transfer(config_name :: atom(), input :: map()) ::
          {:ok, TransferResponse.t()} | {:error, reason :: atom()}
  def dry_run_transfer(config_name, input), do: perform(config_name, input, true)

  @doc """
  Make transfer
  """
  @spec transfer(config_name :: atom(), input :: map()) ::
          {:ok, TransferResponse.t()} | {:error, reason :: atom()}
  def transfer(config_name, input), do: perform(config_name, input, false)

  defp perform(config_name, input, dry_run?) do
    case TransferInput.cast_and_apply(input) do
      %TransferInput{} = input ->
        body = Model.to_map(input)
        url = if dry_run?, do: "/dry_run/#{input.type}s", else: "/#{input.type}s"
        HTTP.post(config_name, url, body, [], model: TransferResponse)

      err ->
        err
    end
  end
end
