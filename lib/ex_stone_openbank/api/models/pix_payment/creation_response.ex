defmodule ExStoneOpenbank.API.Model.PixPayment.CreationResponse do
  @moduledoc false

  use ExStoneOpenbank.Model

  @fields [:id, :end_to_end_id, :fee, :fee_metadata, :status]
  @optional []

  embedded_schema do
    field :id, Ecto.UUID
    field :end_to_end_id
    field :fee, :integer
    field :fee_metadata, :map
    field :status
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
