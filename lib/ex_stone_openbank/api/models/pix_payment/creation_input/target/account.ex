defmodule ExStoneOpenbank.API.Model.PixPayment.CreationInput.Target.Account do
  @moduledoc """
  Account model
  """
  use ExStoneOpenbank.Model

  @fields [:account_code]
  @optional [:branch_code, :account_type]

  embedded_schema do
    field :account_code
    field :branch_code
    field :account_type
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
