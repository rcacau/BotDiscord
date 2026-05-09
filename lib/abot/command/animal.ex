defmodule Abot.Command.Animal do

  def handle_dog(msg) do
    if msg.content == "!dog" do
      {:ok, response} = HTTPoison.get("https://dog.ceo/api/breeds/image/random")
      {:ok, json} = Jason.decode(response.body)
      json["message"]
    end
  end

  def handle_cat(msg) do
    if msg.content == "!cat" do
      {:ok, response} = HTTPoison.get("https://api.thecatapi.com/v1/images/search")
      {:ok, json} = Jason.decode(response.body)
      Enum.at(json, 0)["url"]
    end
  end

end
