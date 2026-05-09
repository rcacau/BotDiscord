defmodule MeuBot.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MeuBot.Store,
      MeuBot.Consumer
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MeuBot.Supervisor)
  end
end
