defmodule Abot do
  @moduledoc """
  Compatibilidade com o projeto base. O consumer principal agora é MeuBot.Consumer.
  """

  defdelegate child_spec(opts), to: MeuBot.Consumer
end
