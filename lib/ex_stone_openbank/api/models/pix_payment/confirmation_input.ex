defmodule ExStoneOpenbank.API.Model.PixPayment.ConfirmationInput do
  @moduledoc false

  use ExStoneOpenbank.Model

  @fields [:id, :idempotency_key]
  @optional []

  embedded_schema do
    field :id
    field :idempotency_key
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
