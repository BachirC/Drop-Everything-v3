defmodule Dev3.Web.Router do
  use Dev3.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Dev3.Web do
    pipe_through :api

    scope "/github" do
      get "/authorize", GithubAuthorizationController, :authorize
      get "/oauth_access", GithubAuthorizationController, :oauth_access
    end

    scope "/slack" do
      get "/oauth_access", SlackAuthorizationController, :oauth_access
    end
  end

  scope "/", Dev3.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
end
