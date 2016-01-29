defmodule Marvin.WebAPI do
  @endpoint "https://slack.com/api"

  def post_message(params) do
    body = params
    |> Keyword.put(:token, Application.get_env(:marvin, :slack_token))
    |> Keyword.put(:as_user, true)

    HTTPoison.post(@endpoint <> "/chat.postMessage", {:form, body})
  end

  def open_mpim(params) do
    body = params
    |> Keyword.put(:token, Application.get_env(:marvin, :slack_token))

    HTTPoison.post(@endpoint <> "/mpim.open", {:form, body})
  end
end
