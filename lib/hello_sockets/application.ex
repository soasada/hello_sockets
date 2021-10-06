defmodule HelloSockets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias HelloSockets.Pipeline.Producer
  alias HelloSockets.Pipeline.ConsumerSupervisor, as: Consumer

  @impl true
  def start(_type, _args) do
    :ok = HelloSockets.Statix.connect()
    children = [
      {Producer, name: Producer},
      # With the consumer supervisor we are able to reach the max_demand because is able to create as many process in parallel
      # as CPU cores you have in your machine, thus you should configure max_demand to the number of CPU cores.
      # In summary, if we double the CPU cores we will double the execution parallelism of our pipeline.
      {Consumer, subscribe_to: [{Producer, max_demand: 10, min_demand: 5}]},
      # Start the Telemetry supervisor
      HelloSocketsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HelloSockets.PubSub},
      # Start the Endpoint (http/https)
      HelloSocketsWeb.Endpoint
      # Start a worker by calling: HelloSockets.Worker.start_link(arg)
      # {HelloSockets.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloSockets.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelloSocketsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
