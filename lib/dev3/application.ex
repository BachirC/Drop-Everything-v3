defmodule Dev3.Application do
  @moduledoc """
    Entry-point of Dev3 app.
  """

  require Prometheus.Registry
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Dev3.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Dev3.Web.Endpoint, []),
      # Start your own worker by calling: Dev3.Worker.start_link(arg1, arg2, arg3)
      # worker(Dev3.Worker, [arg1, arg2, arg3]),
      supervisor(Task.Supervisor, [[name: Dev3.TaskSupervisor, restart: :transient]])
    ]
    Dev3.PhoenixInstrumenter.setup()
    Dev3.PipelineInstrumenter.setup()
    Dev3.RepoInstrumenter.setup()
    Prometheus.Registry.register_collector(:prometheus_process_collector)
    Dev3.PrometheusExporter.setup()
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dev3.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
