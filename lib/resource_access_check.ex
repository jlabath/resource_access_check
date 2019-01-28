defmodule ResourceAccessCheck do
  @moduledoc """
  Documentation for ResourceAccessCheck.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ResourceAccessCheck.hello()
      :world

  """
  def hello do
    :world
  end

  def main(args) do
    case length(args) do
      1 ->
        do_stuff(hd(args))

      _ ->
        IO.puts("requires one argument: application key")
    end
  end

  @spec do_stuff(String.t()) :: :ok
  defp do_stuff(app_key) do
    IO.puts(["Checking GAPI with", " ", app_key])

    case GAPI.resources(app_key) do
      {:ok, resources} ->
        Enum.join(resources, "\n") |> IO.puts()

      {:error, reason} ->
        IO.puts(["Failure: ", reason])
    end
  end
end
