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

  @spec add_perm(String.t(), String.t(), String.t()) :: :ok | {:error, term}
  def add_perm(app_key, perm_key, resource) do
    res = %{resource => "*"}
    data = %{"permissions" => res}

    case JSON.encode(data) do
      {:ok, body} ->
        IO.puts(body)

        response =
          :httpc.request(
            :patch,
            {'https://rest.gadventures.com/application_keys/#{app_key}',
             [{'X-Application-Key', to_charlist(perm_key)}], 'application/json',
             to_charlist(body)},
            [],
            []
          )

        case response do
          {:ok, {{'HTTP/1.1', 200, _}, _headers, _body}} ->
            :ok

          {:ok, {{'HTTP/1.1', code, err}, _headers, _body}} ->
            fjoin = fn lst -> Enum.join(lst, " ") end
            {:error, Enum.map(["#{resource} => HTTP/1.1", code, err], &to_string/1) |> fjoin.()}

          {:error, {a, b}} ->
            {:error, Enum.join(["Error #{resource}:", to_string(a), to_string(b)], " ")}

          _ ->
            {:error, "utter and unknown fail for #{resource}"}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec all_resources() :: list(String.t())
  def all_resources() do
    [
      "accommodation_costs",
      "accommodation_dossiers",
      "accommodation_services",
      "accommodations",
      "activities",
      "activity_dossiers",
      "activity_services",
      "advertised_departures",
      "agencies",
      "agency_chains",
      "agents",
      "airports",
      "applications",
      "application_keys",
      "band_costs",
      "best_prices",
      "booking_companies",
      "bookings",
      "bookings_meta",
      "calls",
      "campaigns",
      "case_statuses",
      "case_types",
      "cases",
      "ceo_profiles",
      "checkins",
      "completed_agreements",
      "continents",
      "cost_centres",
      "countries",
      "country_dossiers",
      "customers",
      "customers_bundle",
      "declined_reasons",
      "departure_components",
      "departures",
      "departure_services",
      "departures_meta",
      "documents",
      "donations",
      "dossier_features",
      "dossiers",
      "dossier_segments",
      "evaluations",
      "extras",
      "feature_categories",
      "features",
      "fee_services",
      "fixed_costs",
      "flight_alerts",
      "flight_segments",
      "flight_services",
      "flight_service_segments",
      "flight_statuses",
      "gt_calls",
      "gt_clients",
      "image_bundles",
      "images",
      "incident_reports",
      "index",
      "insurance_services",
      "invoices",
      "itineraries",
      "itinerary_highlights",
      "itinerary_maps",
      "itinerary_media",
      "job_openings",
      "languages",
      "merchandise",
      "merchandise_services",
      "messages",
      "multishare_costs",
      "namelists",
      "namelists_bundle",
      "nationalities",
      "online_accounts",
      "operational_cases",
      "override_reasons",
      "overrides",
      "packing_items",
      "packing_lists",
      "password_resets/profiles",
      "payments",
      "permission",
      "permissions",
      "per_person_costs",
      "per_person_variable_costs",
      "place_dossiers",
      "places",
      "positions",
      "profile_activities",
      "profiles",
      "profiles_bundle",
      "promotions",
      "quick_quotes",
      "readiness_surveys",
      "reporting_offices",
      "refunds",
      "requirements",
      "requirement_sets",
      "resource",
      "rooming_lists",
      "rooming_requests",
      "service_levels",
      "services",
      "siglos_codes",
      "single_supplements",
      "single_supplement_services",
      "staff_profiles",
      "states",
      "stripe_charges",
      "surveys",
      "transport_leg_dossiers",
      "supplemental_dossiers",
      "suppliers",
      "timezones",
      "tour_categories",
      "tour_dossiers",
      "tours",
      "transport_dossiers",
      "transports",
      "transport_services",
      "validated_services",
      "videos",
      "visas",
      "vouchers",
      "worker_compensations",
      "workers"
    ]
  end
end
