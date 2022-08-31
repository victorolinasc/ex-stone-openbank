defmodule ExStoneOpenbank.API.Model.PixResources.DynamicInvoiceInput do
  @moduledoc false

  use ExStoneOpenbank.Model

  @fields [:account_id, :amount, :key, :transaction_id, :idempotency_key]
  @optional [:request_for_payer]

  embedded_schema do
    field :account_id
    field :amount, :integer
    field :key
    field :transaction_id
    field :request_for_payer
    field :idempotency_key
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
