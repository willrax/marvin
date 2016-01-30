defmodule Marvin.WebAPI do
  use HTTPoison.Base

  def admin_api(method, params \\ []) do
    body = params
    |> Keyword.put(:token, Application.get_env(:marvin, :admin_token))
    Marvin.WebAPI.post(method, {:form, body})
  end

  def api(method, params \\ []) do
    body = params
    |> Keyword.put(:token, Application.get_env(:marvin, :slack_token))
    Marvin.WebAPI.post(method, {:form, body})
  end

  def process_url(url) do
    "https://slack.com/api" <> url
  end
end
