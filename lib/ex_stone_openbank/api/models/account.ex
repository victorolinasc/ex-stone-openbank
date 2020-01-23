defmodule ExStoneOpenbank.API.Model.Account do
  @moduledoc """
  An account representation
  """
  use ExStoneOpenbank.Model

  @fields [
    :account_code,
    :branch_code,
    :institution,
    :institution_name
  ]

  embedded_schema do
    field :account_code, :string
    field :branch_code, :string
    field :institution, :string
    field :institution_name, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
