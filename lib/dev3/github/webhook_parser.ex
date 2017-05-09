defmodule Dev3.GitHub.WebhookParser do
  @events Application.get_env(:dev3, GitHub)[:webhook_events]

  def parse(event, params) when event in @events do
    :ok
  end

  def parse(event, _params) do
    {:invalid_event, event}
  end
end
