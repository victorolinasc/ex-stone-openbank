defmodule ExStoneOpenbank.API.Model.Statement.CounterParty.Entity do
  @moduledoc """
  A legal entity that can be either a user or an organization.
  """
  use ExStoneOpenbank.Model

  @fields [:name]

  embedded_schema do
    field :name, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
