defmodule ExStoneOpenbank.API.Model.PixPayment.CreationInput.Target.Entity do
  @moduledoc """
  Account model
  """
  use ExStoneOpenbank.Model

  @fields [:name, :document]
  @optional []

  embedded_schema do
    field :name
    field :document
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
