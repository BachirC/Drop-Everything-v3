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

  scope "/auth", Dev3.Web do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
  end
  scope "/api", Dev3.Web.API do
    pipe_through :api

    scope "/github", GitHub do
      post "/webhook", GitHubController, :webhook
    end

    scope "/slack", Slack do
      scope "/slash_commands" do
        post "/watchrepos", SlashCommandsController, :watch_repos
      end
    end
  end

  scope "/", Dev3.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
end
