defmodule MeuBot.Consumer do
  @moduledoc false
  use Nostrum.Consumer

  alias Nostrum.Api.Message
  alias MeuBot.Commands

  @impl true
  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    if msg.author.bot do
      :ignore
    else
      msg.content
      |> String.trim()
      |> String.split(~r/\s+/, trim: true)
      |> dispatch_command()
      |> maybe_reply(msg.channel_id)
    end
  end

  def handle_event(_event), do: :noop

  defp dispatch_command(["!ping"]), do: Commands.ping()
  defp dispatch_command(["!clima"]), do: "Uso: `!clima <cidade>`"
  defp dispatch_command(["!clima" | city_parts]), do: Commands.clima(Enum.join(city_parts, " "))
  defp dispatch_command(["!cep"]), do: "Uso: `!cep <cep>`"
  defp dispatch_command(["!cep", cep]), do: Commands.cep(cep)
  defp dispatch_command(["!cotacao"]), do: "Uso: `!cotacao <moeda1> <moeda2>`"
  defp dispatch_command(["!cotacao", from, to]), do: Commands.cotacao(from, to)
  defp dispatch_command(["!curiosidade"]), do: "Uso: `!curiosidade <cidade>`"
  defp dispatch_command(["!curiosidade" | city_parts]), do: Commands.curiosidade(Enum.join(city_parts, " "))
  defp dispatch_command(["!gato"]), do: Commands.gato()
  defp dispatch_command(["!dog"]), do: Commands.dog()
  defp dispatch_command(["!lembrar"]), do: "Uso: `!lembrar <texto>`"
  defp dispatch_command(["!lembrar" | parts]), do: Commands.lembrar(Enum.join(parts, " "))
  defp dispatch_command(["!lembretes"]), do: Commands.lembretes()
  defp dispatch_command(_), do: nil

  defp maybe_reply(nil, _channel_id), do: :ignore

  defp maybe_reply(text, channel_id) when is_binary(text) do
    Message.create(channel_id, text)
  end
end
