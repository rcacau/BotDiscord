defmodule Abot.Command.Cep do

  def handle_cep(msg) do
    list = msg.content |> String.trim() |> String.split(" ")
    case list do
      ["!cep"] -> "Use o comando como: !cep <número>"
      ["!cep", number] -> create_response(number)
      _ -> "Comando inválido, use: !cep <número>"
    end
  end

  defp create_response(number) do
    {:ok, response} = HTTPoison.get("https://viacep.com.br/ws/#{number}/json/")
    cond do
      String.contains?(response.body, "erro") -> "Cep inválido, tente novamente!"
      true ->
        {:ok, json} = Jason.decode(response.body)
        "#{json["logradouro"]}, #{json["bairro"]}, #{json["localidade"]}, #{json["estado"]} (#{json["uf"]})"
    end
  end

end
