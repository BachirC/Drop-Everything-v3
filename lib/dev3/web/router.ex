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

  pipeline :exq do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug ExqUi.RouterPlug, namespace: "exq"
  end

  scope "/auth", Dev3.Web do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
  end
  scope "/api", Dev3.Web.API do
    pipe_through :api

    scope "/github", GitHub do
      post "/webhook", WebhookController, :webhook
    end

    scope "/slack", Slack do
      scope "/slash_commands" do
        post "/watchrepos", SlashCommandsController, :watch_repos
        post "/unwatchrepos", SlashCommandsController, :unwatch_repos
        post "/listrepos", SlashCommandsController, :list_repos
      end

      post "/message_interaction", MessageInteractionsController, :message_interaction
    end
  end

  scope "/exq", ExqUi do
    pipe_through :exq

    forward "/", RouterPlug.Router, :index
  end

  scope "/", Dev3.Web do
    pipe_through :browser # Use the default browser stack

    get "/", Dev3Controller, :index
  end
end
