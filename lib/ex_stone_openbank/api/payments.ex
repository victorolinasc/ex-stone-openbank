defmodule ExStoneOpenbank.API.Payments do
  @moduledoc """
  Payments calls
  """
  alias ExStoneOpenbank.API.Model.{
    BarcodePaymentInput,
    BarcodePaymentResponse,
    DryRunBarcodePaymentInput
  }

  alias ExStoneOpenbank.{HTTP, Model}

  @doc """
  Dry run the payment of a barcode.

  This is needed in order to understand the details of the payment and show it up front to users.
  """
  def dry_run_pay_barcode(config_name, input) do
    case DryRunBarcodePaymentInput.cast_and_apply(input) do
      %DryRunBarcodePaymentInput{} = input ->
        body = Model.to_map(input)
        HTTP.post(config_name, "/dry_run/payments", body, [], model: BarcodePaymentResponse)

      err ->
        err
    end
  end

  @doc """
  Pay a barcode.
  """
  def pay_barcode(config_name, input) do
    case BarcodePaymentInput.cast_and_apply(input) do
      %BarcodePaymentInput{} = input ->
        body = Model.to_map(input)
        HTTP.post(config_name, "/payments", body, [], model: BarcodePaymentResponse)

      err ->
        err
    end
  end
end
