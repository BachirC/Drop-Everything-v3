defmodule Dev3.Web.PageController do
  use Dev3.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
