defmodule Dev3.Web.API.GitHub.WebhookController do
  use Dev3.Web, :controller
  alias Dev3.GitHub.WebhookParser

  action_fallback Dev3.Web.API.GitHub.WebhookFallbackController

  def webhook(conn, params) do
    event = Enum.fetch!(get_req_header(conn, "x-github-event"), 0)
    with :ok <- WebhookParser.parse(event, params) do
      send_resp(conn, 200, "")
    end
  end
end
