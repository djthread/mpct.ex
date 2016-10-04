# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :mpct, Mpct.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bm/lriiNJggjYvUS+CNdP3MMHuxCbNDVWVEemw5m3u2iB+4pafH7n3na0izVTM8Z",
  render_errors: [view: Mpct.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mpct.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mpct, Mpct.Marantz,
  host: '192.168.0.180',
  port: 23

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
