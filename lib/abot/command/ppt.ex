defmodule Abot.Command.Ppt do

  @ppt_valid_values ["pedra", "papel", "tesoura"]

  def handle_ppt(msg) do
    list = msg.content |> String.trim |> String.split(" ")
    case list do
      ["!ppt"] -> "Use o comando como: !ppt <pedra | papel | tesoura>"
      ["!ppt", player_choice] when player_choice in @ppt_valid_values -> play_game(player_choice)
      _ -> "Comando inválido use: !ppt <pedra | papel | tesoura>"
    end
  end

  defp get_bot_choice() do
    Enum.random(@ppt_valid_values)
  end

  defp play_game("pedra") do
    case get_bot_choice() do
      "pedra" -> "😵 Houve um empate! Você escolheu pedra 🪨 e eu também!"
      "papel" -> "😄 Eu ganhei! Você escolheu pedra 🪨 e eu escolhi papel 📄!"
      "tesoura" -> "🏆 Você venceu! Você escolheu pedra 🪨 e eu escolhi tesoura ✂️"
    end
  end

  defp play_game("papel") do
    case get_bot_choice() do
      "pedra" -> "🏆 Você venceu! Você escolheu papel 📄 e eu escolhi pedra 🪨"
      "papel" -> "😵 Houve um empate! Você escolheu papel 📄 e eu também!"
      "tesoura" -> "😄 Eu ganhei! Você escolheu papel 📄 e eu escolhi tesoura ✂️!"
    end
  end

  defp play_game("tesoura") do
    case get_bot_choice() do
      "pedra" -> "😄 Eu ganhei! Você escolheu tesoura ✂️ e eu escolhi pedra 🪨!"
      "papel" -> "🏆 Você venceu! Você escolheu tesoura ✂️ e eu escolhi papel 📄"
      "tesoura" -> "😵 Houve um empate! Você escolheu tesoura ✂️ e eu também!"
    end
  end

end
