defmodule ExStoneOpenbank.API.Model.PixPayment.CreationInput.Target.Institution do
  @moduledoc false

  use ExStoneOpenbank.Model

  @fields []
  @optional [:ispb]

  embedded_schema do
    field :ispb
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
