defmodule ExStoneOpenbank.API.Model.BarcodePaymentInput do
  @moduledoc """
  Input for a barcode payment.
  """
  use ExStoneOpenbank.Model

  @fields [:barcode, :account_id]

  @optional [:scheduled_to]

  embedded_schema do
    field :barcode, :string
    field :account_id, :string
    field :scheduled_to, :naive_datetime
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
