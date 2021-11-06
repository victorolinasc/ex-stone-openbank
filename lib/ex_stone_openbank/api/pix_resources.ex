defmodule ExStoneOpenbank.API.PixResources do
  @moduledoc """
  Defines methods for handling pix resources such as key handling
  and invoice generation.
  """

  alias ExStoneOpenbank.{HTTP, Model}
  alias ExStoneOpenbank.API.Model.PixResources.{DynamicInvoiceInput, DynamicInvoiceResponse}

  @base_url "/pix_payment_invoices"

  @doc """
  Generates an invoice and its QR code according to the documentation:
  https://docs.openbank.stone.com.br/docs/referencia-da-api/pix/recebimento/criar-qrcode-dinamico/

  ### Examples

    {:ok, %{qr_code_content: content_for_copy_and_paste, qr_code_image: b64_encoded_image}} =
      ExStoneOpenbank.API.PixResources.dynamic_invoice(:my_application_name, %{
        account_id: "<<account uuid>>",
        amount: 1,
        key: "your.key.that.can.be.an.email@stone.com.br",
        transaction_id: <<generated transaction id>>,
        idempotency_key: "<<key>>"
      })
  """
  def dynamic_invoice(config_name, input) do
    case DynamicInvoiceInput.cast_and_apply(input) do
      %DynamicInvoiceInput{} = input ->
        body = Model.to_map(input)

        HTTP.post(
          config_name,
          @base_url,
          body,
          [headers: [{"x-stone-idempotency-key", input.idempotency_key}]],
          model: DynamicInvoiceResponse
        )

      err ->
        err
    end
  end
end
