defmodule ExStoneOpenbank.API.Model.PixResources.DynamicInvoiceResponse do
  @moduledoc false

  use ExStoneOpenbank.Model

  @fields [:id, :transaction_id, :qr_code_content, :qr_code_image]
  @optional []

  embedded_schema do
    field :id
    field :transaction_id
    field :qr_code_content
    field :qr_code_image
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
