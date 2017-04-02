defmodule Dev3.Web.GithubHookView do
  use Dev3.Web, :view

  def render("200.json", _assigns) do
    "OK"
  end
end
