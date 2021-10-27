defmodule ExStoneOpenbank.API.PixPayment do
  @moduledoc """
  """
  alias ExStoneOpenbank.API.Model.PixPayment.{CreationInput, CreationResponse, ConfirmationInput}
  alias ExStoneOpenbank.{HTTP, Model}

  @base_url "/pix/outbound_pix_payments"

  def create(config_name, input) do
    case CreationInput.cast_and_apply(input) do
      %CreationInput{} = input ->
        body = Model.to_map(input)

        HTTP.post(
          config_name,
          @base_url,
          body,
          [headers: [{"x-stone-idempotency-key", input.idempotency_key}]],
          model: CreationResponse
        )

      err ->
        err
    end
  end

  def confirm(config_name, input) do
    case ConfirmationInput.cast_and_apply(input) do
      %ConfirmationInput{} = input ->
        HTTP.post(
          config_name,
          "#{@base_url}/#{input.id}/actions/confirm",
          "",
          headers: [{"x-stone-idempotency-key", input.idempotency_key}]
        )

      err ->
        err
    end
  end
end
