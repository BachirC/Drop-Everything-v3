defmodule Dev3.Web.Dev3Controller do
  use Dev3.Web, :controller

  def index(conn, _) do
    redirect conn, to: "/gitbruh.html"
  end
end
