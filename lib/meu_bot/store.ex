defmodule MeuBot.Store do
  @moduledoc false
  use GenServer

  @data_dir "data"
  @file_path Path.join(@data_dir, "lembretes.json")

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_reminder(text) when is_binary(text) do
    GenServer.call(__MODULE__, {:add_reminder, text})
  end

  def list_reminders do
    GenServer.call(__MODULE__, :list_reminders)
  end

  @impl true
  def init(state) do
    File.mkdir_p!(@data_dir)

    if not File.exists?(@file_path) do
      File.write!(@file_path, "[]")
    end

    {:ok, state}
  end

  @impl true
  def handle_call({:add_reminder, text}, _from, state) do
    reminders = read_reminders()
    updated = reminders ++ [%{"texto" => text, "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601()}]

    case write_reminders(updated) do
      :ok -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:list_reminders, _from, state) do
    {:reply, read_reminders(), state}
  end

  defp read_reminders do
    with {:ok, raw} <- File.read(@file_path),
         {:ok, decoded} <- Jason.decode(raw),
         true <- is_list(decoded) do
      decoded
    else
      _ -> []
    end
  end

  defp write_reminders(reminders) do
    case Jason.encode(reminders, pretty: true) do
      {:ok, encoded} -> File.write(@file_path, encoded)
      {:error, reason} -> {:error, reason}
    end
  end
end
