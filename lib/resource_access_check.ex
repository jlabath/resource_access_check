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

        case length(lacks) do
          0 ->
            :ok

          _ ->
            case IO.gets("Would you like to try to add the lacking entries y/n? ") do
              :eof ->
                IO.puts("EOF!?")

              {:error, reason} ->
                IO.puts(["Error reading stdin ", to_string(reason)])

              chr ->
                case chr do
                  "y\n" ->
                    add_perms_json(lacks) |> IO.puts()

                  _ ->
                    IO.puts("OK")
                end
            end
        end

      {:error, reason} ->
        IO.puts(["Failure: ", reason])
    end
  end

  @spec second_list_lacks(list(String.t()), list(String.t())) :: list(String.t())
  def second_list_lacks(total_list, inspect_list) do
    Enum.filter(total_list, fn x -> not Enum.member?(inspect_list, x) end)
  end

  @spec add_perms_json(list(String.t())) :: String.t()
  def add_perms_json(resources) do
    Enum.map(resources, fn x -> "\"#{x}\":\"*\"" end) |> (&Enum.join(&1, ",")).()
  end

  @spec add_perms(list(String.t()), String.t()) :: :ok | {:error, term()}
  def add_perms(resources, app_key) do
    case IO.gets("Enter the key to use to add permissions: ") do
      :eof ->
        {:error, :eof}

      {:error, reason} ->
        {:error, reason}

      perm_key ->
        trouble_list =
          Enum.map(resources, &add_perm_prompt(app_key, String.trim(perm_key), &1))
          |> (&Enum.filter(&1, fn n -> n != :ok end)).()
          |> (fn lst -> Enum.map(lst, &inspect/1) end).()

        if length(trouble_list) > 0 do
          {:error, Enum.join(trouble_list, " ")}
        else
          :ok
        end
    end
  end

  @spec add_perm_prompt(String.t(), String.t(), String.t()) :: :ok | {:error, term}
  def add_perm_prompt(app_key, perm_key, resource) do
    case IO.gets("Add access to #{resource} y/n? ") do
      :eof ->
        IO.puts("EOF!?")

      {:error, reason} ->
        IO.puts(["Error reading stdin ", to_string(reason)])

      chr ->
        case chr do
          "y\n" ->
            IO.puts("Adding #{resource}")
            GAPI.add_perm(app_key, perm_key, resource)

          _ ->
            IO.puts("Skiping #{resource}")
        end
    end
  end
end
