defmodule ExStoneOpenbank.Model do
  @moduledoc """
  Base model
  """

  @iso8601_structs [
    Date,
    DateTime,
    NaiveDateTime,
    Time
  ]

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import ExStoneOpenbank.Model
      @primary_key false

      @type t :: %__MODULE__{}

      def cast_and_apply(params) do
        cast_and_apply(__MODULE__, params)
      end
    end
  end

  @doc """
  Casts and validates model.
  """
  def cast_and_apply(model, params) do
    params
    |> model.changeset()
    |> case do
      %{valid?: true} = cs ->
        Ecto.Changeset.apply_changes(cs)

      changeset ->
        {:errors, IO.inspect(changeset).errors}
    end
  end

  @doc """
  Transforms a struct and its inner fields to atom-maps
  """
  @spec to_map(instance :: map, key_type :: :string_keys | :atom_keys) :: map
  def to_map(instance, key_type \\ :atom_keys) do
    instance
    |> Map.drop([:__struct__, :__meta__])
    |> Map.new(fn
      {key, value} -> {cast_key(key, key_type), do_cast_to_map(value, key_type)}
    end)
  end

  defp do_cast_to_map(%schema{} = struct, key_type) do
    case schema do
      schema when schema in @iso8601_structs ->
        struct

      _ ->
        struct
        |> Map.from_struct()
        |> do_cast_to_map(key_type)
    end
  end

  defp do_cast_to_map(map, key_type) when is_map(map) do
    map
    |> Map.drop([:__meta__])
    |> Map.to_list()
    |> Enum.map(fn
      {k, v} -> {cast_key(k, key_type), do_cast_to_map(v, key_type)}
    end)
    |> Enum.into(%{})
  end

  defp do_cast_to_map(list, key_type) when is_list(list) do
    Enum.map(list, fn
      {k, v} -> {cast_key(k, key_type), do_cast_to_map(v, key_type)}
      v -> do_cast_to_map(v, key_type)
    end)
  end

  defp do_cast_to_map(value, _key_type), do: value

  defp cast_key(key, :atom_keys), do: to_atom(key)
  defp cast_key(key, :string_keys), do: to_string(key)

  defp to_atom(v) when is_atom(v), do: v
  defp to_atom(v), do: String.to_atom(v)
end
