# MeuBot Discord (Elixir + Nostrum)

Projeto de bot Discord em Elixir para atividade de Programacao Funcional, com:

- comandos funcionais com pattern matching;
- consumo de APIs REST publicas;
- persistencia local em JSON;
- arquitetura modular com OTP (Application, Consumer, Commands e Store).

## Objetivo do Projeto

O bot foi adaptado para demonstrar boas praticas em Elixir:

- separacao de responsabilidades por modulo;
- tratamento de erros de entrada e de APIs externas;
- sem uso de estado global mutavel;
- persistencia encapsulada em processo dedicado (`GenServer`).

## Stack Tecnologica

- Elixir `~> 1.14`
- Nostrum (integracao com Discord Gateway)
- HTTPoison (requisicoes HTTP)
- Jason (serializacao/desserializacao JSON)

## Estrutura da Aplicacao

- `MeuBot.Application`
  - supervisor principal;
  - inicia `MeuBot.Store` e `MeuBot.Consumer`.

- `MeuBot.Consumer`
  - recebe eventos do Discord;
  - identifica comandos por pattern matching;
  - delega execucao para `MeuBot.Commands`.

- `MeuBot.Commands`
  - implementa regras de cada comando;
  - consulta APIs REST;
  - retorna mensagens prontas para envio no Discord.

- `MeuBot.Store`
  - persistencia de lembretes em `data/lembretes.json`;
  - leitura/escrita JSON encapsulada em `GenServer`.

## APIs Utilizadas por Comando

- `!ping`: `httpbin.org/status/200`
- `!clima`: `Open-Meteo Geocoding + Forecast`
- `!cep`: `ViaCEP`
- `!cotacao`: `Frankfurter` (fallback para `AwesomeAPI`)
- `!curiosidade`: `Nominatim + Wikipedia REST/API`
- `!gato`: `TheCatAPI` (imagem aleatoria)
- `!dog`: `Dog CEO API` (imagem aleatoria)
- `!piada`: `Official Joke API` (joke in english)
- `!lembrar`: persistencia local JSON
- `!lembretes`: leitura da persistencia local JSON
- `!ajuda`: lista os comandos disponiveis

## Comandos Disponiveis

- `!ping`
  - verifica se o bot esta respondendo.

- `!clima <cidade>`
  - exemplo: `!clima Sao Paulo`
  - retorna temperatura e velocidade do vento.

- `!cep <cep>`
  - exemplo: `!cep 01001000`
  - retorna logradouro, bairro, cidade e UF.

- `!cotacao <moeda1> <moeda2>`
  - exemplo: `!cotacao USD BRL`
  - retorna cotacao atual.

- `!curiosidade <cidade>`
  - exemplo: `!curiosidade Fortaleza`
  - busca localizacao e tenta retornar resumo da Wikipedia.

- `!gato`
  - retorna link de imagem aleatoria de gato.

- `!dog`
  - retorna link de imagem aleatoria de cachorro.

- `!piada`
  - retorna uma piada aleatoria em ingles.

- `!lembrar <texto>`
  - exemplo: `!lembrar estudar recursao`
  - salva lembrete no JSON local.

- `!lembretes`
  - lista lembretes salvos.

- `!ajuda`
  - mostra a lista de comandos disponiveis.

## Como Executar

### 1) Instalar dependencias

```bash
mix deps.get
```

### 2) Compilar

```bash
mix compile
```

### 3) Rodar

No PowerShell (Windows), use:

```powershell
iex.bat -S mix
```

Em outros terminais/sistemas:

```bash
iex -S mix
```

## Token do Discord

Atualmente o token esta configurado de forma fixa em `config/config.exs`.

Exemplo:

```elixir
config :nostrum,
  token: "SEU_TOKEN",
  gateway_intents: :all,
  ffmpeg: false
```

Importante:

- nao compartilhe o token publicamente;
- se o token vazar, gere um novo no Discord Developer Portal.

## Persistencia Local

- arquivo: `data/lembretes.json`
- criado/lido automaticamente pelo `MeuBot.Store`
- ignorado no Git via `.gitignore`

## Tratamento de Erros Implementado

- parametros ausentes (`!clima`, `!cep`, `!cotacao`, `!curiosidade`, `!lembrar`);
- CEP invalido;
- cidade nao encontrada;
- falhas de API externa;
- JSON ausente/invalido no arquivo de lembretes.

## Troubleshooting Rapido

- Bot conecta mas nao responde:
  - confira permissoes de envio no canal;
  - habilite `MESSAGE CONTENT INTENT` no Discord Developer Portal.

- Comando de cotacao falha:
  - pode ser indisponibilidade temporaria das APIs externas.

- No PowerShell aparece erro com `iex -S mix`:
  - use `iex.bat -S mix`.

## Compatibilidade com Projeto Base

O modulo `Abot` foi mantido para compatibilidade com a base original, enquanto a implementacao principal ficou em `MeuBot.*`.
