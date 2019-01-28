defmodule ResourceAccessCheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :resource_access_check,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:json, "~> 1.2"}
    ]
  end

  # escript 
  defp escript do
    [main_module: ResourceAccessCheck]
  end
end