defmodule ExStoneOpenbank.API.Model.DryRunBarcodePaymentInput do
  @moduledoc """
  Dry Run input for a barcode payment.
  """
  use ExStoneOpenbank.Model

  @fields [:barcode, :account_id]

  embedded_schema do
    field :barcode, :string
    field :account_id, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
