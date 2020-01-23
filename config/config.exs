import Config

if Mix.env() == :test do
  config :ex_stone_openbank,
    adapter: ExStoneOpenbank.TeslaMock,
    time_skew: 210

  config :logger, level: :warn
end
