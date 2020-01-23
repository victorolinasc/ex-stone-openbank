defmodule ExStoneOpenbank.API.Model.TransferAccount do
  @moduledoc """
  Account model
  """
  use ExStoneOpenbank.Model

  @fields [:account_code]
  @optional [:branch_code, :institution_code]

  embedded_schema do
    field :account_code, :string
    field :branch_code, :string
    field :institution_ispb, :string
    field :institution_name, :string
    field :institution_code, :string
    field :institution_number_code, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
