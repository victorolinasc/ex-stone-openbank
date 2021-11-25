defmodule ExStoneOpenbank.API.PixPayment do
  @moduledoc """
  Interacts with Pix payments API for sending money to another entity as seen
  in the documentation: https://docs.openbank.stone.com.br/docs/referencia-da-api/pix/pagamento/
  """

  alias ExStoneOpenbank.{HTTP, Model}
  alias ExStoneOpenbank.API.Model.PixPayment.{ConfirmationInput, CreationInput, CreationResponse}

  @base_url "/pix/outbound_pix_payments"

  @doc """
  Calls the API to create a new transaction, providing the target information, amount and extra details.

  It can be done using complete target information (bank code, branch code, account code and document)
  or by using a Pix key.

  Documentation: https://docs.openbank.stone.com.br/docs/referencia-da-api/pix/pagamento/criar-pagamento-pendente/

  A created transaction must be confirmed using confirm/2.

  ### Examples

    {:ok, %CreationResponse{id: pix_id, end_to_end_id: e2e_id}} =
      ExStoneOpenbank.API.PixPayment.create(:my_application_name, %{
        account_id: "<<account uuid>>",
        amount: 199,
        idempotency_key: "<<key>>",
        key: "your.key.that.can.be.an.email@stone.com.br"
      })

    {:ok, _} =
      ExStoneOpenbank.API.PixPayment.create(:my_application_name, %{
        account_id: "<<account uuid>>",
        amount: 199,
        idempotency_key: "<<key>>",
        target: %{
          institution: %{ispb: "???"},
          account: %{account_code: "???", account_type: "PG"},
          entity: %{name: "???", document: "???"}
        }
      })
  """
  @spec create(config_name :: atom(), input :: map()) ::
          {:ok, CreationResponse.t()} | {:error, atom()}
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

  @doc """
  After a Pix transaction is successfully created using create/2, a id
  is returned as response and it must be used to call confirm.

  Documentation: https://docs.openbank.stone.com.br/docs/referencia-da-api/pix/pagamento/confirmar-pagamento-pendente/

  ### Examples

    {:ok, _} =
      ExStoneOpenbank.API.PixPayment.confirm(:my_application_name, %{
        id: pix_id,
        idempotency_key: "<<key>>"
      })
  """
  @spec confirm(config_name :: atom(), input :: map()) ::
          {:ok, any()} | {:error, atom()}
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
