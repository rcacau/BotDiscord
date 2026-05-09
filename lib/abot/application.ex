defmodule Abot.Application do
  @moduledoc """
  Compatibilidade com o projeto base. O módulo principal agora é MeuBot.Application.
  """

  defdelegate start(type, args), to: MeuBot.Application
end
