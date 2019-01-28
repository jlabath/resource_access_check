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
        additional = second_list_lacks(resources, GAPI.all_resources())

        Enum.join(additional, "\n")
        |> (&["The key has these additional resources\n", &1]).()
        |> IO.puts()

        lacks = second_list_lacks(GAPI.all_resources(), resources)

        Enum.join(lacks, "\n")
        |> (&["The key lacks these resources\n", &1]).()
        |> IO.puts()

      {:error, reason} ->
        IO.puts(["Failure: ", reason])
    end
  end

  @spec second_list_lacks(list(String.t()), list(String.t())) :: list(String.t())
  def second_list_lacks(total_list, inspect_list) do
    Enum.filter(total_list, fn x -> not Enum.member?(inspect_list, x) end)
  end
end
