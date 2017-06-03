defmodule Dev3.Web.Dev3Controller do
  use Dev3.Web, :controller

  def index(conn, _) do
    redirect conn, external: "https://dev3.bachirc.me"
  end
end
