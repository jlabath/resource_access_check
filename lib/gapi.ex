defmodule GAPI do
  @spec resources(String.t()) :: {:ok, list(String.t())} | {:error, String.t()}
  def resources(key) do
    response =
      :httpc.request(
        :get,
        {'https://rest.gadventures.com', [{'X-Application-Key', to_charlist(key)}]},
        [],
        []
      )

    case response do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ->
        {status, something} = JSON.decode(body)

        case status do
          :ok ->
            case extract_resources(something) do
              {:ok, res_list} ->
                {:ok, res_list}

              {:error, reason} ->
                {:error, reason}
            end

          :error ->
            {:error, to_string(something)}
            IO.puts("json decoding went bad")
            []
        end

      {:ok, {{'HTTP/1.1', code, err}, _headers, _body}} ->
        fjoin = fn lst -> Enum.join(lst, " ") end
        {:error, Enum.map(["HTTP/1.1", code, err], &to_string/1) |> fjoin.()}

      {:error, {a, b}} ->
        {:error, Enum.join([to_string(a), to_string(b)], " ")}

      _ ->
        {:error, "utter and unknown fail"}
    end
  end

  @spec extract_resources(map()) :: {:ok, list(String.t())} | {:error, String.t()}
  defp extract_resources(root_dict) do
    if Map.has_key?(root_dict, "available_resources") do
      ares = root_dict["available_resources"]

      case convert_resources(ares) do
        {:ok, lst} ->
          {:ok, lst}

        {:error, r} ->
          {:error, r}
      end
    else
      {:error, "no such key available_resources"}
    end
  end

  @spec convert_resources(list(map())) :: {:ok, list(String.t())} | {:error, String.t()}
  defp convert_resources(lst) do
    if Enum.all?(lst, fn x -> Map.has_key?(x, "resource") end) do
      {:ok, for(n <- lst, do: n["resource"])}
    else
      {:error, "some objects lacked resource attribute"}
    end
  end
end
