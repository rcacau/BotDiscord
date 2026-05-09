defmodule MeuBot.Commands do
  @moduledoc false

  alias MeuBot.Store

  def ping do
    case HTTPoison.get("https://httpbin.org/status/200") do
      {:ok, %{status_code: 200}} -> "Pong!"
      _ -> "Pong! (API de status indisponivel no momento)"
    end
  end

  def clima(city) do
    with {:ok, geo} <- geocode_city(city),
         {:ok, weather} <- fetch_weather(geo["latitude"], geo["longitude"]) do
      temp = weather["current"]["temperature_2m"]
      wind = weather["current"]["wind_speed_10m"]
      "Clima em #{geo["name"]}: #{temp}C, vento #{wind} km/h."
    else
      {:error, :city_not_found} -> "Nao encontrei essa cidade. Tente outro nome."
      _ -> "Nao consegui consultar o clima agora. Tente novamente mais tarde."
    end
  end

  def cep(cep) do
    clean = cep |> String.replace(~r/\D/, "")

    if String.length(clean) != 8 do
      "CEP invalido. Use 8 digitos, ex: `!cep 01001000`."
    else
      case HTTPoison.get("https://viacep.com.br/ws/#{clean}/json/") do
        {:ok, %{status_code: 200, body: body}} ->
          with {:ok, data} <- Jason.decode(body),
               false <- Map.get(data, "erro", false) do
            "#{data["logradouro"]}, #{data["bairro"]} - #{data["localidade"]}/#{data["uf"]}"
          else
            _ -> "CEP nao encontrado."
          end

        _ ->
          "Nao consegui consultar o CEP agora."
      end
    end
  end

  def cotacao(from, to) do
    base = String.upcase(from)
    quote = String.upcase(to)
    with {:ok, value} <- cotacao_frankfurter(base, quote) do
      "Cotacao #{base}/#{quote}: #{Float.round(value, 4)}"
    else
      _ ->
        with {:ok, value} <- cotacao_awesomeapi(base, quote) do
          "Cotacao #{base}/#{quote}: #{Float.round(value, 4)}"
        else
          _ -> "API de cotacao indisponivel agora."
        end
    end
  end

  def curiosidade(city) do
    with {:ok, place} <- fetch_place(city),
         term <- place["display_name"] |> to_string() |> String.split(",") |> List.first() |> String.trim(),
         {:ok, summary} <- fetch_wikipedia_summary(term) do
      title = summary["title"] || city
      extract = summary["extract"] || "Sem resumo disponivel."
      "Curiosidade sobre #{title}: #{extract}"
    else
      {:error, :city_not_found} -> "Nao encontrei essa cidade para buscar curiosidade."
      _ -> "Nao consegui gerar curiosidade agora."
    end
  end

  def gato do
    case HTTPoison.get("https://api.thecatapi.com/v1/images/search") do
      {:ok, %{status_code: 200, body: body}} ->
        with {:ok, data} <- Jason.decode(body),
             [%{"url" => url} | _] <- data,
             true <- is_binary(url) do
          "Aqui vai um gato aleatorio pra voce: #{url}"
        else
          _ -> "Nao consegui buscar um gato agora."
        end

      _ ->
        "API de gatos indisponivel no momento."
    end
  end

  def lembrar(text) do
    case Store.add_reminder(text) do
      :ok -> "Lembrete salvo: #{text}"
      {:error, _reason} -> "Nao consegui salvar seu lembrete."
    end
  end

  def lembretes do
    case Store.list_reminders() do
      [] ->
        "Voce ainda nao tem lembretes salvos."

      list ->
        formatted =
          list
          |> Enum.with_index(1)
          |> Enum.map(fn {%{"texto" => texto}, idx} -> "#{idx}. #{texto}" end)
          |> Enum.join("\n")

        "Seus lembretes:\n" <> formatted
    end
  end

  defp geocode_city(city) do
    encoded = URI.encode(city)
    url = "https://geocoding-api.open-meteo.com/v1/search?name=#{encoded}&count=1&language=pt&format=json"

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, data} <- Jason.decode(body),
         [first | _] <- data["results"] do
      {:ok, first}
    else
      _ -> {:error, :city_not_found}
    end
  end

  defp fetch_weather(lat, lon) do
    url =
      "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}" <>
        "&current=temperature_2m,wind_speed_10m&timezone=auto"

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, data} <- Jason.decode(body),
         %{} <- data["current"] do
      {:ok, data}
    else
      _ -> {:error, :weather_error}
    end
  end

  defp fetch_place(city) do
    encoded = URI.encode(city)
    url = "https://nominatim.openstreetmap.org/search?q=#{encoded}&format=json&limit=1"
    headers = [{"user-agent", "meu-bot-discord/1.0"}]

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, [first | _]} <- Jason.decode(body) do
      {:ok, first}
    else
      _ -> {:error, :city_not_found}
    end
  end

  defp fetch_wikipedia_summary(term) do
    encoded = URI.encode(term)
    url = "https://pt.wikipedia.org/api/rest_v1/page/summary/#{encoded}"

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, data} <- Jason.decode(body),
         extract when is_binary(extract) <- data["extract"] do
      {:ok, data}
    else
      _ -> fetch_wikipedia_summary_by_search(term)
    end
  end

  defp fetch_wikipedia_summary_by_search(term) do
    encoded = URI.encode(term)
    search_url = "https://pt.wikipedia.org/w/api.php?action=query&list=search&srsearch=#{encoded}&utf8=1&format=json&srlimit=1"

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(search_url),
         {:ok, data} <- Jason.decode(body),
         [%{"title" => title} | _] <- get_in(data, ["query", "search"]),
         {:ok, summary} <- fetch_wikipedia_summary_direct(title) do
      {:ok, summary}
    else
      _ -> {:error, :wikipedia_error}
    end
  end

  defp fetch_wikipedia_summary_direct(title) do
    encoded = URI.encode(title)
    url = "https://pt.wikipedia.org/api/rest_v1/page/summary/#{encoded}"

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, data} <- Jason.decode(body),
         extract when is_binary(extract) <- data["extract"] do
      {:ok, data}
    else
      _ -> {:error, :wikipedia_error}
    end
  end

  defp cotacao_frankfurter(base, quote) do
    url = "https://api.frankfurter.app/latest?from=#{base}&to=#{quote}"

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, data} <- Jason.decode(body),
         rates when is_map(rates) <- data["rates"],
         value when is_number(value) <- rates[quote] do
      {:ok, value}
    else
      _ -> {:error, :frankfurter_failed}
    end
  end

  defp cotacao_awesomeapi(base, quote) do
    url = "https://economia.awesomeapi.com.br/json/last/#{base}-#{quote}"
    pair = "#{base}#{quote}"

    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url),
         {:ok, data} <- Jason.decode(body),
         entry when is_map(entry) <- data[pair],
         bid when is_binary(bid) <- entry["bid"],
         {value, ""} <- Float.parse(bid) do
      {:ok, value}
    else
      _ -> {:error, :awesomeapi_failed}
    end
  end
end
